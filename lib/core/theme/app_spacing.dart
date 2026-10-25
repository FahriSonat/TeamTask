import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const double pagePaddingMobile = 16.0;
  static const double formPadding = 24.0;

  static const double radiusChip = 6.0;
  static const double radiusField = 10.0;
  static const double radiusCard = 10.0;
  static const double radiusColumn = 14.0;
  static const double radiusButton = 14.0;
  static const double radiusSheet = 24.0;

  static const double minTouchTarget = 44.0;

  static const BorderRadius borderRadiusChip = BorderRadius.all(
    Radius.circular(radiusChip),
  );
  static const BorderRadius borderRadiusField = BorderRadius.all(
    Radius.circular(radiusField),
  );
  static const BorderRadius borderRadiusCard = BorderRadius.all(
    Radius.circular(radiusCard),
  );
  static const BorderRadius borderRadiusColumn = BorderRadius.all(
    Radius.circular(radiusColumn),
  );
  static const BorderRadius borderRadiusButton = BorderRadius.all(
    Radius.circular(radiusButton),
  );
  static const BorderRadius borderRadiusSheet = BorderRadius.vertical(
    top: Radius.circular(radiusSheet),
  );
}
