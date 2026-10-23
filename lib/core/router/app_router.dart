import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

import '../../features/projects/presentation/pages/members_page.dart';
import '../../features/projects/presentation/pages/new_project_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';

import '../../features/tasks/presentation/pages/board_page.dart';
import '../../features/tasks/presentation/pages/my_tasks_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/chat/presentation/pages/project_chat_page.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : '/splash';
      }

      if (authState is Unauthenticated || authState is AuthError) {
        return isAuthRoute ? null : '/login';
      }

      if (authState is Authenticated) {
        if (isSplash || isAuthRoute) {
          return '/projects';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsPage(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewProjectPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/project/:projectId/board',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return BoardPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/task/new',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final status = state.uri.queryParameters['status'];
          return TaskFormPage(projectId: projectId, initialStatus: status);
        },
      ),
      GoRoute(
        path: '/project/:projectId/task/:taskId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailPage(projectId: projectId, taskId: taskId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/task/:taskId/edit',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskFormPage(projectId: projectId, taskId: taskId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/members',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return MembersPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/chat',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectChatPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/my-tasks',
        builder: (context, state) => const MyTasksPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Sayfa bulunamadı: ${state.error}'))),
  );
}
