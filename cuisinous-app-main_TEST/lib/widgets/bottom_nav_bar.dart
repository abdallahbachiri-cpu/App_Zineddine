import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> navigationItems;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, BuyerOrderProvider>(
      builder: (context, cartProvider, orderProvider, _) {
        final cartItemCount = cartProvider.cart?.dishes.length ?? 0;
        final pendingPaymentOrders =
            orderProvider.orders
                .where(
                  (order) =>
                      order.paymentStatus == 'pending' ||
                      order.paymentStatus == 'failed',
                )
                .length;

        return BottomNavigationBar(
          selectedItemColor: const Color(0xFFDC1D27),
          unselectedItemColor: Colors.grey.shade500,
          currentIndex: currentIndex,
          onTap: onTap,
          items:
              navigationItems.map((item) {
                Widget? badge;
                if (item == NavigationItem.cart && cartItemCount > 0) {
                  badge = Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (item == NavigationItem.orders &&
                    pendingPaymentOrders > 0) {
                  badge = Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingPaymentOrders.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return BottomNavigationBarItem(
                  backgroundColor: AppConsts.backgroundColor,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(_getNavigationIcon(item), size: 28),
                      if (badge != null)
                        Positioned(right: -10, top: -5, child: badge),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildIconWithIndicator(_getNavigationIcon(item)),
                      if (badge != null)
                        Positioned(right: -10, top: -5, child: badge),
                    ],
                  ),
                  label: _getTranslatedLabel(S.of(context), item).toUpperCase(),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildIconWithIndicator(IconData icon) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 28),
          Positioned(
            top: -5,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFDC1D27),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNavigationIcon(NavigationItem item) {
    switch (item) {
      case NavigationItem.home:
        return Icons.home;
      case NavigationItem.explore:
        return Icons.search;
      case NavigationItem.orders:
        return Icons.list_alt;
      case NavigationItem.menu:
        return Icons.menu_book;
      case NavigationItem.stats:
        return Icons.bar_chart;
      case NavigationItem.settings:
        return Icons.settings;
      case NavigationItem.cart:
        return Icons.shopping_cart;
    }
  }

  String _getTranslatedLabel(S localizations, NavigationItem item) {
    switch (item) {
      case NavigationItem.home:
        return localizations.homeLabel;
      case NavigationItem.explore:
        return localizations.exploreLabel;
      case NavigationItem.orders:
        return localizations.ordersLabel;
      case NavigationItem.menu:
        return localizations.menuLabel;
      case NavigationItem.stats:
        return localizations.statsLabel;
      case NavigationItem.settings:
        return localizations.settingsLabel;
      case NavigationItem.cart:
        return localizations.cart_label;
    }
  }
}
