import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/core/utils/currency_formatter.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/providers/navigation_provider.dart';
import 'package:cuisinous/providers/statistics_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'dart:developer' as devtools;

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final userProvider = context.read<AuthProvider>();
    final foodStoreProvider = context.read<FoodStoreProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    try {
      await userProvider.fetchUserProfile();

      if (userProvider.type == 'seller') {
        await foodStoreProvider.getMyStore();

        if (foodStoreProvider.currentStore != null) {
          await statsProvider.fetchSellerStats();
        }
      }
    } catch (e, s) {
      devtools.log('Initialization error', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Text(""),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              _buildUserGreeting(),
              const SizedBox(height: 24),
              _buildStoreStatusSection(),

              const SizedBox(height: 32),
              _buildStatsSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading && userProvider.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${S.of(context).sellerHome_welcome}, ${userProvider.user?.firstName ?? S.of(context).sellerHome_sellerFallback}!',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProvider.user?.email ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.notificationSeller);
              },
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStoreStatusSection() {
    return Consumer<FoodStoreProvider>(
      builder: (context, foodStoreProvider, _) {
        if (foodStoreProvider.isLoading &&
            foodStoreProvider.currentStore == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (foodStoreProvider.error != null &&
            foodStoreProvider.currentStore == null) {
          return _buildErrorSection(foodStoreProvider.error!);
        }

        if (foodStoreProvider.currentStore == null) {
          return _buildNoStoreSection();
        }

        final store = foodStoreProvider.currentStore!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    AppRouter.editStore,
                    arguments: store,
                  ),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: ClipOval(
                        child: NetworkImageWidget(
                          imageUrl: store.profileImageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: const Icon(
                            Icons.store,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  store.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (store.description?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            Text(
                              store.description!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (store.address?.street?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    store.address!.street!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationStatus() {
    return Consumer<FoodStoreProvider>(
      builder: (context, foodStoreProvider, _) {
        final request = foodStoreProvider.storeRequest;

        if (request == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: _getStatusColor(request.status),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(request.status).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(request.status), color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${S.of(context).sellerHome_verificationStatus} ${_getTranslatedStatus(request.status).toUpperCase()}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (request.adminComment?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${S.of(context).sellerHome_adminFeedback}: ${request.adminComment}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary() {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, _) {
        final stats = statsProvider.sellerStats;

        if (statsProvider.isLoading && stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stats == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildStatCard(
              context,
              S.of(context).sellerHome_pendingOrders,
              stats.totalPendingOrders.toString(),
              Icons.pending_actions_outlined,
              const Color(0xFFFFB74D),
              onTap: () {
                context.read<NavigationProvider>().setNavigationItem(
                  NavigationItem.orders,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              S.of(context).sellerHome_totalRevenue,
              CurrencyFormatter.format(stats.totalRevenue),
              Icons.attach_money,
              const Color(0xFF4CAF50),
              onTap: () {
                context.read<NavigationProvider>().setNavigationItem(
                  NavigationItem.stats,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoStoreSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              S.of(context).sellerHome_noStore,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushNamed(context, AppRouter.createStore),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(S.of(context).sellerHome_createStore),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFB74D);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'rejected':
        return Icons.warning_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getTranslatedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).sellerHome_statusApproved;
      case 'pending':
        return S.of(context).sellerHome_statusPending;
      case 'rejected':
        return S.of(context).sellerHome_statusRejected;
      default:
        return status;
    }
  }
}
