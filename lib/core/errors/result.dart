// Dosya: lib/core/errors/result.dart
// Result<T>: bir işlemin ya başarılı veriyi ya da Failure'ı taşıdığı sonuç tipi.
// try/catch yerine sonuçların açıkça ele alınmasını sağlar.

import 'package:equatable/equatable.dart';

import 'failures.dart';

/// Başarı (Success) veya hata (FailureResult) olabilen sonuç.
sealed class Result<T> extends Equatable {
  const Result();

  /// İşlem başarılı mı?
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  /// Başarılıysa veriyi, değilse null döndürür.
  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    FailureResult<T>() => null,
  };

  /// Hatalıysa Failure'ı, değilse null döndürür.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(failure: final f) => f,
  };

  /// İki durumu da ele almaya zorlar: success veya failure fonksiyonu çağrılır.
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      FailureResult<T>(failure: final f) => failure(f),
    };
  }

  /// Kısayol kurucular: Result.success(veri) / Result.failure(hata).
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;
}

/// Başarılı sonuç; data alanı veriyi taşır.
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Başarısız sonuç; failure alanı hatayı taşır.
final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  List<Object?> get props => [failure];
}
