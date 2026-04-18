import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/core/ui/auth_status.dart';

import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/screens/privacy_policy_screen.dart';
import 'package:cuisinous/screens/terms_and_conditions_screen.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    devtools.log('[LoginScreen] Initialized');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthChange);
  }

  @override
  void dispose() {
    devtools.log('[LoginScreen] Disposed');
    _authProvider.removeListener(_handleAuthChange);
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
                                _buildForm(authProvider),
                                const SizedBox(height: 20),
                                _buildFooter(),
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

  Widget _buildForm(AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/Logo.png', width: 100),
        const SizedBox(height: 8),
        Text(
          S.of(context).login_slogan,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        CustomInputField(
          hintText: S.of(context).login_emailHint,
          labelText: S.of(context).login_emailLabel,
          controller: _emailController,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: S.of(context).login_passwordLabel,
            hintText: S.of(context).login_passwordHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _authProvider.clearError();
              Navigator.pushNamed(context, AppRouter.passwordRecovery);
            },
            child: Text(
              S.of(context).login_forgotPassword,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                authProvider.isLoading
                    ? null
                    : () async {
                      try {
                        authProvider.clearError();
                        await authProvider.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (authProvider.authStatus ==
                            AuthStatus.authenticated) {
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      } catch (_) {}
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                      S.of(context).login_button,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            _authProvider.clearError();
            devtools.log('[LoginScreen] Register button clicked');
            Navigator.pushNamed(context, AppRouter.register);
          },
          child: Text(
            S.of(context).login_registerPrompt,
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

  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      children: [
        TextButton(
          onPressed: () {
            _authProvider.clearError();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsAndConditionsScreen(),
              ),
            );
          },
          child: Text(
            S.of(context).login_termsAndConditions,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            _authProvider.clearError();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
          child: Text(
            S.of(context).login_privacyPolicy,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
