import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smgo/core/resources/app_strings.dart';

class AppLocationUtils {
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showSnackbar(context, AppStrings.aLUEnableGpsSnackbarContent.tr());
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
            AppStrings.aLULocationPermissionDeniedSnackbarContent.tr(),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSnackbar(
          context,
          AppStrings.aLULocationPermissionDeniedForeverSnackbarContent.tr(),
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
        _showSnackbar(
          context,
          AppStrings.aLUGetCurrentLocationFailedSnackbarContent.tr(),
        );
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
