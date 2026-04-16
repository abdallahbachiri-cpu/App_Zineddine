import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/core/enums/user_type.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/navigation_provider.dart';
import 'package:cuisinous/screens/buyer_orders_screen.dart';
import 'package:cuisinous/screens/cart_screen.dart';
import 'package:cuisinous/screens/dish_management_screen.dart';
import 'package:cuisinous/screens/food_store_map_screen.dart';
import 'package:cuisinous/screens/home_screen.dart';
import 'package:cuisinous/screens/seller_home_screen.dart';
import 'package:cuisinous/screens/seller_order_management_screen.dart';
import 'package:cuisinous/screens/seller_stats_screen.dart';
import 'package:cuisinous/screens/settings_screen.dart';

import 'package:cuisinous/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/app_service.dart';

class MainScreen extends StatefulWidget {
  final NavigationItem? initialNavigationItem;

  const MainScreen({super.key, this.initialNavigationItem});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialNavigationItem != null) {
        context.read<NavigationProvider>().setNavigationItem(
          widget.initialNavigationItem!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NavigationProvider>(
      builder: (context, authProvider, navProvider, _) {
        final userType = authProvider.currentUserType;
        final selectedIndex = navProvider.getSelectedIndex(userType);
        final navigationItems = navProvider.getNavigationItems(userType);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: selectedIndex,
            children:
                navigationItems
                    .map((item) => _mapItemToScreen(item, userType))
                    .toList(),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: selectedIndex,
            onTap: (index) => navProvider.setSelectedIndex(index, userType),
            navigationItems: navigationItems,
          ),
        );
      },
    );
  }

  Widget _mapItemToScreen(NavigationItem item, String? userType) {
    switch (item) {
      case NavigationItem.home:
        return userType == UserType.seller.name
            ? const SellerHomeScreen()
            : const HomeScreen();
      case NavigationItem.explore:
        return const FoodStoreMapScreen();
      case NavigationItem.orders:
        return userType == UserType.seller.name
            ? const SellerOrderScreen()
            : const BuyerOrderScreen();
      case NavigationItem.menu:
        return const DishManagementScreen();
      case NavigationItem.stats:
        return const SellerStatsScreen();
      case NavigationItem.cart:
        return const CartScreen();
      case NavigationItem.settings:
        return const SettingsScreen();
    }
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(S.of(context).menuScreen));
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(S.of(context).statsScreen));
  }
}
