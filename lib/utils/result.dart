import 'package:flutter/material.dart';

/// Result Type - A functional approach to error handling
/// Inspired by Kotlin's Result and Rust's Result types
///
/// Usage:
/// ```dart
/// Future<Result<User>> login(String username, String password) async {
///   try {
///     final user = await repository.login(username, password);
///     if (user == null) {
///       return Result.failure('معلومات المستخدم غير صحيحة');
///     }
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure('حدث خطأ أثناء تسجيل الدخول', exception: e);
///   }
/// }
///
/// // Using the result
/// final result = await login(username, password);
/// if (result.isSuccess) {
///   print('User: ${result.data}');
/// } else {
///   print('Error: ${result.message}');
/// }
/// ```

sealed class Result<T> {
  const Result();

  /// Check if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data (throws if failure)
  T get data => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => throw StateError('Cannot get data from a Failure'),
      };

  /// Get the error message (null if success)
  String? get message => switch (this) {
        Success<T>() => null,
        Failure<T>(message: final m) => m,
      };

  /// Alias for message - Get the error message (null if success)
  String? get errorMessage => message;

  /// Get the exception (null if success)
  Object? get exception => switch (this) {
        Success<T>() => null,
        Failure<T>(exception: final e) => e,
      };

  /// Create a successful result
  static Result<T> success<T>(T data) => Success<T>(data);

  /// Create a failure result
  static Result<T> failure<T>(String message, {Object? exception}) =>
      Failure<T>(message, exception: exception);

  /// Map the success value to a new type
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(data: final d) => Result.success(transform(d)),
        Failure<T>(message: final m, exception: final e) =>
          Result.failure(m, exception: e),
      };

  /// Map the success value asynchronously
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success<T>(data: final d) =>
        Result.success(await transform(d)),
      Failure<T>(message: final m, exception: final e) =>
        Result.failure(m, exception: e),
    };
  }

  /// Map the error message
  Result<T> mapError(String Function(String message) transform) => switch (this) {
        Success<T>() => this,
        Failure<T>(message: final m, exception: final e) =>
          Result.failure(transform(m), exception: e),
      };

  /// Execute callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    if (this case Success<T>(data: final d)) {
      callback(d);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(String message, Object? exception) callback) {
    if (this case Failure<T>(message: final m, exception: final e)) {
      callback(m, e);
    }
    return this;
  }

  /// Get data or a default value
  T getOrElse(T defaultValue) => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => defaultValue,
      };

  /// Get data or compute a default value
  T getOrCompute(T Function() defaultSupplier) => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => defaultSupplier(),
      };

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Object? exception) onFailure,
  }) =>
      switch (this) {
        Success<T>(data: final d) => onSuccess(d),
        Failure<T>(message: final m, exception: final e) => onFailure(m, e),
      };

  /// Convert to nullable
  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };
}

/// Success result
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
  
  @override
  String toString() => 'Success($data)';
}

/// Failure result
class Failure<T> extends Result<T> {
  final String message;
  final Object? exception;
  
  const Failure(this.message, {this.exception});
  
  @override
  String toString() => 'Failure($message)';
}

/// Extensions for easier handling
extension ResultExtensions<T> on Result<T> {
  /// Show error dialog if failure
  void showErrorDialogIfFailure(BuildContext context, {String? title}) {
    if (this case Failure<T>(message: final m)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title ?? 'خطأ'),
          content: Text(m),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  /// Show success snackbar if success
  void showSuccessSnackbarIfSuccess(BuildContext context, String message) {
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Result builder for chaining operations
class ResultBuilder<T> {
  Result<T> _result;

  ResultBuilder(Result<T> result) : _result = result;

  /// Chain another operation
  ResultBuilder<R> then<R>(Result<R> Function(T data) operation) {
    return ResultBuilder(
      _result.fold(
        onSuccess: (data) => operation(data),
        onFailure: (message, exception) => Result.failure(message, exception: exception),
      ),
    );
  }

  /// Chain an async operation
  Future<ResultBuilder<R>> thenAsync<R>(
    Future<Result<R>> Function(T data) operation,
  ) async {
    return ResultBuilder(
      await _result.fold(
        onSuccess: (data) => operation(data),
        onFailure: (message, exception) =>
            Future.value(Result.failure(message, exception: exception)),
      ),
    );
  }

  /// Get the result
  Result<T> build() => _result;
}
