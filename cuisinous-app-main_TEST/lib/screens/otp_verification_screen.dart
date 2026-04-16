import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_consts.dart';
import '../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class OptVerificationScreen extends StatefulWidget {
  const OptVerificationScreen({super.key});

  @override
  State<OptVerificationScreen> createState() => _OptVerificationScreenState();
}

class _OptVerificationScreenState extends State<OptVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isSubmitting = false;
  bool _isResending = false;
  String? _inlineError;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String get _otpCode => _otpController.text;

  Future<void> _submitOtp(AuthProvider authProvider) async {
    _otpFocusNode.unfocus();

    if (_isSubmitting || _otpCode.length != 6) return;

    setState(() {
      _inlineError = null;
      _isSubmitting = true;
    });

    final email = authProvider.user?.email;
    if (email == null) {
      setState(() {
        _inlineError = S.of(context).optVerification_validationRequired;
        _isSubmitting = false;
      });
      return;
    }

    try {
      await authProvider.emailConfirmationAsync(email, _otpCode);
      if (mounted) {
        if (authProvider.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).optVerification_success),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _inlineError =
                authProvider.error ?? S.of(context).optVerification_error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inlineError = S.of(context).optVerification_error;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resendCode(AuthProvider authProvider) async {
    setState(() => _isResending = true);
    final email = authProvider.user?.email;
    if (email == null) {
      setState(() => _isResending = false);
      return;
    }
    try {
      await authProvider.resendEmailConfirmationCode(email);
      if (mounted) {
        if (authProvider.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${S.of(context).optVerification_resend} ${S.of(context).optVerification_success}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? S.of(context).optVerification_error,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).optVerification_error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,

      resizeToAvoidBottomInset: false,
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
                  const SizedBox(height: 165),
                  Text(
                    S.of(context).optVerification_title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).optVerification_subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 36),

                  GestureDetector(
                    onTap: () {
                      if (!_otpFocusNode.hasFocus) {
                        _otpFocusNode.requestFocus();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return _buildOtpDisplayBox(index);
                          }),
                        ),

                        Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            maxLength: 6,
                            keyboardType: TextInputType.text,

                            autofocus: false,
                            enableInteractiveSelection: true,
                            showCursor: false,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {});
                              if (value.length == 6) {
                                _submitOtp(authProvider);
                              }
                            },
                          ),
                        ),
                      ],
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
                  const SizedBox(height: 12),
                  Center(
                    child: CustomButton(
                      type: ButtonType.text,
                      size: ButtonSize.medium,
                      shape: ButtonShape.rounded,
                      text: S.of(context).optVerification_resend,
                      onPressed:
                          _isResending
                              ? () {}
                              : () => _resendCode(authProvider),
                      isLoading: _isResending,
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => authProvider.logout(),
                      icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                      label: Text(
                        S.of(context).logout,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom > 0
                                ? 20
                                : 0,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC1D27),
                          padding: const EdgeInsets.all(22),
                          shape: const CircleBorder(),
                        ),
                        onPressed:
                            _isSubmitting
                                ? null
                                : () => _submitOtp(authProvider),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : SvgPicture.asset(
                                  'assets/icons/arrow_icon.svg',
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  height: 18,
                                  width: 18,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpDisplayBox(int index) {
    final code = _otpController.text;
    final char = code.length > index ? code[index] : '';
    final isActive = code.length == index;

    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              isActive && _otpFocusNode.hasFocus
                  ? Border.all(color: const Color(0xFFDC1D27), width: 1.5)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(80),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            char,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
