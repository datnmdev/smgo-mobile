import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AppLocationUtils {
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showSnackbar(context, 'Vui lòng bật GPS trên thiết bị của bạn.');
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showSnackbar(
            context,
            'Ứng dụng cần quyền truy cập vị trí để tối ưu tuyến đường từ điểm bạn đang đứng.',
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSnackbar(
          context,
          'Vui lòng vào Cài đặt để cấp quyền vị trí cho ứng dụng.',
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'Không thể lấy được vị trí hiện tại của bạn.');
      }
      return null;
    }
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
