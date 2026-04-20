import 'dart:async';
import 'dart:developer' as devtools;

import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/utils/map_marker_utils.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/widgets/store_card.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class StoreMapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? selectedStoreId;

  const StoreMapScreen({
    super.key,
    this.initialLocation,
    this.selectedStoreId,
  });

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _addressController = TextEditingController();
  bool _isSearchLoading = false;

  String? _error;
  bool _isLoading = true;

  LatLng _currentLocation = AppConsts.defaultMapLocation;
  Set<Marker> _markers = {};
  FoodStoreProvider? _foodStoreProvider;

  Future<void> _refreshDataInBackground() async {
    try {
      await _foodStoreProvider!.fetchNearbyFoodStores();
      if (_foodStoreProvider!.error == null) {
        await _updateMarkers(_foodStoreProvider!.nearbyFoodStores);
      }
    } catch (e) {
      devtools.log('Background refresh failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _currentLocation = widget.initialLocation!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLocation != null) {
        _fetchDataForLocation(widget.initialLocation!);
      } else {
        _getUserLocationAndFetchStores();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _foodStoreProvider ??= Provider.of<FoodStoreProvider>(
      context,
      listen: false,
    );
  }

  Future<void> _fetchDataForLocation(LatLng location) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _foodStoreProvider!.setLocationForNearbySearch(
        location.latitude,
        location.longitude,
      );

      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(location, 14.0));

      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }

      await _foodStoreProvider!.fetchNearbyFoodStores();
      if (_foodStoreProvider!.error != null) {
        throw Exception(_foodStoreProvider!.error);
      }

      await _updateMarkers(_foodStoreProvider!.nearbyFoodStores);

      if (widget.selectedStoreId != null) {
        final selectedStore =
            _foodStoreProvider!.nearbyFoodStores
                .where((s) => s.id == widget.selectedStoreId)
                .firstOrNull;
        if (selectedStore != null) {
          _showStoreDetails(selectedStore);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is PlatformException) {
            _error = S.of(context).foodStoreMap_geocodingError;
          } else {
            _error = e.toString().replaceFirst("Exception: ", "");
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onAddressSearch() async {
    if (_addressController.text.isEmpty) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSearchLoading = true;
      _error = null;
    });

    try {
      final locations = await geocoding.locationFromAddress(
        _addressController.text,
      );

      final firstLocation = locations.firstOrNull;

      if (firstLocation != null) {
        final newLocation = LatLng(
          firstLocation.latitude,
          firstLocation.longitude,
        );

        await _fetchDataForLocation(newLocation);
      } else {
        throw Exception(S.of(context).foodStoreMap_addressNotFound);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is PlatformException) {
            _error = S.of(context).foodStoreMap_geocodingError;
          } else {
            _error = e.toString().replaceFirst("Exception: ", "");
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchLoading = false;
        });
      }
    }
  }

  Future<void> _getUserLocationAndFetchStores() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _determinePosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      await _fetchDataForLocation(newLocation);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    final locationDisabledMsg = S.of(context).foodStoreMap_locationDisabled;
    final permissionDeniedMsg = S.of(context).foodStoreMap_permissionDenied;
    final permissionPermanentlyDeniedMsg =
        S.of(context).foodStoreMap_permissionDeniedPermanently;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(locationDisabledMsg);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(permissionDeniedMsg);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(permissionPermanentlyDeniedMsg);
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _centerMap() async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.0,
            left: 10,
            right: 10,
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(30.0),
              child: TextField(
                controller: _addressController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onAddressSearch(),
                decoration: InputDecoration(
                  hintText: S.of(context).foodStoreMap_searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _isSearchLoading
                          ? const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            ),
                          )
                          : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _addressController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),

          if (_error != null)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getUserLocationAndFetchStores,
                        child: Text(S.of(context).foodStoreMap_retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'foodStoreMapScreenFab',
        onPressed: _getUserLocationAndFetchStores,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _updateMarkers(List<FoodStore> stores) async {
    final List<Marker> markers = [];

    for (final store in stores.where((s) => s.address != null)) {
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

      final customIcon = await MapMarkerUtils.loadStoreMarkerIcon(
        store.profileImageUrl,
      );
      if (customIcon != null) {
        icon = customIcon;
      }

      final marker = Marker(
        markerId: MarkerId(store.id),
        position: LatLng(store.address!.latitude, store.address!.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: store.name,
          snippet: store.address?.street,
        ),
        onTap: () => _showStoreDetails(store),
      );

      markers.add(marker);
    }

    if (mounted) {
      setState(() {
        _markers = markers.toSet();
      });
    }
  }

  void _showStoreDetails(FoodStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: StoreCard(store: store),
              ),
            );
          },
        );
      },
    );
  }
}
