// Dosya: test/responsive_test.dart
// Responsive testi: tüm sayfaları farklı telefon/tablet boyutlarında ve büyük
// yazı tipinde açar; taşma (overflow) olursa test başarısız olur.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:team_task/app.dart';
import 'package:team_task/core/di/injection.dart';
import 'package:team_task/features/auth/domain/repositories/auth_repository.dart';

/// Yaygın telefon / tablet ekranları (mantıksal piksel).
const _screens = <String, Size>{
  'iPhone SE (1. nesil) 320x568': Size(320, 568),
  'Küçük Android 360x640': Size(360, 640),
  'iPhone SE 375x667': Size(375, 667),
  'iPhone 14 390x844': Size(390, 844),
  'Pixel 7 412x915': Size(412, 915),
  'Yatay telefon 640x360': Size(640, 360),
  'Yatay iPhone 844x390': Size(844, 390),
  'Tablet 768x1024': Size(768, 1024),
  'Tablet yatay 1280x800': Size(1280, 800),
};

/// Oturum açmadan görülen sayfalar.
const _guestRoutes = ['/login', '/register'];

/// Oturum açtıktan sonra gezilen sayfalar.
const _authRoutes = [
  '/projects',
  '/projects/new',
  '/project/proj-bitirme-1/board',
  '/project/proj-bitirme-1/task/new',
  '/project/proj-bitirme-1/task/task-3',
  '/project/proj-bitirme-1/task/task-3/edit',
  '/project/proj-bitirme-1/members',
  '/project/proj-bitirme-1/chat',
  '/my-tasks',
];

late Directory _tempDir;

/// Sonsuz animasyonlar (ör. yükleniyor göstergesi) pumpAndSettle'ı kilitlediği
/// için sabit sayıda kare ilerletilir; arada gerçek async işlere izin verilir.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Uygulamayı verilen boyutta açar, rotaları gezer ve yakalanan hataları döndürür.
Future<List<String>> _checkRoutes(
  WidgetTester tester, {
  required Size size,
  required List<String> routes,
  double textScale = 1.0,
}) async {
  final errors = <String>[];
  final originalOnError = FlutterError.onError;
  String? currentRoute;
  FlutterError.onError = (details) {
    // Hatayı üreten widget'ın kaynak konumu (ör. lib/.../page.dart:42)
    final location = RegExp(
      r'lib/[\w/]+\.dart:\d+',
    ).firstMatch(details.toString())?.group(0);
    errors.add(
      '[$currentRoute] ${details.exceptionAsString().split('\n').first}'
      '${location != null ? ' ($location)' : ''}',
    );
  };

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  try {
    await tester.pumpWidget(const TeamTaskApp());
    await _settle(tester);

    for (final route in routes) {
      currentRoute = route;
      final ctx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(ctx).go(route);
      await _settle(tester);
    }
  } finally {
    FlutterError.onError = originalOnError;
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  }
  return errors;
}

/// Önce Hive geçici klasörde kurulur, sonra her ekran için test çalışır.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _tempDir = await Directory.systemTemp.createTemp('teamtask_responsive');
    await initInjection(storagePath: _tempDir.path);
  });

  tearDownAll(() async {
    try {
      await _tempDir.delete(recursive: true);
    } catch (_) {
      // Hive dosyaları açık kalmış olabilir; geçici klasör OS tarafından temizlenir.
    }
  });

  group('Oturumsuz sayfalar', () {
    for (final entry in _screens.entries) {
      testWidgets('${entry.key} taşma yok', (tester) async {
        final errors = await _checkRoutes(
          tester,
          size: entry.value,
          routes: _guestRoutes,
        );
        expect(errors, isEmpty, reason: errors.join('\n'));
      });
    }
  });

  group('Oturumlu sayfalar', () {
    setUpAll(() async {
      await sl<AuthRepository>().login(
        email: 'esra@teamtask.com',
        password: '123456',
      );
    });

    for (final entry in _screens.entries) {
      testWidgets('${entry.key} taşma yok', (tester) async {
        final errors = await _checkRoutes(
          tester,
          size: entry.value,
          routes: _authRoutes,
        );
        expect(errors, isEmpty, reason: errors.join('\n'));
      });
    }

    testWidgets('Büyük yazı tipi (1.3x) 360x640 taşma yok', (tester) async {
      final errors = await _checkRoutes(
        tester,
        size: const Size(360, 640),
        routes: _authRoutes,
        textScale: 1.3,
      );
      expect(errors, isEmpty, reason: errors.join('\n'));
    });
  });
}
