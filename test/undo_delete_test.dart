// Dosya: test/undo_delete_test.dart
// Silmeyi geri al testi: gerçek uygulamada görevi siler, "Geri al"a basar ve
// görevin aynı TT koduyla panoya ve veritabanına geri döndüğünü doğrular.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:team_task/app.dart';
import 'package:team_task/core/constants/app_strings.dart';
import 'package:team_task/core/di/injection.dart';
import 'package:team_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:team_task/features/tasks/domain/repositories/task_repository.dart';

const _projectId = 'proj-bitirme-1';
const _taskTitle = 'Sunum ve Demo Senaryosu Hazırlığı'; // seed'deki TT-4

late Directory _tempDir;

/// Sonsuz animasyonlar pumpAndSettle'ı kilitlediği için sabit sayıda kare
/// ilerletilir; arada Hive'ın gerçek dosya işlemlerine izin verilir.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Veritabanında TT-4 var mı?
Future<bool> _taskExistsInDb(WidgetTester tester) async {
  final result = await tester.runAsync(
    () => sl<TaskRepository>().getTasksByProject(_projectId),
  );
  return result!.dataOrNull!.any((t) => t.id == 'task-4' && t.number == 4);
}

/// Hive geçici klasörde kurulur ve demo kullanıcısıyla oturum açılır.
void main() {
  setUpAll(() async {
    _tempDir = await Directory.systemTemp.createTemp('teamtask_undo');
    await initInjection(storagePath: _tempDir.path);
    await sl<AuthRepository>().login(
      email: 'esra@teamtask.com',
      password: '123456',
    );
  });

  tearDownAll(() async {
    try {
      await _tempDir.delete(recursive: true);
    } catch (_) {
      // Hive dosyaları açık kalmış olabilir; geçici klasör OS tarafından temizlenir.
    }
  });

  testWidgets('silinen görev "Geri al" ile aynı TT koduyla geri gelir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TeamTaskApp());
    await _settle(tester);

    // Panoyu aç, ardından görev detayını üstüne it (geri dönülebilsin).
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('/project/$_projectId/board');
    await _settle(tester);
    expect(find.text(_taskTitle), findsOneWidget);

    router.push('/project/$_projectId/task/task-4');
    await _settle(tester);

    // Sil -> onayla
    await tester.tap(find.byTooltip(AppStrings.deleteTask));
    await _settle(tester);
    await tester.tap(find.text(AppStrings.delete).last);
    await _settle(tester);

    // Panoya dönüldü, görev yok, "Geri al" mesajı görünüyor.
    expect(find.text(_taskTitle), findsNothing);
    expect(find.text('TT-4 · ${AppStrings.taskDeleted}'), findsOneWidget);
    expect(await _taskExistsInDb(tester), isFalse);

    // Geri al
    await tester.tap(find.text(AppStrings.undo));
    await _settle(tester);

    expect(find.text(_taskTitle), findsOneWidget);
    expect(await _taskExistsInDb(tester), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
