import 'dart:async';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/buyer_location_provider.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools;

class AddressFormScreen extends StatefulWidget {
  final String? locationId;

  const AddressFormScreen({super.key, this.locationId});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final BuyerLocationsProvider _provider;
  late final TextEditingController _addressController;
  final Completer<GoogleMapController> _mapController = Completer();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _provider = context.read<BuyerLocationsProvider>();
    _addressController = TextEditingController(text: _provider.address);
    _provider.addListener(_updateAddressController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.locationId != null) {
        _provider.clearSelection();
        _provider.fetchLocation(widget.locationId!);
      } else {
        _provider.clearSelection();
      }
    });
  }

  void _updateAddressController() {
    if (_addressController.text != _provider.address) {
      _addressController.text = _provider.address;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _provider.removeListener(_updateAddressController);
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => {
                context.read<BuyerLocationsProvider>().clearSelection(),
                Navigator.of(context).pop(),
              },
        ),
        title: Text(
          widget.locationId == null
              ? S.of(context).editAddress_addTitle
              : S.of(context).editAddress_editTitle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<BuyerLocationsProvider>(
          builder: (context, provider, _) {
            if (provider.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
                provider.clearError();
              });
            }

            if (widget.locationId != null &&
                provider.selectedLocation == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAddressForm(provider),
                const SizedBox(height: 24),
                _buildMapSection(provider),
                const SizedBox(height: 24),
                _buildActionButtons(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressForm(BuyerLocationsProvider provider) {
    final l10n = S.of(context);
    return CustomInputField(
      controller: _addressController,
      labelText: S.of(context).editAddress_streetLabel,
      hintText: S.of(context).editAddress_streetHint,
      prefixIcon: Icons.location_on,
      onChanged: (value) async {
        provider.updateAddress(value);
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () async {
          final trimmed = value.trim();
          if (trimmed.isEmpty) return;

          try {
            final locations = await locationFromAddress(trimmed);
            if (locations.isNotEmpty) {
              final loc = locations.first;

              final placemarks = await placemarkFromCoordinates(
                loc.latitude,
                loc.longitude,
              );

              String? zipCode;
              Placemark? selectedPlacemark;

              for (final p in placemarks) {
                selectedPlacemark ??= p;
                if (p.postalCode != null && p.postalCode!.isNotEmpty) {
                  zipCode = p.postalCode;
                  selectedPlacemark = p;
                  break;
                }
              }

              if (selectedPlacemark == null) {
                throw Exception(l10n.editAddress_failedToGetAddress);
              }

              final p = selectedPlacemark;

              final picked = provider.selectedLocation?.copyWith(
                latitude: loc.latitude,
                longitude: loc.longitude,
                street: trimmed,
                city: p.locality,
                state: p.administrativeArea,
                zipCode: zipCode ?? "",
                country: p.country,
                additionalDetails:
                    '${p.name ?? ''} ${p.subLocality ?? ''}'.trim(),
              );
              if (picked != null) {
                await provider.updateSelectedLocation(picked, _mapController);
              } else {
                throw Exception(l10n.editAddress_failedToUpdateLocation);
              }
            }
          } catch (e) {
            devtools.log('Geocoding failed: ${e.toString()}');
          }
        });
      },
    );
  }

  Widget _buildActionButtons(BuyerLocationsProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: provider.isLoading ? null : () => _handleSubmit(provider),
      child: Text(
        provider.isLoading
            ? S.of(context).editAddress_processing
            : widget.locationId == null
            ? S.of(context).editAddress_saveButton
            : S.of(context).editAddress_updateButton,
      ),
    );
  }

  void _handleSubmit(BuyerLocationsProvider provider) async {
    widget.locationId == null
        ? await provider.addLocation()
        : await provider.updateLocation(
          widget.locationId!,
          provider.selectedLocation!,
        );

    if (mounted) {
      if (provider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.locationId == null
                  ? 'Address added successfully'
                  : 'Address updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildMapSection(BuyerLocationsProvider provider) {
    final LatLng initialPosition =
        provider.selectedLocation != null
            ? LatLng(
              provider.selectedLocation!.latitude,
              provider.selectedLocation!.longitude,
            )
            : const LatLng(45.5017, -73.5673);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              S.of(context).editAddress_mapTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 11,
                ),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                  if (provider.selectedLocation != null) {
                    controller.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          provider.selectedLocation!.latitude,
                          provider.selectedLocation!.longitude,
                        ),
                      ),
                    );
                  } else {
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(45.5017, -73.5673),
                        10,
                      ),
                    );
                  }
                },
                onTap: (LatLng position) {
                  provider.updateFromPlacemark(
                    position.latitude,
                    position.longitude,
                    _mapController,
                  );
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers:
                    provider.selectedLocation != null
                        ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: LatLng(
                              provider.selectedLocation!.latitude,
                              provider.selectedLocation!.longitude,
                            ),
                          ),
                        }
                        : {},
              ),
            ),
          ],
        ),
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed:
                () =>
                    provider.isLoading
                        ? null
                        : provider.getCurrentLocation(_mapController),
            child: const Icon(Icons.my_location, size: 20),
          ),
        ),
      ],
    );
  }
}
