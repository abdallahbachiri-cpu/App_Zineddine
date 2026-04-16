import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/core/enums/user_type.dart';
import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  NavigationItem _selectedItem = NavigationItem.home;

  NavigationItem get selectedItem => _selectedItem;

  void setNavigationItem(NavigationItem item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  int getSelectedIndex(String? userType) {
    final items = getNavigationItems(userType);
    return items.indexOf(_selectedItem);
  }

  void setSelectedIndex(int index, String? userType) {
    final items = getNavigationItems(userType);
    if (index >= 0 && index < items.length) {
      setNavigationItem(items[index]);
    }
  }

  List<NavigationItem> getNavigationItems(String? userType) {
    return userType == UserType.seller.name
        ? [
          NavigationItem.home,
          NavigationItem.stats,
          NavigationItem.menu,
          NavigationItem.orders,
          NavigationItem.settings,
        ]
        : [
          NavigationItem.home,
          NavigationItem.explore,
          NavigationItem.cart,
          NavigationItem.orders,
          NavigationItem.settings,
        ];
  }
}
