import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorAgreementScreen extends StatefulWidget {
  const VendorAgreementScreen({super.key});

  @override
  State<VendorAgreementScreen> createState() => _VendorAgreementScreenState();
}

class _VendorAgreementScreenState extends State<VendorAgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasReachedBottom &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 20) {
      setState(() {
        _hasReachedBottom = true;
      });
    }
  }

  void _handleAgree() {
    final foodStoreProvider = Provider.of<FoodStoreProvider>(
      context,
      listen: false,
    );
    foodStoreProvider.acceptVendorAgreement();
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        title: Text(S.of(context).vendorAgreement_title),
        backgroundColor: AppConsts.backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).vendorAgreement_intro,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: S.of(context).vendorAgreement_preambleTitle,
                      body: S.of(context).vendorAgreement_preambleBody,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section1Title,
                      body: S.of(context).vendorAgreement_section1Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section2Title,
                      body: S.of(context).vendorAgreement_section2Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section3Title,
                      body: S.of(context).vendorAgreement_section3Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section4Title,
                      body: S.of(context).vendorAgreement_section4Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section5Title,
                      body: S.of(context).vendorAgreement_section5Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section6Title,
                      body: S.of(context).vendorAgreement_section6Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section7Title,
                      body: S.of(context).vendorAgreement_section7Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section8Title,
                      body: S.of(context).vendorAgreement_section8Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section9Title,
                      body: S.of(context).vendorAgreement_section9Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section10Title,
                      body: S.of(context).vendorAgreement_section10Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section11Title,
                      body: S.of(context).vendorAgreement_section11Body,
                    ),
                    _buildSection(
                      title: S.of(context).vendorAgreement_section12Title,
                      body: S.of(context).vendorAgreement_section12Body,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasReachedBottom ? _handleAgree : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConsts.secondaryAccentColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    S.of(context).vendorAgreement_agreeAndContinue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
