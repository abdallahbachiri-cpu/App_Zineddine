import 'dart:io';

import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/dish_ingredients_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/ingredients_provider.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MenuItemFormScreen extends StatefulWidget {
  final String? dishId;
  const MenuItemFormScreen({super.key, this.dishId});

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<XFile> _selectedImages = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.dishId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeEditingState();
      });
    }
  }

  Future<void> _initializeEditingState() async {
    final dishProvider = context.read<SellerDishProvider>();
    final ingredientsProvider = context.read<DishIngredientsProvider>();

    await Future.wait([
      dishProvider.getDishById(widget.dishId!),
      ingredientsProvider.fetchDishIngredients(widget.dishId!),
      context.read<IngredientsProvider>().fetchIngredients(),
    ]);

    final dish = dishProvider.selectedDish;
    if (dish != null) {
      _nameController.text = dish.name;
      _priceController.text = dish.price.toString();
      _descriptionController.text = dish.description ?? '';
    }
  }

  Future<void> _handleFormSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    final dishProvider = context.read<SellerDishProvider>();

    if (_isEditing) {
      await dishProvider.updateDish(
        id: widget.dishId!,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        gallery: _selectedImages,
      );
    } else {
      await dishProvider.createDish(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        gallery: _selectedImages,
      );
    }
    if (mounted) {
      if (dishProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dishProvider.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(
          _isEditing
              ? S.of(context).dishForm_editTitle
              : S.of(context).dishForm_createTitle,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Consumer<SellerDishProvider>(
          builder: (context, provider, _) => _buildSubmitButton(provider),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<SellerDishProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && _isEditing) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 8),
                    _buildPriceField(),
                    const SizedBox(height: 8),
                    _buildDescriptionField(),
                    const SizedBox(height: 8),
                    _buildImageSection(context, provider),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomInputField(
      controller: _nameController,
      labelText: S.of(context).dishForm_nameLabel,
      hintText: S.of(context).dishForm_nameHint,
      validator:
          (value) =>
              value?.isEmpty ?? true ? S.of(context).validationRequired : null,
    );
  }

  Widget _buildPriceField() {
    return CustomInputField(
      controller: _priceController,
      labelText: S.of(context).dishForm_priceLabel,
      hintText: S.of(context).dishForm_priceHint,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return S.of(context).validationRequired;
        return double.tryParse(value!) == null
            ? S.of(context).validationInvalidPrice
            : null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return CustomInputField(
      controller: _descriptionController,
      labelText: S.of(context).dishForm_descriptionLabel,
      hintText: S.of(context).dishForm_descriptionHint,
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton(SellerDishProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomButton(
        type: ButtonType.elevated,
        size: ButtonSize.large,
        shape: ButtonShape.rounded,
        borderRadius: 10,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        padding: EdgeInsetsDirectional.symmetric(vertical: 10),
        onPressed:
            provider.isLoading || provider.isProcessing
                ? () {}
                : _handleFormSubmission,
        isLoading: provider.isLoading || provider.isProcessing,
        loadingIndicatorColor: AppConsts.accentColor,
        text:
            _isEditing
                ? S.of(context).dishForm_updateButton
                : S.of(context).dishForm_createButton,
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, SellerDishProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).dishForm_imagesLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._buildExistingImages(provider),
            ..._buildNewImages(),
            _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildExistingImages(SellerDishProvider provider) {
    if (provider.selectedDish == null || !_isEditing) return [];

    return provider.selectedDish!.gallery
        .map(
          (media) => Stack(
            children: [
              NetworkImageWidget(
                imageUrl: media.url,
                width: 100,
                height: 100,
                borderRadius: BorderRadius.circular(10),
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed:
                      () => _confirmDeleteMedia(
                        context,
                        widget.dishId!,
                        media.id,
                      ),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  List<Widget> _buildNewImages() {
    return _selectedImages
        .map(
          (file) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.file(File(file.path), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _selectedImages.remove(file)),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: const Center(child: Icon(Icons.add_a_photo)),
      ),
    );
  }

  Future<void> _pickImages() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _onPickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(S.of(context).foodStoreTabGallery),
                  onTap: () {
                    Navigator.pop(context);
                    _onPickImagesFromGallery();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _onPickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImages.add(image));
    }
  }

  Future<void> _onPickImagesFromGallery() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _confirmDeleteMedia(
    BuildContext context,
    String dishId,
    String mediaId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).dishForm_deleteImageTitle),
            content: Text(S.of(context).dishForm_deleteImageContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).manageCategoriesCancel),
              ),
              TextButton(
                onPressed: () async {
                  final provider = context.read<SellerDishProvider>();
                  await provider.deleteMedia(dishId, mediaId);
                  if (context.mounted) {
                    if (provider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error!),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(S.of(context).addressManagement_deleteConfirm),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
