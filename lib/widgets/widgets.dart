import 'package:flutter/material.dart';
import 'package:furdle/utils/settings_service.dart';

/**
 * Small helper widgets go here in this page
 * for custom large widgets consider creating
 * a separate file under lib/widgets
 */

SnackBar showSnackbar({required String message, required Duration duration}) {
  final double margin = SettingsService.screenSize.width / 3;
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    margin: EdgeInsets.only(
        bottom: SettingsService.screenSize.height * 0.9 - kToolbarHeight,
        right: SettingsService.screenSize.width < 500 ? 20 : margin,
        left: SettingsService.screenSize.width < 500 ? 20 : margin),
  );
}
