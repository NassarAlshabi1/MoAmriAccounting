import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Biometric Authentication Service
/// Handles fingerprint, Face ID, and other biometric authentication methods
class BiometricService extends GetxService {
  static BiometricService get to => Get.find();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final _isBiometricAvailable = false.obs;
  final _isBiometricEnabled = false.obs;
  final _biometricType = BiometricType.none.obs;
  final _isAuthenticating = false.obs;
  final _hasSavedCredentials = false.obs;

  // Getters
  bool get isBiometricAvailable => _isBiometricAvailable.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  BiometricType get biometricType => _biometricType.value;
  bool get isAuthenticating => _isAuthenticating.value;
  bool get hasSavedCredentials => _hasSavedCredentials.value;

  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedUsernameKey = 'biometric_saved_username';
  static const String _savedPasswordKey = 'biometric_saved_password';

  /// Initialize biometric service
  Future<void> init() async {
    await checkBiometricAvailability();
    await _loadBiometricSettings();
    _checkSavedCredentials();
  }

  /// Check if biometric authentication is available on the device
  Future<void> checkBiometricAvailability() async {
    try {
      // Check if device supports biometrics
      final isAvailable = await _localAuth.canCheckBiometrics;
      _isBiometricAvailable.value = isAvailable;

      if (isAvailable) {
        // Get available biometric types
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        
        if (availableBiometrics.isNotEmpty) {
          _biometricType.value = availableBiometrics.first;
          
          if (kDebugMode) {
            print('Available biometrics: $availableBiometrics');
            print('Primary biometric type: ${_biometricType.value}');
          }
        }
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error checking biometric availability: ${e.message}');
      }
      _isBiometricAvailable.value = false;
      _biometricType.value = BiometricType.none;
    }
  }

  /// Load biometric settings from storage
  Future<void> _loadBiometricSettings() async {
    _isBiometricEnabled.value = _storage.read(_biometricEnabledKey) ?? false;
  }

  /// Check if credentials are saved
  void _checkSavedCredentials() {
    final username = _storage.read<String>(_savedUsernameKey);
    final password = _storage.read<String>(_savedPasswordKey);
    _hasSavedCredentials.value = username != null && password != null;
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(_biometricEnabledKey, enabled);
    _isBiometricEnabled.value = enabled;
    
    if (!enabled) {
      // Clear saved credentials when disabled
      await clearSavedCredentials();
    }
  }

  /// Save user credentials for biometric login
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(_savedUsernameKey, username);
    await _storage.write(_savedPasswordKey, password);
    _hasSavedCredentials.value = true;
  }

  /// Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    final username = _storage.read<String>(_savedUsernameKey);
    final password = _storage.read<String>(_savedPasswordKey);
    
    if (username != null && password != null) {
      return {
        'username': username,
        'password': password,
      };
    }
    return null;
  }

  /// Clear saved credentials
  Future<void> clearSavedCredentials() async {
    await _storage.remove(_savedUsernameKey);
    await _storage.remove(_savedPasswordKey);
    _hasSavedCredentials.value = false;
  }

  /// Authenticate with biometrics
  /// Returns true if authentication is successful
  Future<BiometricResult> authenticate({
    String localizedReason = 'يرجى المصادقة للوصول إلى حسابك',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    if (!isBiometricAvailable) {
      return BiometricResult(
        success: false,
        error: BiometricError.notAvailable,
        message: 'البصمة غير متوفرة على هذا الجهاز',
      );
    }

    try {
      _isAuthenticating.value = true;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      _isAuthenticating.value = false;

      if (didAuthenticate) {
        return BiometricResult(
          success: true,
          message: 'تمت المصادقة بنجاح',
        );
      } else {
        return BiometricResult(
          success: false,
          error: BiometricError.authenticationFailed,
          message: 'فشل في المصادقة',
        );
      }
    } on PlatformException catch (e) {
      _isAuthenticating.value = false;
      
      return _handleAuthError(e);
    }
  }

  /// Handle authentication errors
  BiometricResult _handleAuthError(PlatformException e) {
    BiometricError error;
    String message;

    switch (e.code) {
      case auth_error.notAvailable:
        error = BiometricError.notAvailable;
        message = 'البصمة غير متوفرة على هذا الجهاز';
        break;
      case auth_error.notEnrolled:
        error = BiometricError.notEnrolled;
        message = 'لم يتم تسجيل أي بصمة على الجهاز';
        break;
      case auth_error.lockedOut:
        error = BiometricError.lockedOut;
        message = 'تم قفل البصمة مؤقتاً. حاول مرة أخرى لاحقاً';
        break;
      case auth_error.permanentlyLockedOut:
        error = BiometricError.permanentlyLockedOut;
        message = 'تم قفل البصمة نهائياً. يرجى فتح الجهاز بكلمة المرور';
        break;
      case auth_error.passcodeNotSet:
        error = BiometricError.passcodeNotSet;
        message = 'لم يتم تعيين رمز مرور على الجهاز';
        break;
      default:
        error = BiometricError.unknown;
        message = 'حدث خطأ غير متوقع: ${e.message}';
    }

    return BiometricResult(
      success: false,
      error: error,
      message: message,
    );
  }

  /// Get biometric type name in Arabic
  String getBiometricTypeName() {
    switch (_biometricType.value) {
      case BiometricType.fingerprint:
        return 'بصمة الإصبع';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'التعرف على القزحية';
      case BiometricType.strong:
        return 'البصمة البيومترية';
      case BiometricType.weak:
        return 'البصمة الضعيفة';
      default:
        return 'البصمة';
    }
  }

  /// Get biometric icon based on type
  IconData getBiometricIcon() {
    switch (_biometricType.value) {
      case BiometricType.fingerprint:
        return Icons.fingerprint_rounded;
      case BiometricType.face:
        return Icons.face_retouching_natural_rounded;
      case BiometricType.iris:
        return Icons.remove_red_eye_rounded;
      default:
        return Icons.fingerprint_rounded;
    }
  }

  /// Stop authentication if in progress
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      _isAuthenticating.value = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping authentication: $e');
      }
    }
  }
}

/// Biometric authentication result
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Biometric error types
enum BiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  passcodeNotSet,
  authenticationFailed,
  unknown,
}
