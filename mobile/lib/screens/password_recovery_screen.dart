import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_consts.dart';
import '../core/routes/app_router.dart';
import '../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).passwordRecoveryEmailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return S.of(context).passwordRecoveryEmailInvalid;
    }
    return null;
  }

  Future<void> _submitPasswordReset(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _inlineError = null;
      _isSubmitting = true;
    });

    try {
      await authProvider.requestPasswordReset(_emailController.text.trim());
      if (mounted) {
        if (authProvider.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).passwordRecoverySuccessMessage),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _inlineError =
                authProvider.error ??
                S.of(context).passwordRecoveryErrorMessage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inlineError = S.of(context).passwordRecoveryErrorMessage;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Opacity(
              opacity: .8,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/bg_design_1.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 200),
                  Text(
                    S.of(context).passwordRecoveryTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).passwordRecoverySubtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: CustomInputField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hintText: S.of(context).passwordRecoveryEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      onChanged: (value) {
                        setState(() {
                          _inlineError = null;
                        });
                      },
                    ),
                  ),
                  if (_inlineError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 20.0,
                      ),
                      child: Text(
                        _inlineError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: CustomButton(
                      type: ButtonType.elevated,
                      size: ButtonSize.medium,
                      shape: ButtonShape.rounded,
                      borderRadius: 10,
                      text: S.of(context).passwordRecoveryButton,
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => _submitPasswordReset(authProvider),
                      isLoading: _isSubmitting,
                      backgroundColor: const Color(0xFFDC1D27),
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
