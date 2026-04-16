import 'dart:developer' as devtools;

import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/screens/privacy_policy_screen.dart';
import 'package:cuisinous/screens/terms_and_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AuthOptionsScreen extends StatelessWidget {
  final VoidCallback? onGoogleSelected;
  final VoidCallback? onAppleSelected;

  const AuthOptionsScreen({
    super.key,
    this.onGoogleSelected,
    this.onAppleSelected,
  });

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
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 64),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final isLoading = authProvider.isLoading;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      devtools.log(
                                        '[AuthOptionsScreen] Email selected',
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.login,
                                      );
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              S.of(context).login_continueWithEmail,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Apple button — must appear above Google (Apple guideline)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: isLoading ? null : onAppleSelected,
                            icon: const Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 22,
                            ),
                            label:
                                isLoading
                                    ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      S.of(context).login_apple,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: isLoading ? null : onGoogleSelected,
                            icon: const Icon(Icons.login, color: Colors.black),
                            label:
                                isLoading
                                    ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    )
                                    : Text(
                                      S.of(context).login_google,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            S.of(context).login_googleDisclaimer,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 16.0,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const TermsAndConditionsScreen(),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PrivacyPolicyScreen(),
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
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
