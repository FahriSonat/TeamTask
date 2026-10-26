// Dosya: lib/features/auth/presentation/bloc/auth_bloc.dart
// Oturum durumunu yöneten Bloc. Router bu Bloc'u dinleyerek yönlendirir.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Olaylar: kontrol, giriş, kayıt, çıkış. Durumlar: auth_state.dart.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  /// Açılışta kayıtlı oturum var mı bakar.
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.when(
      success: (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
      failure: (failure) {
        emit(const Unauthenticated());
      },
    );
  }

  /// Giriş dener; başarılıysa Authenticated, değilse AuthError.
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );
    result.when(
      success: (user) => emit(Authenticated(user)),
      failure: (failure) => emit(AuthError(failure.message)),
    );
  }

  /// Kayıt olur ve doğrudan oturum açar.
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.when(
      success: (user) => emit(Authenticated(user)),
      failure: (failure) => emit(AuthError(failure.message)),
    );
  }

  /// Çıkış yapar.
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated());
  }
}
