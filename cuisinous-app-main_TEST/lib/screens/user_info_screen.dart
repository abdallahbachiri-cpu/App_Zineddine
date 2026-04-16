import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/data/models/user_model.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  XFile? _selectedImage;
  bool _isEditing = false;
  String _selectedCountryCode = '+1';
  String _initialCountrySelection = 'CA';

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user!;
    _updateFormValues(user);
  }

  void _updateFormValues(User user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _parsePhoneNumber(user.phoneNumber);
  }

  void _parsePhoneNumber(String? fullNumber) {
    if (fullNumber == null ||
        fullNumber.isEmpty ||
        !fullNumber.startsWith('+')) {
      _selectedCountryCode = '+1';
      _phoneController.text = fullNumber ?? '';
      _initialCountrySelection = 'CA';
      return;
    }

    if (fullNumber.startsWith('+213')) {
      _selectedCountryCode = '+213';
      _phoneController.text = fullNumber.substring(4);
      _initialCountrySelection = 'DZ';
    } else if (fullNumber.startsWith('+1')) {
      _selectedCountryCode = '+1';
      _phoneController.text = fullNumber.substring(2);
      _initialCountrySelection = 'CA';
    } else {
      int splitIndex = fullNumber
          .substring(1)
          .split('')
          .indexWhere((c) => int.tryParse(c) == null);
      if (splitIndex != -1) {
        splitIndex += 1;
        _selectedCountryCode = fullNumber.substring(0, splitIndex);
        _phoneController.text = fullNumber.substring(splitIndex);
        _initialCountrySelection = 'CA';
      } else {
        _selectedCountryCode = '+1';
        _phoneController.text = fullNumber.substring(1);
        _initialCountrySelection = 'CA';
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        final user = context.read<AuthProvider>().user!;
        _updateFormValues(user);
        _selectedImage = null;
        _formKey.currentState?.reset();
      }
    });
  }

  Future<void> _saveProfile({required bool ignoreEmail}) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullPhoneNumber =
        '$_selectedCountryCode${_phoneController.text.trim()}';

    final updates = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phoneNumber': fullPhoneNumber,
    };

    final imageFile =
        _selectedImage != null ? File(_selectedImage!.path) : null;

    final userProvider = context.read<UserProvider>();
    await userProvider.updateUserProfile(updates, profileImage: imageFile);

    if (!mounted) return;

    if (userProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context).userInfo_errorUpdatingProfile}: ${userProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await userProvider.getUserProfile();

    if (!mounted) return;

    setState(() {
      _isEditing = false;
      _selectedImage = null;

      final updatedUser = context.read<AuthProvider>().user;
      if (updatedUser != null) {
        _updateFormValues(updatedUser);
      }
    });

    _formKey.currentState?.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).userInfo_profileUpdatedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).googleRegister_validationFirstNameRequired;
    }
    if (value.trim().length < 2) {
      return S.of(context).googleRegister_requiredField;
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).googleRegister_validationLastNameRequired;
    }
    if (value.trim().length < 2) {
      return S.of(context).googleRegister_requiredField;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).googleRegister_validationPhoneRequired;
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 9 || digitsOnly.length > 10) {
      return S.of(context).userInfo_phoneNumberTooLong;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? S.of(context).userInfo_editProfile
              : S.of(context).userInfo_profile,
        ),
        actions: [
          if (!_isEditing) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => userProvider.getUserProfile(),
              ),
            ),
          ],
        ],
        leading:
            _isEditing
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _toggleEditing(),
                )
                : null,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child:
            user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userProvider.isLoading)
                          const LinearProgressIndicator(),

                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _isEditing ? _pickImage : null,
                                child: _ProfileAvatar(
                                  user: user,
                                  selectedImage: _selectedImage,
                                  isEditing: _isEditing,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                '@${user.firstName.toLowerCase()}${user.lastName.toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        _ProfileField(
                          label: S.of(context).userInfo_firstName,
                          controller: _firstNameController,
                          isEditing: _isEditing,

                          validator: _isEditing ? _validateFirstName : null,
                        ),

                        _ProfileField(
                          label: S.of(context).userInfo_lastName,
                          controller: _lastNameController,
                          isEditing: _isEditing,

                          validator: _isEditing ? _validateLastName : null,
                        ),

                        _ProfileField(
                          label: S.of(context).userInfo_email,
                          controller: _emailController,
                          isEditing: _isEditing,
                          isDisabled: true,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        _PhoneProfileField(
                          label: S.of(context).userInfo_phoneNumber,
                          controller: _phoneController,
                          countryCode: _selectedCountryCode,
                          initialSelection: _initialCountrySelection,
                          isEditing: _isEditing,
                          onCountryChanged: (newCode) {
                            setState(() {
                              _selectedCountryCode = newCode;
                            });
                          },

                          validator: _isEditing ? _validatePhone : null,
                        ),

                        const SizedBox(height: 24),

                        if (!_isEditing)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 20),
                            label: Text(S.of(context).userInfo_editProfile),
                            onPressed: _toggleEditing,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          )
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed:
                                    () => _saveProfile(ignoreEmail: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  S.of(context).userInfo_save,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _toggleEditing,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  S.of(context).userInfo_cancel,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}

