// Dosya: lib/features/auth/presentation/bloc/auth_event.dart
// AuthBloc'a gönderilen olaylar.

import 'package:equatable/equatable.dart';

/// Tüm kimlik olaylarının atası.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kayıtlı oturumu kontrol et.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Giriş yap.
final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Kayıt ol.
final class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Çıkış yap.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
