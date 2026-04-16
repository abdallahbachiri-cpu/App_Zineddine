import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/address.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreProfileScreen extends StatefulWidget {
  final FoodStore store;

  const StoreProfileScreen({super.key, required this.store});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await context.read<FoodStoreProvider>().getMyStore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).storeProfile_errorLoadingStore)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FoodStore currentStore =
        context.watch<FoodStoreProvider>().currentStore ?? widget.store;
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColorLight,
                    ),
                    child: ClipOval(
                      child: NetworkImageWidget(
                        imageUrl: currentStore.profileImageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorWidget: Icon(
                          Icons.store,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionCard(
                  context,
                  title: S.of(context).storeProfile_storeName,
                  content: Text(
                    currentStore.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (currentStore.description != null &&
                    currentStore.description!.isNotEmpty)
                  _buildSectionCard(
                    context,
                    title: S.of(context).storeProfile_description,
                    content: Text(
                      currentStore.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                if (currentStore.address != null)
                  _buildSectionCard(
                    context,
                    title: S.of(context).storeProfile_address,
                    content: _buildAddressDetails(
                      context,
                      currentStore.address!,
                    ),
                  ),
                const SizedBox(height: 16),
                _buildActionButtons(context, currentStore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),

      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetails(BuildContext context, Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.street != null && address.street!.isNotEmpty)
          Text(address.street!, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          [
            address.city,
            address.state,
            address.zipCode,
          ].where((s) => s?.isNotEmpty ?? false).join(', '),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (address.country != null && address.country!.isNotEmpty)
          Text(address.country!, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text(
          S
              .of(context)
              .storeProfile_coordinates(
                address.latitude.toStringAsFixed(4),
                address.longitude.toStringAsFixed(4),
              ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, FoodStore store) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: Text(S.of(context).storeProfile_editStore),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.black, width: 1.5),

              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  AppRouter.editStore,
                  arguments: store,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 20),
            label: Text(S.of(context).storeProfile_deleteStore),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.red, width: 1.5),
              foregroundColor: Colors.red,
            ),
            onPressed: () => _confirmDeleteStore(context),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteStore(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              S.of(context).storeProfile_deleteStore,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(S.of(context).storeProfile_deleteStoreContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).storeProfile_cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<FoodStoreProvider>().deleteStore();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.login,
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  S.of(context).storeProfile_deleteStore,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
