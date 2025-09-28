import 'package:flutter/material.dart';

enum FormFactor { mobile, tablet, desktop }

class LayoutBreakpoints {
  static const double tabletMin = 700;
  static const double desktopMin = 1100;

  static FormFactor of(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= desktopMin) return FormFactor.desktop;
    if (w >= tabletMin) return FormFactor.tablet;
    return FormFactor.mobile;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    switch (of(context)) {
      case FormFactor.desktop: return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
      case FormFactor.tablet:  return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      case FormFactor.mobile:  return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  static double cardRadius(BuildContext context) {
    switch (of(context)) {
      case FormFactor.desktop: return 20;
      case FormFactor.tablet:  return 16;
      case FormFactor.mobile:  return 14;
    }
  }
}
