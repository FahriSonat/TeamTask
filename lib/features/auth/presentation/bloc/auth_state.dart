// Dosya: lib/features/auth/presentation/bloc/auth_state.dart
// AuthBloc'un yayınladığı durumlar.

import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Tüm oturum durumlarının atası.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Henüz kontrol edilmedi.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// İşlem sürüyor.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Giriş yapılmış; user alanında kullanıcı var.
final class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Oturum yok.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Giriş/kayıt hatası; message ekranda gösterilir.
final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
