// Dosya: lib/core/theme/theme_cubit.dart
// Açık / koyu tema durumu ve kalıcı saklanması.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../constants/hive_box_names.dart';

/// Seçili ThemeMode'u tutar ve oturum kutusuna kaydeder.
class ThemeCubit extends Cubit<ThemeMode> {
  final Box sessionBox;
  static const String _key = SessionKeys.themeMode;

  ThemeCubit({required this.sessionBox}) : super(_getInitialMode(sessionBox));

  /// Kayıtlı tercih yoksa sistem temasını kullanır.
  static ThemeMode _getInitialMode(Box box) {
    final saved = box.get(_key) as String?;
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Koyu <-> açık arasında geçiş yapar.
  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  /// Yeni temayı yayınlar ve Hive'a yazar.
  void setTheme(ThemeMode mode) {
    emit(mode);
    sessionBox.put(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  /// Koyu mod seçili mi?
  bool get isDark => state == ThemeMode.dark;
}
