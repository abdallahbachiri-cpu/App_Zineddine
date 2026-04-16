import 'dart:developer' as devtools;

import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/screens/main_screen.dart';
import 'package:cuisinous/screens/store_form_screen.dart';
import 'package:cuisinous/screens/vendor_agreement_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StoreRequestStatus { pending, rejected, approved }

class StoreWrapper extends StatefulWidget {
  const StoreWrapper({super.key});

  @override
  State<StoreWrapper> createState() => _StoreWrapperState();
}

class _StoreWrapperState extends State<StoreWrapper> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    devtools.log('[StoreWrapper] Initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    devtools.log('[StoreWrapper] Disposed');
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    try {
      final foodStore = context.read<FoodStoreProvider>();

      await foodStore.getMyStore();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;

      devtools.log('[StoreWrapper] Initialization error: $e');
      setState(() {
        _error = S.of(context).storeNavigation_operationFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeApp,
                child: Text(S.of(context).storeNavigation_retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(S.of(context).storeNavigation_initializing),
            ],
          ),
        ),
      );
    }

    return Consumer<FoodStoreProvider>(
      builder: (context, foodStore, _) {
        if (foodStore.currentStore == null) {
          devtools.log(
            '[StoreWrapper] No store found, showing StoreFormScreen',
          );
          return const StoreFormScreen();
        }

        if (!foodStore.currentStore!.vendorAgreementAccepted) {
          devtools.log(
            '[StoreWrapper] Vendor agreement not accepted, showing VendorAgreementScreen',
          );
          return const VendorAgreementScreen();
        }

        devtools.log('[StoreWrapper] Store approved, showing MainScreen');
        return const MainScreen();
      },
    );
  }
}
