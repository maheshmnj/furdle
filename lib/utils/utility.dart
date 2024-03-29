import 'package:flutter/material.dart';
import 'package:furdle/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// State Color for either furdle or Keyboard
class Utility {
  static Size _screenSize = const Size(0, 0);

  static Size get screenSize => _screenSize;

  static set screenSize(Size size) {
    _screenSize = size;
  }

  Utility({required Size screenSize}) {
    _screenSize = screenSize;
  }

  static Future<void> launch(String url,
      {bool isNewTab = true,
      LaunchMode mode = LaunchMode.externalApplication}) async {
    await launchUrl(
      Uri.parse(url),
      mode: mode,
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }

  static void showMessage(context, message,
      {Duration? duration = const Duration(milliseconds: 1500)}) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar(
        screenSize: _screenSize, message: '$message', duration: duration!));
  }
}
