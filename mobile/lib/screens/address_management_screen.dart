import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/data/models/picked_location.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/buyer_location_provider.dart';
import 'package:cuisinous/widgets/address_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerLocationsProvider>().fetchLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).addressManagement_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => Navigator.pushNamed(context, AppRouter.createAddress),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer<BuyerLocationsProvider>(
          builder: (context, provider, _) {
            if (provider.error != null && provider.locations.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                provider.clearError();
              });
            }

            if (provider.isLoading && provider.locations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.locations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchLocations(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.locations.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchLocations(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    S.of(context).addressManagement_yourAddresses,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...provider.locations.map(
                    (location) => AddressCard(
                      location: location,
                      onEdit: () => _navigateToEditScreen(context, location),
                      onDelete:
                          () => _handleDeleteLocation(
                            context,
                            provider,
                            location.id!,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(S.of(context).addressManagement_emptyText),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRouter.createAddress),
            child: Text(S.of(context).addressManagement_emptyButton),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, PickedLocation location) {
    Navigator.pushNamed(
      context,
      AppRouter.editAddress,
      arguments: location.id!,
    );
  }

  Future<void> _handleDeleteLocation(
    BuildContext context,
    BuyerLocationsProvider provider,
    String locationId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).addressManagement_deleteTitle),
            content: Text(S.of(context).addressManagement_deleteContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(S.of(context).addressManagement_deleteCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  S.of(context).addressManagement_deleteConfirm,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.deleteLocation(locationId);

      if (mounted) {
        if (provider.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}
