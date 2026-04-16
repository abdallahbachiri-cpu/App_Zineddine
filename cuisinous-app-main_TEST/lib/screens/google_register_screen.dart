import 'package:country_code_picker/country_code_picker.dart';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GoogleRegisterScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const GoogleRegisterScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  State<GoogleRegisterScreen> createState() => _GoogleRegisterScreenState();
}

class _GoogleRegisterScreenState extends State<GoogleRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+1';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      await authProvider.updateUserType(
        null,
        '$_selectedCountryCode${_phoneController.text.trim()}',
        widget.email,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        null,
      );

      if (!mounted) return;

      if (authProvider.error != null) {
        setState(() => _error = authProvider.error);
      }
    } catch (e) {
      setState(
        () =>
            _error =
                authProvider.error ??
                S.of(context).googleRegister_operationFailed,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      return S.of(context).googleRegister_validationPhoneInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: .8,
              child: SvgPicture.asset(
                'assets/images/bg_design.svg',
                fit: BoxFit.fitWidth,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<AuthProvider>(
                        builder:
                            (context, authProvider, _) =>
                                _buildContent(authProvider),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/Logo.png', width: 100),
        const SizedBox(height: 8),
        Text(
          S.of(context).googleRegister_slogan,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _firstNameController,
                      labelText: S.of(context).googleRegister_firstNameLabel,
                      hintText: S.of(context).googleRegister_firstNameHint,
                      validator: _validateFirstName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomInputField(
                      controller: _lastNameController,
                      labelText: S.of(context).googleRegister_lastNameLabel,
                      hintText: S.of(context).googleRegister_lastNameHint,
                      validator: _validateLastName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _emailController,
                labelText: S.of(context).googleRegister_emailLabel,
                hintText: S.of(context).googleRegister_emailHint,
                isEnabled: false,
              ),
              const SizedBox(height: 16),
              _PhoneInputField(
                controller: _phoneController,
                selectedCountryCode: _selectedCountryCode,
                onCountryCodeChanged: (countryCode) {
                  setState(() {
                    _selectedCountryCode = countryCode;
                  });
                },
                validator: _validatePhone,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || authProvider.isLoading
                          ? null
                          : () => _submit(authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading || authProvider.isLoading
                          ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                          : Text(
                            S.of(context).googleRegister_button,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final String? Function(String?)? validator;

  const _PhoneInputField({
    required this.controller,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.validator,
  });

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
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

  String _getCountryFromDialCode(String dialCode) {
    final dialCodeToCountry = {'+1': 'CA'};
    return dialCodeToCountry[dialCode] ?? 'CA';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError
                      ? theme.colorScheme.error
                      : theme.dividerColor.withOpacity(0.2),
              width: hasError ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    hasError
                        ? theme.colorScheme.error.withOpacity(0.1)
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
                  widget.onCountryCodeChanged(country.dialCode ?? '+1');
                },
                initialSelection: _getCountryFromDialCode(
                  widget.selectedCountryCode,
                ),
                favorite: const ['+1', 'CA'],
                textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Container(
                width: 1,
                height: 32,
                color: theme.dividerColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 16),
                  onChanged: (_) => _validate(),
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    if (mounted) {
                      setState(() {
                        _errorText = error;
                      });
                    }
                    return error;
                  },
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
                color: theme.colorScheme.error,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
