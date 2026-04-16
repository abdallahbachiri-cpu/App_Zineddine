import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;

  final double? width;

  final double? height;

  final BoxFit fit;

  final BorderRadius? borderRadius;

  final IconData errorIcon;

  final double errorIconSize;

  final Widget? errorWidget;

  final Color? backgroundColor;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.fastfood,
    this.errorIconSize = 50,
    this.backgroundColor,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[200];
    final processedUrl = _processImageUrl();

    Widget imageWidget = CachedNetworkImage(
      imageUrl: processedUrl,
      width: width,
      height: height,
      fit: fit,

      placeholder:
          (context, url) => Container(
            width: width,
            height: height,
            color: bgColor,
            child: const Center(child: CircularProgressIndicator()),
          ),

      errorWidget:
          (context, url, error) => Container(
            width: width,
            height: height,
            color: bgColor,
            child:
                errorWidget ??
                Icon(errorIcon, size: errorIconSize, color: Colors.grey[400]),
          ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  String _processImageUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return '';
    }

    final fullUrl = '${AppConsts.apiBaseUrl}$imageUrl';
    return fullUrl.replaceAll(RegExp(r'(?<!:)//'), '/');
  }
}
