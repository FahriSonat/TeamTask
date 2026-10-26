// Dosya: lib/app.dart
// Kök widget (TeamTaskApp).
// Tüm Bloc/Cubit örneklerini oluşturup ağaca verir; tema, yönlendirme ve
// Türkçe yerelleştirme ayarlarıyla MaterialApp.router kurulur.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/projects/presentation/bloc/project_bloc.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/cubit/my_tasks_cubit.dart';

/// Uygulamanın en üst widget'ı; global state yöneticilerinin sahibidir.
class TeamTaskApp extends StatefulWidget {
  const TeamTaskApp({super.key});

  @override
  State<TeamTaskApp> createState() => _TeamTaskAppState();
}

class _TeamTaskAppState extends State<TeamTaskApp> {
  late final AuthBloc _authBloc;
  late final ProjectBloc _projectBloc;
  late final TaskBloc _taskBloc;
  late final MyTasksCubit _myTasksCubit;
  late final ChatBloc _chatBloc;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  /// Bloc'lar GetIt üzerinden bir kez oluşturulur ve uygulama boyunca yaşar.
  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _projectBloc = sl<ProjectBloc>();
    _taskBloc = sl<TaskBloc>();
    _myTasksCubit = sl<MyTasksCubit>();
    _chatBloc = sl<ChatBloc>();
    _themeCubit = sl<ThemeCubit>();
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  /// Uygulama kapanırken tüm Bloc akışları kapatılır.
  @override
  void dispose() {
    _authBloc.close();
    _projectBloc.close();
    _taskBloc.close();
    _myTasksCubit.close();
    _chatBloc.close();
    _themeCubit.close();
    super.dispose();
  }

  /// Bloc'lar ağaca verilir; tema değişince MaterialApp yeniden çizilir.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProjectBloc>.value(value: _projectBloc),
        BlocProvider<TaskBloc>.value(value: _taskBloc),
        BlocProvider<MyTasksCubit>.value(value: _myTasksCubit),
        BlocProvider<ChatBloc>.value(value: _chatBloc),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _appRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
          );
        },
      ),
    );
  }
}
