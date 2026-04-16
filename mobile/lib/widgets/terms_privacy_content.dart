import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';

class TermsContent extends StatelessWidget {
  final ScrollController? scrollController;

  const TermsContent({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).termsAndConditions_intro,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          PolicySection(
            title: S.of(context).termsAndConditions_section1Title,
            body: S.of(context).termsAndConditions_section1Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section2Title,
            body: S.of(context).termsAndConditions_section2Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section3Title,
            body: S.of(context).termsAndConditions_section3Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section4Title,
            body: S.of(context).termsAndConditions_section4Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section5Title,
            body: S.of(context).termsAndConditions_section5Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section6Title,
            body: S.of(context).termsAndConditions_section6Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section7Title,
            body: S.of(context).termsAndConditions_section7Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section8Title,
            body: S.of(context).termsAndConditions_section8Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section9Title,
            body: S.of(context).termsAndConditions_section9Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section10Title,
            body: S.of(context).termsAndConditions_section10Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section11Title,
            body: S.of(context).termsAndConditions_section11Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section12Title,
            body: S.of(context).termsAndConditions_section12Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section13Title,
            body: S.of(context).termsAndConditions_section13Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section14Title,
            body: S.of(context).termsAndConditions_section14Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section15Title,
            body: S.of(context).termsAndConditions_section15Body,
          ),

          PolicySection(
            title: S.of(context).termsAndConditions_section16Title,
            body: S.of(context).termsAndConditions_section16Body,
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class PrivacyContent extends StatelessWidget {
  final ScrollController? scrollController;

  const PrivacyContent({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).privacyPolicy_intro,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          PolicySection(
            title: S.of(context).privacyPolicy_section1Title,
            body: S.of(context).privacyPolicy_section1Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section2Title,
            body: S.of(context).privacyPolicy_section2Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section3Title,
            body: S.of(context).privacyPolicy_section3Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section4Title,
            body: S.of(context).privacyPolicy_section4Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section5Title,
            body: S.of(context).privacyPolicy_section5Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section6Title,
            body: S.of(context).privacyPolicy_section6Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section7Title,
            body: S.of(context).privacyPolicy_section7Body,
          ),

          PolicySection(
            title: S.of(context).privacyPolicy_section8Title,
            body: S.of(context).privacyPolicy_section8Body,
          ),

          const SizedBox(height: 10),

          Text(
            S.of(context).privacyPolicy_conclusion,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const PolicySection({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
      ],
    );
  }
}
