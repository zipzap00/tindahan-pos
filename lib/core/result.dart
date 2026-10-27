// Every repository call that can fail returns a Result instead of throwing,
// so screens always have a human message and a way forward.

enum AppErrorCode {
  permissionDenied,
  notFound,
  offline,
  insufficientStock,
  invalidInput,
  emailInUse,
  wrongCredentials,
  weakPassword,
  invalidEmail,
  tooManyAttempts,
  notConfigured,
  unknown,
}

class AppError {
  const AppError(this.code, {this.context = '', this.cause, this.detail});

  final AppErrorCode code;

  /// Where it happened, for logs only: "[sales/checkout]".
  final String context;

  /// Original exception, logged and never shown.
  final Object? cause;

  /// Optional safe detail to show, such as product names that ran out.
  final String? detail;
}

sealed class Result<T> {
  const Result();

  R when<R>({required R Function(T value) ok, required R Function(AppError error) err}) {
    return switch (this) {
      Ok<T>(:final value) => ok(value),
      Err<T>(:final error) => err(error),
    };
  }

  AppError? get errorOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final error) => error,
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}
