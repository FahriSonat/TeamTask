import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_task/core/errors/result.dart';
import 'package:team_task/features/tasks/domain/entities/task.dart';
import 'package:team_task/features/tasks/domain/enums/task_priority.dart';
import 'package:team_task/features/tasks/domain/enums/task_status.dart';
import 'package:team_task/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_task/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:team_task/features/tasks/presentation/bloc/task_event.dart';
import 'package:team_task/features/tasks/presentation/bloc/task_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockTaskRepository;
  late TaskBloc taskBloc;

  final testTask = Task(
    id: 't1',
    projectId: 'p1',
    number: 1,
    title: 'Test Görevi',
    description: 'Açıklama',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    createdBy: 'u1',
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    taskBloc = TaskBloc(taskRepository: mockTaskRepository);
  });

  tearDown(() {
    taskBloc.close();
  });

  group('TaskBloc Test', () {
    test('initial state is TaskInitial', () {
      expect(taskBloc.state, const TaskInitial());
    });

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when tasks are loaded successfully',
      build: () {
        when(
          () => mockTaskRepository.getTasksByProject('p1'),
        ).thenAnswer((_) async => Result.success([testTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const TasksLoadRequested('p1')),
      expect: () => [
        const TaskLoading(),
        TasksLoaded(tasks: [testTask]),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'optimistically updates status and keeps it on repository success',
      build: () {
        when(
          () => mockTaskRepository.changeStatus('t1', TaskStatus.inProgress),
        ).thenAnswer(
          (_) async =>
              Result.success(testTask.copyWith(status: TaskStatus.inProgress)),
        );
        return taskBloc;
      },
      seed: () => TasksLoaded(tasks: [testTask]),
      act: (bloc) => bloc.add(
        const TaskStatusChanged(taskId: 't1', newStatus: TaskStatus.inProgress),
      ),
      expect: () => [
        TasksLoaded(tasks: [testTask.copyWith(status: TaskStatus.inProgress)]),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'removes task on TaskDeleted',
      build: () {
        when(
          () => mockTaskRepository.deleteTask('t1'),
        ).thenAnswer((_) async => const Result.success(null));
        return taskBloc;
      },
      seed: () => TasksLoaded(tasks: [testTask]),
      act: (bloc) => bloc.add(const TaskDeleted('t1')),
      expect: () => [const TasksLoaded(tasks: [])],
    );
  });
}
