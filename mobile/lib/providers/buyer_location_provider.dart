import 'dart:async';
import 'dart:developer' as devtools;

import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/data/models/picked_location.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuyerLocationsProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  BuyerLocationsProvider({required ApiClient apiClient})
    : _apiClient = apiClient;

  final List<PickedLocation> _locations = [];
  bool _isLoading = false;
  PickedLocation? _selectedLocation;

  List<PickedLocation> get locations => _locations;
  bool get isLoading => _isLoading;
  PickedLocation? get selectedLocation => _selectedLocation;

  Future<void> fetchLocations() async {
    devtools.log('[Locations] Starting fetchLocations');
    try {
      _isLoading = true;
      clearError();
      notifyListeners();
      devtools.log('[Locations] Fetching locations from API');

      final response = await _apiClient.get(ApiEndpoints.buyerLocations);

      devtools.log('[Locations] API response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        devtools.log('[Locations] Received ${data.length} locations');

        _locations.clear();
        _locations.addAll(
          data.map(
            (item) => PickedLocation.fromMap(item as Map<String, dynamic>),
          ),
        );

        devtools.log(
          '[Locations] Successfully loaded ${_locations.length} locations',
        );
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to load locations');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[Locations] fetchLocations completed');
    }
  }

  Future<void> addLocation() async {
    devtools.log('[Locations] Starting addLocation');
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      if (_selectedLocation == null) {
        handleError(
          Exception('Please select a location on the map'),
          StackTrace.current,
          fallbackMessage: 'Please select a location on the map',
        );
        devtools.log('[Locations] No location selected for add');
        _isLoading = false;
        notifyListeners();
        return;
      }

      devtools.log(
        '[Locations] Posting location: ${_selectedLocation!.toMap()}',
      );
      final response = await _apiClient.post(
        ApiEndpoints.buyerLocations,
        body: _adaptLocationData(_selectedLocation!),
      );

      devtools.log('[Locations] Add response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final newLocation = PickedLocation.fromMap(
          response.data as Map<String, dynamic>,
        );
        _locations.add(newLocation);
        devtools.log('[Locations] Added location ID: ${newLocation.id}');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to add location');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[Locations] addLocation completed');
    }
  }

  Future<void> fetchLocation(String locationId) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.get(
        ApiEndpoints.buyerLocation(locationId),
      );

      if (response.statusCode == 200) {
        _selectedLocation = PickedLocation.fromMap(
          response.data as Map<String, dynamic>,
        );

        _address = _selectedLocation?.street ?? '';
        devtools.log('[Locations] Fetched location: $locationId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to fetch location');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(String locationId, PickedLocation updates) async {
    devtools.log('[Locations] Starting update for $locationId');
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      devtools.log('[Locations] Sending update: ${updates.toMap()}');
      final response = await _apiClient.patch(
        ApiEndpoints.buyerLocation(locationId),
        body: _adaptLocationData(updates),
      );

      devtools.log('[Locations] Update response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final updatedLocation = PickedLocation.fromMap(
          response.data as Map<String, dynamic>,
        );
        final index = _locations.indexWhere((loc) => loc.id == locationId);

        if (index != -1) {
          _locations[index] = updatedLocation;
          devtools.log('[Locations] Updated index $index');
        }

        _selectedLocation = updatedLocation;
        devtools.log('[Locations] Successfully updated $locationId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to update location');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[Locations] updateLocation completed');
    }
  }

  Future<void> deleteLocation(String locationId) async {
    devtools.log('[Locations] Starting delete for $locationId');
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      devtools.log('[Locations] Sending delete request');
      final response = await _apiClient.delete(
        ApiEndpoints.buyerLocation(locationId),
      );

      devtools.log('[Locations] Delete response: ${response.statusCode}');
      if (response.statusCode == 200) {
        _locations.removeWhere((loc) => loc.id == locationId);
        devtools.log('[Locations] Removed $locationId from local list');

        if (_selectedLocation?.id == locationId) {
          _selectedLocation = null;
          devtools.log('[Locations] Cleared selected location');
        }
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to delete location');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[Locations] deleteLocation completed');
    }
  }

  Map<String, dynamic> _adaptLocationData(PickedLocation location) {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'street': location.street,
      'city': location.city,
      'state': location.state,
      'zipCode': location.zipCode,
      'country': location.country,
      'additionalDetails': location.additionalDetails,
    };
  }

  void clearSelection() {
    _address = '';
    _selectedLocation = null;
    notifyListeners();
  }

  String _address = '';
  String get address => _address;

  Future<void> updateSelectedLocation(
    PickedLocation location,
    Completer<GoogleMapController> mapController,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedLocation = location;

      final controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 15,
          ),
        ),
      );

      clearError();
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to get address');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateAddress(String newAddress) {
    if (_selectedLocation != null) {
      _selectedLocation = _selectedLocation!.copyWith(street: newAddress);
    }
    _address = newAddress;
    notifyListeners();
  }

  Future<void> getCurrentLocation(
    Completer<GoogleMapController> mapController,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        handleError(
          Exception('Location services are disabled'),
          StackTrace.current,
          fallbackMessage: 'Location services are disabled',
        );
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          handleError(
            Exception('Location permissions are denied'),
            StackTrace.current,
            fallbackMessage: 'Location permissions are denied',
          );
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        handleError(
          Exception('Location permissions are permanently denied'),
          StackTrace.current,
          fallbackMessage: 'Location permissions are permanently denied',
        );
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await updateFromPlacemark(
        position.latitude,
        position.longitude,
        mapController,
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Location error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFromPlacemark(
    double latitude,
    double longitude,
    Completer<GoogleMapController> mapController,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

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
        handleError(
          Exception('Failed to get address'),
          StackTrace.current,
          fallbackMessage: 'Failed to get address',
        );
        return;
      }

      final p = selectedPlacemark;
      final picked = PickedLocation(
        latitude: latitude,
        longitude: longitude,
        street: p.street,
        city: p.locality,
        state: p.administrativeArea,
        zipCode: zipCode,
        country: p.country,
        additionalDetails: '${p.name ?? ''} ${p.subLocality ?? ''}'.trim(),
      );

      await updateSelectedLocation(picked, mapController);
      devtools.log('Picked Location: ${picked.toJson().toString()}');
      _address = picked.street!;
      clearError();
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to get address');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatAddress(Placemark place) {
    return [
      place.street,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ].where((part) => part?.isNotEmpty ?? false).join(', ');
  }
}
