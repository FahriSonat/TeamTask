import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Box sessionBox;
  static const String _key = 'user_theme_mode';

  ThemeCubit({required this.sessionBox}) : super(_getInitialMode(sessionBox));

  static ThemeMode _getInitialMode(Box box) {
    final saved = box.get(_key) as String?;
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    sessionBox.put(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDark => state == ThemeMode.dark;
}
