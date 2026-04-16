import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/screens/store_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStore();
    });
  }

  Future<void> _loadStore() async {
    final storeProvider = context.read<FoodStoreProvider>();
    try {
      await storeProvider.getMyStore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).storeHome_errorLoadingStore),
            action: SnackBarAction(
              label: S.of(context).storeHome_retry,
              onPressed: _loadStore,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(S.of(context).storeHome_title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStore),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<FoodStoreProvider>(
          builder: (context, storeProvider, child) {
            return _buildStoreContent(storeProvider);
          },
        ),
      ),
      floatingActionButton: Consumer<FoodStoreProvider>(
        builder: (context, storeProvider, child) {
          return storeProvider.isLoading == false &&
                  storeProvider.currentStore == null
              ? FloatingActionButton(
                heroTag: 'add_store',
                onPressed:
                    () => Navigator.pushNamed(context, AppRouter.createStore),
                child: const Icon(Icons.add_business),
              )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStoreContent(FoodStoreProvider storeProvider) {
    if (storeProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(S.of(context).storeHome_loadingStoreInformation),
          ],
        ),
      );
    }

    if (storeProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              storeProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStore,
              child: Text(S.of(context).storeHome_retry),
            ),
          ],
        ),
      );
    }

    if (storeProvider.currentStore == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).storeHome_noStoreFound,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => Navigator.pushNamed(context, AppRouter.createStore),
              child: Text(S.of(context).storeHome_createStore),
            ),
          ],
        ),
      );
    }

    return StoreProfileScreen(store: storeProvider.currentStore!);
  }
}
