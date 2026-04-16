import 'dart:ui' as ui;
import 'dart:developer' as devtools;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cuisinous/generated/l10n.dart';

class MapMarkerUtils {
  static Future<BitmapDescriptor> getCircularMarkerIcon(
    String imageUrl, {
    int size = 150,
  }) async {
    if (imageUrl.isEmpty) {
      devtools.log('MapMarkerUtils: Empty image URL provided');
      return BitmapDescriptor.defaultMarker;
    }

    try {
      String cleanUrl = imageUrl.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
      devtools.log('MapMarkerUtils: Generating marker for URL: $cleanUrl');

      final response = await Dio().get<List<int>>(
        cleanUrl,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        devtools.log(
          'MapMarkerUtils: Failed to download image. Status: ${response.statusCode}',
        );
        return BitmapDescriptor.defaultMarker;
      }

      if (response.data == null || response.data!.isEmpty) {
        devtools.log('MapMarkerUtils: Image data is empty');
        return BitmapDescriptor.defaultMarker;
      }

      final bytes = Uint8List.fromList(response.data!);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size,
        targetHeight: size,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint()..isAntiAlias = true;

      final canvasHeight = size + 40;
      final radius = size / 2;
      final imageRadius = radius - 14;
      final center = Offset(radius, radius + 10);

      final path = Path();
      path.moveTo(center.dx, center.dy + radius);
      path.lineTo(center.dx - 20, center.dy + radius - 30);
      path.lineTo(center.dx + 20, center.dy + radius - 30);
      path.close();
      canvas.drawPath(path, Paint()..color = AppConsts.accentColor);

      canvas.drawCircle(
        center,
        imageRadius + 4,
        Paint()
          ..color = AppConsts.accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      canvas.drawCircle(
        center,
        imageRadius,
        Paint()..color = AppConsts.accentColor,
      );

      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: imageRadius)),
      );

      final imageOffset = Offset(center.dx - size / 2, center.dy - size / 2);
      canvas.drawImage(image, imageOffset, paint);
      canvas.restore();

      final markerImage = await pictureRecorder.endRecording().toImage(
        size,
        canvasHeight.toInt(),
      );

      final byteData = await markerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        devtools.log('MapMarkerUtils: Failed to convert image to byte data');
        return BitmapDescriptor.defaultMarker;
      }

      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      devtools.log('MapMarkerUtils: Error creating marker icon: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  static Future<BitmapDescriptor?> loadStoreMarkerIcon(
    String? profileImageUrl,
  ) async {
    if (profileImageUrl != null) {
      try {
        final fullUrl = '${AppConsts.apiBaseUrl}$profileImageUrl';
        return await MapMarkerUtils.getCircularMarkerIcon(
          fullUrl.replaceAll(RegExp(r'(?<!:)//'), '/'),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> navigateToMap(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).mapLaunchError)));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.of(context).mapLaunchError)));
      }
    }
  }
}
