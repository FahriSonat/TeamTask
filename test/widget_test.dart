import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_task/core/constants/app_strings.dart';
import 'package:team_task/features/tasks/domain/enums/task_priority.dart';
import 'package:team_task/features/tasks/domain/enums/task_status.dart';
import 'package:team_task/shared/widgets/empty_view.dart';
import 'package:team_task/shared/widgets/priority_badge.dart';
import 'package:team_task/shared/widgets/status_badge.dart';

void main() {
  group('Widget UI Tests', () {
    testWidgets('PriorityBadge displays correct text and icon for urgent', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PriorityBadge(priority: TaskPriority.urgent)),
        ),
      );

      expect(find.text(AppStrings.priorityUrgent), findsOneWidget);
      expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
    });

    testWidgets('StatusBadge displays correct text for inProgress', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatusBadge(status: TaskStatus.inProgress)),
        ),
      );

      expect(find.text(AppStrings.statusInProgress), findsOneWidget);
    });

    testWidgets('EmptyView renders title, description and button', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              icon: Icons.inbox,
              title: 'Boş Başlık',
              description: 'Açıklama metni',
              actionText: 'Eylem',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Boş Başlık'), findsOneWidget);
      expect(find.text('Açıklama metni'), findsOneWidget);
      expect(find.text('Eylem'), findsOneWidget);

      await tester.tap(find.text('Eylem'));
      expect(buttonPressed, isTrue);
    });
  });
}
