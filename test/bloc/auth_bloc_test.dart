// Dosya: test/bloc/auth_bloc_test.dart
// AuthBloc testleri: başarılı giriş, hatalı giriş ve çıkış.
// Repository mocktail ile taklit edilir.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_task/core/errors/failures.dart';
import 'package:team_task/core/errors/result.dart';
import 'package:team_task/features/auth/domain/entities/user.dart';
import 'package:team_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:team_task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_task/features/auth/presentation/bloc/auth_event.dart';
import 'package:team_task/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// Test grubu.
void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  final testUser = User(
    id: 'u1',
    name: 'Esra Yılmaz',
    email: 'esra@teamtask.com',
    createdAt: DateTime.utc(2026, 10, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Test', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when session exists',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => Result.success(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when session is null',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Result.success(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful login',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'esra@teamtask.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => Result.success(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'esra@teamtask.com',
          password: 'password123',
        ),
      ),
      expect: () => [const AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failed login',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'esra@teamtask.com',
            password: 'wrong',
          ),
        ).thenAnswer(
          (_) async => const Result.failure(AuthFailure('Hatalı şifre')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'esra@teamtask.com', password: 'wrong'),
      ),
      expect: () => [const AuthLoading(), const AuthError('Hatalı şifre')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on logout',
      build: () {
        when(
          () => mockAuthRepository.logout(),
        ).thenAnswer((_) async => const Result.success(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );
  });
}
