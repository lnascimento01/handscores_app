import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: onSurface),
      titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface.withOpacity(.90)),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface.withOpacity(.75)),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface),
    );
  }
}
