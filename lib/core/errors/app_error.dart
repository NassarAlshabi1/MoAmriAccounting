/// App Error - A structured error handling system
///
/// This provides a type-safe way to handle different types of errors
/// throughout the application.

/// Base class for all application errors
sealed class AppError {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Get user-friendly error message in Arabic
  String get userMessage => message;
}

/// Database-related errors
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory DatabaseError.notFound(String entity, int id) => DatabaseError(
        message: 'لم يتم العثور على $entity بالمعرف $id',
        code: 'DB_NOT_FOUND',
      );

  factory DatabaseError.insertFailed(String entity, Object? error) =>
      DatabaseError(
        message: 'فشل في إضافة $entity',
        code: 'DB_INSERT_FAILED',
        originalError: error,
      );

  factory DatabaseError.updateFailed(String entity, Object? error) =>
      DatabaseError(
        message: 'فشل في تحديث $entity',
        code: 'DB_UPDATE_FAILED',
        originalError: error,
      );

  factory DatabaseError.deleteFailed(String entity, Object? error) =>
      DatabaseError(
        message: 'فشل في حذف $entity',
        code: 'DB_DELETE_FAILED',
        originalError: error,
      );

  factory DatabaseError.queryFailed(String query, Object? error) =>
      DatabaseError(
        message: 'فشل في تنفيذ الاستعلام',
        code: 'DB_QUERY_FAILED',
        originalError: error,
      );
}

/// Validation errors
class ValidationError extends AppError {
  final String field;

  const ValidationError({
    required super.message,
    required this.field,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationError.required(String field) => ValidationError(
        message: 'حقل $field مطلوب',
        field: field,
        code: 'VAL_REQUIRED',
      );

  factory ValidationError.invalidFormat(String field, String expectedFormat) =>
      ValidationError(
        message: 'صيغة $field غير صحيحة. المتوقع: $expectedFormat',
        field: field,
        code: 'VAL_INVALID_FORMAT',
      );

  factory ValidationError.outOfRange(
          String field, num min, num max, num actual) =>
      ValidationError(
        message: 'قيمة $field يجب أن تكون بين $min و $max. القيمة الحالية: $actual',
        field: field,
        code: 'VAL_OUT_OF_RANGE',
      );

  factory ValidationError.insufficientStock(
          String materialName, double available, double requested) =>
      ValidationError(
        message:
            'الكمية المتوفرة من "$materialName" غير كافية. المتوفر: $available، المطلوب: $requested',
        field: 'quantity',
        code: 'VAL_INSUFFICIENT_STOCK',
      );
}

/// Business logic errors
class BusinessError extends AppError {
  const BusinessError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory BusinessError.materialNotDeletable(String materialName) =>
      BusinessError(
        message: 'لا يمكن حذف المادة "$materialName" لارتباطها بعمليات أخرى',
        code: 'BIZ_MATERIAL_NOT_DELETABLE',
      );

  factory BusinessError.customerNotDeletable(String customerName) =>
      BusinessError(
        message: 'لا يمكن حذف العميل "$customerName" لوجود ديون مرتبطة به',
        code: 'BIZ_CUSTOMER_NOT_DELETABLE',
      );

  factory BusinessError.cannotDeleteWithDependencies(
          String entity, int count) =>
      BusinessError(
        message: 'لا يمكن حذف $entity لوجود $count عنصر مرتبط به',
        code: 'BIZ_HAS_DEPENDENCIES',
      );
}

/// Network/API errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkError.noConnection() => const NetworkError(
        message: 'لا يوجد اتصال بالإنترنت',
        code: 'NET_NO_CONNECTION',
      );

  factory NetworkError.timeout() => const NetworkError(
        message: 'انتهت مهلة الاتصال',
        code: 'NET_TIMEOUT',
      );

  factory NetworkError.serverError(int statusCode) => NetworkError(
        message: 'خطأ في الخادم (رمز: $statusCode)',
        code: 'NET_SERVER_ERROR',
      );
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthError.invalidCredentials() => const AuthError(
        message: 'اسم المستخدم أو كلمة المرور غير صحيحة',
        code: 'AUTH_INVALID_CREDENTIALS',
      );

  factory AuthError.sessionExpired() => const AuthError(
        message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
        code: 'AUTH_SESSION_EXPIRED',
      );

  factory AuthError.unauthorized() => const AuthError(
        message: 'ليس لديك صلاحية للقيام بهذه العملية',
        code: 'AUTH_UNAUTHORIZED',
      );

  factory AuthError.biometricFailed() => const AuthError(
        message: 'فشل في التحقق من البصمة',
        code: 'AUTH_BIOMETRIC_FAILED',
      );
}

/// Unknown/Unexpected errors
class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory UnknownError.fromObject(Object error, [StackTrace? stackTrace]) =>
      UnknownError(
        message: 'حدث خطأ غير متوقع: ${error.toString()}',
        code: 'UNKNOWN',
        originalError: error,
        stackTrace: stackTrace,
      );
}

/// Extension to convert any error to AppError
extension ErrorToAppError on Object {
  AppError toAppError() {
    if (this is AppError) return this as AppError;
    return UnknownError.fromObject(this);
  }
}
