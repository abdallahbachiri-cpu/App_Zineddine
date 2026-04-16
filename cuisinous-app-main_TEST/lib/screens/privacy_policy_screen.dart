import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/widgets/terms_privacy_content.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        title: Text(S.of(context).privacyPolicy_title),
        backgroundColor: AppConsts.backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(bottom: true, top: false, child: const PrivacyContent()),
    );
  }
}
