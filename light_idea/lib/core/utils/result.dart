sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.error(String message, [Object? cause]) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        _ => null,
      };

  String? get errorOrNull => switch (this) {
        Error<T>(:final message) => message,
        _ => null,
      };

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Object? error) onError,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final message, :final cause) => onError(message, cause),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Result.success(transform(data)),
      Error<T>(:final message, :final cause) => Result.error(message, cause),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final String message;
  final Object? cause;
  const Error(this.message, [this.cause]);
}
