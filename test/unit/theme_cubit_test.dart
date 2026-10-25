import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_task/core/theme/theme_cubit.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;
  late ThemeCubit themeCubit;

  setUp(() {
    mockBox = MockBox();
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
    themeCubit = ThemeCubit(sessionBox: mockBox);
  });

  tearDown(() {
    themeCubit.close();
  });

  group('ThemeCubit Test', () {
    test('initial mode is ThemeMode.system when no preference saved', () {
      expect(themeCubit.state, ThemeMode.system);
    });

    test('toggleTheme switches between dark and light', () {
      themeCubit.setTheme(ThemeMode.light);
      expect(themeCubit.state, ThemeMode.light);

      themeCubit.toggleTheme();
      expect(themeCubit.state, ThemeMode.dark);
      expect(themeCubit.isDark, isTrue);

      themeCubit.toggleTheme();
      expect(themeCubit.state, ThemeMode.light);
      expect(themeCubit.isDark, isFalse);
    });
  });
}
