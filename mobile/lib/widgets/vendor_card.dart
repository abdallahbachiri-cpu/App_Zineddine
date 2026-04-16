import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as devtools;

class VendorCard extends StatelessWidget {
  final String vendorName;
  final String? vendorEmail;
  final String? vendorAddress;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? avatarRadius;
  final String? placeholderImage;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final IconData? trailingIcon;
  final double? trailingIconSize;
  final VoidCallback? onTap;
  final VendorCardLayout layoutType;

  const VendorCard({
    super.key,
    required this.vendorName,
    this.margin,
    this.vendorEmail,
    this.vendorAddress,
    this.elevation,
    this.avatarRadius,
    this.placeholderImage,
    this.titleStyle,
    this.subtitleStyle,
    this.trailingIcon,
    this.trailingIconSize,
    this.onTap,
    this.layoutType = VendorCardLayout.avatarWithNameBelow,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,

        elevation: elevation ?? 4,
        child:
            layoutType == VendorCardLayout.avatarWithNameBelow
                ? _buildAvatarWithNameBelow()
                : _buildAvatarWithNameAndAddressOnRight(),
      ),
    );
  }

  Widget _buildAvatarWithNameBelow() {
    return SizedBox(
      width: 130,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Container(
              width: (avatarRadius ?? 25) * 2,
              height: (avatarRadius ?? 25) * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child: NetworkImageWidget(
                  imageUrl: placeholderImage,
                  width: (avatarRadius ?? 25) * 2,
                  height: (avatarRadius ?? 25) * 2,
                  fit: BoxFit.cover,
                  errorWidget: const Icon(
                    Icons.storefront,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              vendorName,
              overflow: TextOverflow.ellipsis,
              style:
                  titleStyle ??
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithNameAndAddressOnRight() {
    return ListTile(
      leading: Container(
        width: (avatarRadius ?? 25) * 2,
        height: (avatarRadius ?? 25) * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: ClipOval(
          child: NetworkImageWidget(
            imageUrl: placeholderImage,
            width: (avatarRadius ?? 25) * 2,
            height: (avatarRadius ?? 25) * 2,
            fit: BoxFit.cover,
            errorWidget: const Icon(
              Icons.storefront,
              color: Colors.grey,
              size: 40,
            ),
          ),
        ),
      ),
      title: Text(
        vendorName,
        style:
            titleStyle ?? TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vendorAddress != null)
            Text(
              vendorAddress!,
              style: subtitleStyle ?? TextStyle(fontSize: 14),
            ),
          if (vendorEmail != null)
            Text(vendorEmail!, style: subtitleStyle ?? TextStyle(fontSize: 14)),
        ],
      ),
      trailing: Icon(
        trailingIcon ?? Icons.arrow_forward_ios,
        size: trailingIconSize ?? 16,
      ),
      onTap:
          onTap ??
          () {
            devtools.log('Tapped on $vendorName');
          },
    );
  }
}

enum VendorCardLayout { avatarWithNameBelow, avatarWithNameAndAddressOnRight }
