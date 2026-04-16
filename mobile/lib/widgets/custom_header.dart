import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String username;
  final String address;
  final String? profileImageUrl;
  final VoidCallback onNotificationPressed;
  final ValueChanged<String> onSearchChanged;
  final List<String> filterOptions;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback? onFilterPressed;
  final bool hasActiveFilters;
  final Color headerBackgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color searchBarColor;
  final TextStyle usernameTextStyle;
  final TextStyle addressTextStyle;
  final TextStyle searchHintTextStyle;
  final IconData notificationIcon;
  final IconData searchIcon;
  final IconData filterIcon;

  const CustomHeader({
    super.key,
    required this.username,
    required this.address,
    this.profileImageUrl,
    required this.onNotificationPressed,
    required this.onSearchChanged,
    required this.filterOptions,
    required this.onFilterSelected,
    this.onFilterPressed,
    this.hasActiveFilters = false,
    this.headerBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconColor = Colors.grey,
    this.searchBarColor = Colors.white,
    this.usernameTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    this.addressTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black38,
    ),
    this.searchHintTextStyle = const TextStyle(color: Colors.grey),
    this.notificationIcon = Icons.notifications,
    this.searchIcon = Icons.search,
    this.filterIcon = Icons.filter_list,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 60),
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: NetworkImageWidget(
                    imageUrl: profileImageUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: Image.asset(
                      'assets/images/default_profile.png',
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).header_hello(username),
                      style: usernameTextStyle.copyWith(color: textColor),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: addressTextStyle.copyWith(color: textColor),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onNotificationPressed,
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: searchBarColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(searchIcon, color: iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: S.of(context).header_searchHint,
                      hintStyle: searchHintTextStyle,
                      border: InputBorder.none,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (onFilterPressed != null)
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(filterIcon, color: iconColor),
                        onPressed: onFilterPressed,
                      ),
                      if (hasActiveFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
