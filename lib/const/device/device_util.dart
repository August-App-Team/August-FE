import 'dart:io';

import 'package:flutter/material.dart';

class DeviceUtils {
  // Define standard breakpoints for mobile, tablet
  static bool isTablet(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.shortestSide;
    return deviceWidth > 600; // Define tablet as any device with >600dp width
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

enum AppIcon {
  dark_prime,
  light_prime,
  dark_pencil,
  light_pencil,
}
