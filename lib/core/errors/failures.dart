import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Veri kaydedilirken veya okunurken bir sorun oluştu.',
  ]);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'E-posta veya şifre hatalı.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Girdi bilgileri kurallara uymuyor.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'İstenen kayıt bulunamadı.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmeyen bir hata oluştu.']);
}
