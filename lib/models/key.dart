import 'package:flutter/material.dart';
class SpecialKey {
  String character;

  /// position of key in the Row
  int position;
  Size size;
  SpecialKey(
      {this.character = '', this.position = 0, this.size = const Size(60, 60)});
}

class FurdleKey {
  String character;
  bool isPhysicalKey;
  bool isPressed;
  FurdleKey(
      {this.character = '',
      this.isPressed = false,
      this.isPhysicalKey = false});
}
