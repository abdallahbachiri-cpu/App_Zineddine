import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';

import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:cuisinous/widgets/terms_flow_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as devtools;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptedConditions = false;

  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    devtools.log('[RegisterScreen] Initialized');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    devtools.log('[RegisterScreen] Disposed');
    _authProvider.removeListener(_handleAuthChange);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthChange() {
    if (!mounted) return;

    if (_authProvider.error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: .8,
            child: SvgPicture.asset(
              'assets/images/bg_design.svg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: true,
            top: false,
            child: LayoutBuilder(
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
                            (context, authProvider, _) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 20),
                                _buildForm(authProvider),
                                const SizedBox(height: 20),
                                _buildFooter(authProvider),
                              ],
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/Logo.png', width: 100),
        const SizedBox(height: 8),
        Text(
          S.of(context).register_slogan,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  controller: _firstNameController,
                  labelText: S.of(context).register_firstNameLabel,
                  hintText: S.of(context).register_firstNameHint,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).register_validationFirstNameRequired;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomInputField(
                  controller: _lastNameController,
                  labelText: S.of(context).register_lastNameLabel,
                  hintText: S.of(context).register_lastNameHint,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).register_validationLastNameRequired;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomInputField(
            hintText: S.of(context).register_emailHint,
            labelText: S.of(context).register_emailLabel,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).register_validationEmailRequired;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return S.of(context).register_validationEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          CustomInputField(
            hintText: S.of(context).register_passwordHint,
            labelText: S.of(context).register_passwordLabel,
            controller: _passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).register_validationPasswordRequired;
              }
              if (value.length < 8) {
                return S.of(context).register_validationPasswordLength;
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  authProvider.isLoading
                      ? null
                      : () async {
                        if (_formKey.currentState!.validate()) {
                          if (!_acceptedConditions) {
                            final bool? agreed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const TermsFlowDialog(),
                            );

                            if (agreed != true) return;

                            if (!mounted) return;
                            setState(() {
                              _acceptedConditions = true;
                            });
                          }

                          authProvider.clearError();
                          await authProvider.register(
                            email: _emailController.text,
                            password: _passwordController.text,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                          );

                          if (authProvider.user != null) {
                            if (!mounted) return;
                            setState(() {
                              _acceptedConditions = false;
                            });
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  authProvider.isLoading
                      ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                      : Text(
                        S.of(context).register_button,
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
    );
  }

  Widget _buildFooter(AuthProvider authProvider) {
    return Column(
      children: [
        TextButton(
          onPressed: () => {authProvider.clearError(), Navigator.pop(context)},
          child: Text(
            S.of(context).register_loginPrompt,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
