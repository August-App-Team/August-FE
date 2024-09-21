import 'dart:ui';

import 'package:flutter/material.dart';

List<Color> lightenColors(List<Color> colors, double amount) {
  return colors.map((color) => lightenColor(color, amount)).toList();
}

Color lightenColor(Color color, double amount) {
  assert(amount >= 0 && amount <= 1);

  final hslColor = HSLColor.fromColor(color);
  final lightenedHslColor = hslColor.withLightness(
    (hslColor.lightness + amount).clamp(0.0, 1.0),
  );

  return lightenedHslColor.toColor();
}

List<Color> darkenColors(List<Color> colors, double amount) {
  return colors.map((color) => darkenColor(color, amount)).toList();
}

Color darkenColor(Color color, double amount) {
  assert(amount >= 0 && amount <= 1);

  final hslColor = HSLColor.fromColor(color);
  final darkenedHslColor = hslColor.withLightness(
    (hslColor.lightness - amount).clamp(0.0, 1.0),
  );

  return darkenedHslColor.toColor();
}
