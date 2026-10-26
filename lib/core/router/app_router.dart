// Dosya: lib/core/router/app_router.dart
// Uygulamanın tüm sayfa rotaları (GoRouter).
// Oturum durumuna göre otomatik yönlendirme burada yapılır.

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

/// Rota tanımlarını ve oturum korumasını içerir.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  /// AuthBloc her durum değiştirdiğinde redirect yeniden çalışır.
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    // Oturum kontrolü: yükleniyorsa splash, giriş yoksa login, giriş varsa projeler.
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
    // Rota listesi (adres -> sayfa).
    routes: [
      // Açılış ekranı ve giriş/kayıt sayfaları.
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        // Proje listesi ve alt rotası /projects/new (yeni proje).
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
        // Projenin Kanban panosu.
        path: '/project/:projectId/board',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return BoardPage(projectId: projectId);
        },
      ),
      GoRoute(
        // Yeni görev; ?status=... ile başlangıç kolonu seçilebilir.
        path: '/project/:projectId/task/new',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final status = state.uri.queryParameters['status'];
          return TaskFormPage(projectId: projectId, initialStatus: status);
        },
      ),
      GoRoute(
        // Görev detayı.
        path: '/project/:projectId/task/:taskId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailPage(projectId: projectId, taskId: taskId);
        },
      ),
      GoRoute(
        // Görev düzenleme (aynı form sayfası).
        path: '/project/:projectId/task/:taskId/edit',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskFormPage(projectId: projectId, taskId: taskId);
        },
      ),
      GoRoute(
        // Proje bilgisi, davet kodu ve üyeler.
        path: '/project/:projectId/members',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return MembersPage(projectId: projectId);
        },
      ),
      GoRoute(
        // Proje sohbeti.
        path: '/project/:projectId/chat',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectChatPage(projectId: projectId);
        },
      ),
      GoRoute(
        // Oturumdaki kullanıcıya atanan görevler.
        path: '/my-tasks',
        builder: (context, state) => const MyTasksPage(),
      ),
    ],
    // Bilinmeyen adres açılırsa gösterilen sayfa.
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Sayfa bulunamadı: ${state.error}'))),
  );
}
