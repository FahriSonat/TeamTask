import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_box_names.dart';
import '../theme/theme_cubit.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/models/membership_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/presentation/bloc/project_bloc.dart';

import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/tasks/presentation/cubit/my_tasks_cubit.dart';

import '../../features/chat/data/datasources/chat_local_datasource.dart';
import '../../features/chat/data/models/chat_message_model.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

final sl = GetIt.instance;

/// [storagePath] verilirse Hive bu klasörde açılır (testler için);
/// verilmezse platformun uygulama dokümanları klasörü kullanılır.
Future<void> initInjection({String? storagePath}) async {
  // 1. Hive başlatma
  if (storagePath != null) {
    Hive.init(storagePath);
  } else {
    await Hive.initFlutter();
  }

  // 2. Adapter registration
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ProjectModelAdapter().typeId)) {
    Hive.registerAdapter(ProjectModelAdapter());
  }
  if (!Hive.isAdapterRegistered(MembershipModelAdapter().typeId)) {
    Hive.registerAdapter(MembershipModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ChatMessageModelAdapter().typeId)) {
    Hive.registerAdapter(ChatMessageModelAdapter());
  }

  // 3. Hive kutuları açma
  final userBox = await Hive.openBox<UserModel>(HiveBoxNames.users);
  final projectBox = await Hive.openBox<ProjectModel>(HiveBoxNames.projects);
  final membershipBox = await Hive.openBox<MembershipModel>(
    HiveBoxNames.memberships,
  );
  final taskBox = await Hive.openBox<TaskModel>(HiveBoxNames.tasks);
  final messageBox = await Hive.openBox<ChatMessageModel>(
    HiveBoxNames.messages,
  );
  final sessionBox = await Hive.openBox(HiveBoxNames.session);

  // 4. Seed Kontrolü
  await _applySeedIfNeeded(
    userBox: userBox,
    projectBox: projectBox,
    membershipBox: membershipBox,
    taskBox: taskBox,
    messageBox: messageBox,
    sessionBox: sessionBox,
  );

  // 5. Theme
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sessionBox: sessionBox),
  );

  // 6. Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(userBox: userBox, sessionBox: sessionBox),
  );
  sl.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(
      projectBox: projectBox,
      membershipBox: membershipBox,
      userBox: userBox,
      sessionBox: sessionBox,
    ),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(taskBox: taskBox, sessionBox: sessionBox),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(messageBox: messageBox),
  );

  // 7. Repositories (Domain Sözleşmeleri ile)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () =>
        ProjectRepositoryImpl(localDataSource: sl(), authLocalDataSource: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () =>
        TaskRepositoryImpl(localDataSource: sl(), projectLocalDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(localDataSource: sl()),
  );

  // 8. Blocs / Cubits
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
  sl.registerFactory<ProjectBloc>(() => ProjectBloc(projectRepository: sl()));
  sl.registerFactory<TaskBloc>(() => TaskBloc(taskRepository: sl()));
  sl.registerFactory<MyTasksCubit>(() => MyTasksCubit(taskRepository: sl()));
  sl.registerFactory<ChatBloc>(() => ChatBloc(chatRepository: sl()));
}

Future<void> _applySeedIfNeeded({
  required Box<UserModel> userBox,
  required Box<ProjectModel> projectBox,
  required Box<MembershipModel> membershipBox,
  required Box<TaskModel> taskBox,
  required Box<ChatMessageModel> messageBox,
  required Box sessionBox,
}) async {
  final seedApplied = sessionBox.get(SessionKeys.seedApplied) as bool?;
  if (seedApplied == true) return;

  try {
    final jsonStr = await rootBundle.loadString(
      'assets/seed/teamtask_seed.json',
    );
    final Map<String, dynamic> data = json.decode(jsonStr);

    final usersList = (data['users'] as List).cast<Map<String, dynamic>>();
    for (final item in usersList) {
      final user = UserModel.fromJson(item);
      await userBox.put(user.id, user);
    }

    final projectsList = (data['projects'] as List)
        .cast<Map<String, dynamic>>();
    for (final item in projectsList) {
      final project = ProjectModel.fromJson(item);
      await projectBox.put(project.id, project);
    }

    final membershipsList = (data['memberships'] as List)
        .cast<Map<String, dynamic>>();
    for (final item in membershipsList) {
      final mem = MembershipModel.fromJson(item);
      await membershipBox.put(mem.id, mem);
    }

    final tasksList = (data['tasks'] as List).cast<Map<String, dynamic>>();
    for (final item in tasksList) {
      final task = TaskModel.fromJson(item);
      await taskBox.put(task.id, task);
    }

    if (data['messages'] != null) {
      final messagesList = (data['messages'] as List)
          .cast<Map<String, dynamic>>();
      for (final item in messagesList) {
        final msg = ChatMessageModel.fromJson(item);
        await messageBox.put(msg.id, msg);
      }
    }

    // Görev sayacı: son kullanılan numara saklanır, getNextTaskNumber bir
    // artırarak verir (seed TT-1..TT-4 ise ilk yeni görev TT-5 olur).
    if (projectsList.isNotEmpty) {
      final firstProjectId = projectsList.first['id'] as String;
      final lastNumber = tasksList.fold<int>(
        0,
        (max, t) => (t['number'] as int) > max ? t['number'] as int : max,
      );
      await sessionBox.put(
        SessionKeys.nextTaskNumber(firstProjectId),
        lastNumber,
      );
      await sessionBox.put(SessionKeys.activeProjectId, firstProjectId);
    }

    await sessionBox.put(SessionKeys.seedApplied, true);
  } catch (e, st) {
    // Seed yükleme hatası durumunda çökertme, ama hatayı görünür kıl
    debugPrint('Seed verisi yüklenemedi: $e');
    debugPrintStack(stackTrace: st);
  }
}