class _PhoneProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String countryCode;
  final String initialSelection;
  final bool isEditing;
  final ValueChanged<String> onCountryChanged;

  final String? Function(String?)? validator;

  const _PhoneProfileField({
    required this.label,
    required this.controller,
    required this.countryCode,
    required this.initialSelection,
    required this.isEditing,
    required this.onCountryChanged,

    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          isEditing
              ? _buildEditMode(context)
              : Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                child: Text(
                  controller.text.isEmpty
                      ? 'N/A'
                      : '$countryCode${controller.text}',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        controller.text.isEmpty
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : null,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final theme = Theme.of(context);

    return _ValidatedPhoneField(
      controller: controller,
      countryCode: countryCode,
      initialSelection: initialSelection,
      onCountryChanged: onCountryChanged,
      validator: validator,
      theme: theme,
    );
  }
}

class _ValidatedField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDisabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ThemeData theme;

  const _ValidatedField({
    required this.controller,
    required this.isDisabled,
    this.keyboardType,
    this.validator,
    required this.theme,
  });

  @override
  State<_ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<_ValidatedField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      if (mounted) {
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError
                      ? widget.theme.colorScheme.error
                      : widget.theme.dividerColor.withOpacity(0.2),
              width: hasError ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    hasError
                        ? widget.theme.colorScheme.error.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            enabled: !widget.isDisabled,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            style: const TextStyle(fontSize: 16),
            onChanged: (_) => _validate(),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: widget.theme.colorScheme.error,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}

class _ValidatedPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String countryCode;
  final String initialSelection;
  final ValueChanged<String> onCountryChanged;
  final String? Function(String?)? validator;
  final ThemeData theme;

  const _ValidatedPhoneField({
    required this.controller,
    required this.countryCode,
    required this.initialSelection,
    required this.onCountryChanged,
    this.validator,
    required this.theme,
  });

  @override
  State<_ValidatedPhoneField> createState() => _ValidatedPhoneFieldState();
}

class _ValidatedPhoneFieldState extends State<_ValidatedPhoneField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      if (mounted) {
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError
                      ? widget.theme.colorScheme.error
                      : widget.theme.dividerColor.withOpacity(0.2),
              width: hasError ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    hasError
                        ? widget.theme.colorScheme.error.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CountryCodePicker(
                onChanged: (country) {
                  widget.onCountryChanged(country.dialCode ?? '+1');
                },
                initialSelection: widget.initialSelection,
                favorite: const ['+213', 'DZ', '+1', 'CA'],
                textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Container(
                width: 1,
                height: 32,
                color: widget.theme.dividerColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 16),
                  onChanged: (_) => _validate(),
                  decoration: InputDecoration(
                    hintText: '(416) 123-4567',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: widget.theme.colorScheme.error,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final User user;
  final XFile? selectedImage;
  final bool isEditing;

  const _ProfileAvatar({
    required this.user,
    this.selectedImage,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (selectedImage != null) {
      imageWidget = Image.file(
        File(selectedImage!.path),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } else {
      imageWidget = NetworkImageWidget(
        imageUrl: user.profileImageUrl ?? '',
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorWidget: Image.asset(
          'assets/images/default_profile.png',
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageWidget,
            if (isEditing)
              IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.black45),
                  child: const Icon(Icons.edit, size: 24, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool isEditing;
  final bool isDisabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    this.isDisabled = false,
    this.value,
    this.controller,
    required this.isEditing,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          isEditing
              ? _ValidatedField(
                controller: controller!,
                isDisabled: isDisabled,
                keyboardType: keyboardType,
                validator: validator,
                theme: theme,
              )
              : Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                child: Text(
                  value ?? controller?.text ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _BioField extends StatefulWidget {
  final TextEditingController controller;
  final bool isEditing;

  const _BioField({required this.controller, required this.isEditing});

  @override
  State<_BioField> createState() => _BioFieldState();
}

class _BioFieldState extends State<_BioField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              S.of(context).userInfo_bio,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          widget.isEditing
              ? Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  maxLines: 3,
                  maxLength: 100,
                  onChanged: (value) => setState(() {}),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    counterText: '${widget.controller.text.length} / 100',
                    counterStyle: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              )
              : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                child: Text(
                  widget.controller.text.isEmpty
                      ? 'No bio available'
                      : widget.controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        widget.controller.text.isEmpty
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : null,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
