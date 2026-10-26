// Dosya: lib/core/theme/app_text_styles.dart
// Yazı stilleri (başlık, gövde, etiket, açıklama).

import 'package:flutter/material.dart';

/// Ekranlarda tutarlı tipografi için hazır TextStyle'lar.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 48,
    height: 52 / 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 19,
    height: 24 / 19,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 23 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 15,
    height: 23 / 15,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 17 / 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
}
