import 'dart:async';
import 'dart:developer' as devtools;
import 'dart:io';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/data/models/picked_location.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerScreen({
    super.key,
    this.initialLocation = AppConsts.defaultMapLocation,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _loggerName = 'MapPickerScreen';
  late LatLng _pickedLocation;
  bool _isFetchingLocation = false;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  void _confirmSelection() {
    devtools.log('Confirming location: $_pickedLocation', name: _loggerName);
    Navigator.of(context).pop(_pickedLocation);
  }

  Future<void> _getCurrentLocation() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);
    devtools.log('Starting: Get Current Location', name: _loggerName);

    try {
      final position = await _determinePosition();
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
      });
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(_pickedLocation));
      devtools.log('Success: Moved map to current location', name: _loggerName);
    } catch (e) {
      devtools.log('Error getting location: $e', name: _loggerName, error: e);
      if (mounted) {
        String errorMessage = "Could not fetch location. Please try again.";
        final errorString = e.toString();
        if (errorString.contains('denied')) {
          errorMessage =
              "Location permissions are denied. Please enable them in your app settings.";
        } else if (errorString.contains('disabled')) {
          errorMessage = "Location services are disabled. Please enable GPS.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pickedLocation,
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              onCameraMove: (position) {
                _pickedLocation = position.target;
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
            const IgnorePointer(
              child: Icon(Icons.location_pin, size: 50, color: Colors.red),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 15,
              left: 15,
              child: FloatingActionButton.small(
                heroTag: 'back_button',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: const Icon(Icons.arrow_back),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(S.of(context).storeForm_confirmLocation),
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: _getCurrentLocation,
                    tooltip: 'Get Current Location',
                    child:
                        _isFetchingLocation
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }
  return await Geolocator.getCurrentPosition();
}

class StoreFormScreen extends StatefulWidget {
  final FoodStore? existingStore;

  const StoreFormScreen({super.key, this.existingStore});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  static const _loggerName = 'StoreFormScreen';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  XFile? _selectedImage;
  PickedLocation? _pickedLocation;
  LatLng _mapCenter = AppConsts.defaultMapLocation;

  bool _isSubmitting = false;
  bool _isGeocoding = false;
  bool _isPickingImage = false;

  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _disposableMapController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingStore?.name);
    _descController = TextEditingController(
      text: widget.existingStore?.description,
    );

    final mode = widget.existingStore == null ? 'CREATE' : 'EDIT';
    devtools.log('Initializing screen in $mode mode.', name: _loggerName);

    if (widget.existingStore?.address != null) {
      final address = widget.existingStore!.address!;
      _mapCenter = LatLng(address.latitude, address.longitude);
      _pickedLocation = PickedLocation.fromJson(address.toJson());
      devtools.log(
        'Loaded existing store location: $_mapCenter',
        name: _loggerName,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    devtools.log('Starting: Image Picking from $source', name: _loggerName);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
        devtools.log('Image selected: ${pickedFile.path}', name: _loggerName);
      } else {
        devtools.log('Image picking cancelled by user.', name: _loggerName);
      }
    } catch (e, s) {
      devtools.log(
        'Error in Image Picking',
        name: _loggerName,
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        _showSnackBar(S.of(context).storeForm_operationFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).foodStoreTabGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reverseGeocode() async {
    if (_isGeocoding) return;
    setState(() => _isGeocoding = true);
    devtools.log(
      'Starting: Reverse Geocoding for position: $_mapCenter',
      name: _loggerName,
    );
    try {
      final placemarks = await placemarkFromCoordinates(
        _mapCenter.latitude,
        _mapCenter.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        setState(() {
          _pickedLocation = PickedLocation(
            latitude: _mapCenter.latitude,
            longitude: _mapCenter.longitude,
            street: p.street,
            city: p.locality,
            state: p.administrativeArea,
            zipCode: p.postalCode,
            country: p.country,
            additionalDetails: '${p.name ?? ''} ${p.subLocality ?? ''}'.trim(),
          );
        });
        devtools.log(
          'Success: Reverse Geocoding - ${p.street}, ${p.locality}',
          name: _loggerName,
        );
      }
    } catch (e, s) {
      devtools.log(
        'Error in Reverse Geocoding',
        name: _loggerName,
        error: e,
        stackTrace: s,
      );
      if (mounted)
        _showSnackBar(
          S.of(context).storeForm_couldNotFetchAddress,
          isError: true,
        );
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _openMapPicker() async {
    devtools.log(
      'Opening map picker with initial location: $_mapCenter',
      name: _loggerName,
    );

    final LatLng? selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapPickerScreen(initialLocation: _mapCenter),
      ),
    );

    if (selectedLocation != null && mounted) {
      devtools.log(
        'New location selected from picker: $selectedLocation',
        name: _loggerName,
      );

      setState(() {
        _mapCenter = selectedLocation;
        _pickedLocation = null;
      });

      final controller = await _mapControllerCompleter.future;
      controller.animateCamera(CameraUpdate.newLatLng(_mapCenter));
      await _reverseGeocode();
    } else {
      devtools.log(
        'Map picker closed without selecting a new location.',
        name: _loggerName,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) {
      devtools.log('Form validation failed.', name: _loggerName);
      return;
    }
    if (_pickedLocation == null) {
      devtools.log(
        'Submit attempted without a selected location.',
        name: _loggerName,
      );
      _showSnackBar(
        S.of(context).storeForm_pleaseSelectLocation,
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final operation =
        widget.existingStore == null ? 'Create Store' : 'Update Store';
    devtools.log('Starting: $operation', name: _loggerName);

    try {
      final storeProvider = context.read<FoodStoreProvider>();
      if (widget.existingStore == null) {
        await storeProvider.createStore(
          name: _nameController.text,
          description: _descController.text,
          imageFile: _selectedImage,
          location: _pickedLocation!.toMap(),
        );
      } else {
        await storeProvider.updateStore(
          description: _descController.text,
          latitude: _pickedLocation!.latitude,
          longitude: _pickedLocation!.longitude,
          street: _pickedLocation!.street ?? '',
          city: _pickedLocation!.city ?? '',
          state: _pickedLocation!.state ?? '',
          zipCode: _pickedLocation!.zipCode ?? '',
          country: _pickedLocation!.country ?? '',
          additionalDetails: _pickedLocation!.additionalDetails ?? '',
        );
        if (_selectedImage != null) {
          await storeProvider.updateProfileImage(_selectedImage!);
        }
        if (mounted) Navigator.pop(context);
      }
      devtools.log('Success: $operation', name: _loggerName);
    } catch (e, s) {
      devtools.log(
        'Error in $operation',
        name: _loggerName,
        error: e,
        stackTrace: s,
      );
      if (mounted)
        _showSnackBar(S.of(context).storeForm_operationFailed, isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    devtools.log('Disposing screen.', name: _loggerName);
    _nameController.dispose();
    _descController.dispose();
    _disposableMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: _buildHeader(),
      ),
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(),
                _buildFormFields(),
                const SizedBox(height: 32),
                _buildMapSection(),
                _buildLocationDetails(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: _openMapPicker,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AbsorbPointer(
                absorbing: true,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _disposableMapController = controller;
                    if (!_mapControllerCompleter.isCompleted) {
                      _mapControllerCompleter.complete(controller);
                    }
                    devtools.log(
                      'Google Map preview created.',
                      name: _loggerName,
                    );
                    if (_pickedLocation == null &&
                        widget.existingStore?.address != null) {
                      _reverseGeocode();
                    }
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                ),
              ),
            ),
          ),
          const IgnorePointer(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withOpacity(0.1),
              ),
              child: Center(
                child: Chip(
                  avatar: Icon(Icons.touch_app, color: Colors.black54),
                  label: Text(S.of(context).storeForm_tapToSelectLocation),
                  backgroundColor: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    if (_isGeocoding) {
      return const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Fetching address..."),
          ],
        ),
      );
    }

    if (_pickedLocation == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          S.of(context).storeForm_moveTheMapToSelectLocation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );
    }

    final address =
        '${_pickedLocation!.street ?? ''}\n'
        '${_pickedLocation!.city ?? ''}, ${_pickedLocation!.state ?? ''} '
        '${_pickedLocation!.zipCode ?? ''}\n'
        '${_pickedLocation!.country ?? ''}';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).storeForm_selectedLocation,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            address.trim().isEmpty
                ? S.of(context).storeForm_addressNotAvailable
                : address,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConsts.secondaryAccentColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon:
          _isSubmitting
              ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : const Icon(Icons.save, color: Colors.white),
      label: Text(
        widget.existingStore == null
            ? S.of(context).storeForm_createStore
            : S.of(context).storeForm_save,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: _isSubmitting ? null : _submitForm,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.existingStore != null) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            Expanded(
              child: Center(
                child: Text(
                  widget.existingStore == null
                      ? S.of(context).storeForm_createStore
                      : S.of(context).storeForm_editStore,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            if (widget.existingStore != null) const SizedBox(width: 48),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildProfileImage(),
                  if (_selectedImage == null &&
                      widget.existingStore?.profileImageUrl == null)
                    const Icon(Icons.camera_alt, size: 40, color: Colors.grey),

                  if (_selectedImage != null ||
                      widget.existingStore?.profileImageUrl != null)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(Icons.edit, size: 24, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: _showImageSourceDialog,
          child: Text(
            _selectedImage != null
                ? S.of(context).storeForm_changeImage
                : S.of(context).storeForm_uploadImage,
            style: const TextStyle(color: Colors.black45),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    if (widget.existingStore?.profileImageUrl != null) {
      return NetworkImageWidget(
        imageUrl: widget.existingStore!.profileImageUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox();
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomInputField(
          isEnabled: widget.existingStore == null,
          controller: _nameController,
          hintText: S.of(context).storeForm_nameHint,
          labelText: S.of(context).storeForm_nameLabel,
          validator:
              (value) =>
                  value!.isEmpty ? S.of(context).storeForm_requiredField : null,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          controller: _descController,
          hintText: S.of(context).storeForm_bioHint,
          labelText: S.of(context).storeForm_bioLabel,
          maxLines: 3,
          validator:
              (value) =>
                  value!.isEmpty ? S.of(context).storeForm_requiredField : null,
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
