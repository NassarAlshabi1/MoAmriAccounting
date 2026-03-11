import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Password Security Helper
/// Provides methods for secure password hashing and verification
///
/// Uses SHA-256 with salt for password hashing
/// For production, consider using bcrypt or Argon2 via native libraries

class PasswordSecurity {
  PasswordSecurity._();

  /// Generate a random salt
  static String generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return _hashString('$timestamp$random').substring(0, 16);
  }

  /// Hash a password with salt
  static String hashPassword(String password, String salt) {
    final saltedPassword = '$password$salt';
    return _hashString(saltedPassword);
  }

  /// Verify a password against a hash
  static bool verifyPassword({
    required String password,
    required String hashedPassword,
    required String salt,
  }) {
    final newHash = hashPassword(password, salt);
    return newHash == hashedPassword;
  }

  /// Internal hash function using SHA-256
  static String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a password is already hashed (basic check)
  static bool isHashed(String password) {
    // SHA-256 produces 64 character hex strings
    return password.length == 64 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(password);
  }
}

/// Simple encryption helper for sensitive data
/// Uses base64 encoding (NOT secure for production - use proper encryption)
class DataEncryption {
  DataEncryption._();

  /// Encode data (for obfuscation only - not secure encryption)
  static String encode(String data) {
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// Decode data
  static String decode(String encoded) {
    try {
      final bytes = base64Decode(encoded);
      return utf8.decode(bytes);
    } catch (e) {
      return '';
    }
  }

  /// Check if string is base64 encoded
  static bool isEncoded(String data) {
    try {
      base64Decode(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Session security helper
class SessionSecurity {
  SessionSecurity._();

  /// Generate a session token
  static String generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return PasswordSecurity._hashString('$timestamp$random${DateTime.now()}');
  }

  /// Check if session is expired
  static bool isSessionExpired(DateTime lastActivity, {int timeoutMinutes = 30}) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inMinutes > timeoutMinutes;
  }
}

/// Audit Logger for security events
class SecurityAuditLogger {
  static final List<SecurityEvent> _events = [];

  /// Log a security event
  static void log({
    required String action,
    required int? userId,
    required String details,
    required bool success,
  }) {
    _events.add(SecurityEvent(
      timestamp: DateTime.now(),
      action: action,
      userId: userId,
      details: details,
      success: success,
    ));

    // Keep only last 100 events
    if (_events.length > 100) {
      _events.removeAt(0);
    }
  }

  /// Get all security events
  static List<SecurityEvent> getEvents() => List.unmodifiable(_events);

  /// Get failed login attempts
  static List<SecurityEvent> getFailedLoginAttempts({int? forUserId}) {
    return _events.where((e) {
      if (e.action != 'login') return false;
      if (e.success) return false;
      if (forUserId != null && e.userId != forUserId) return false;
      return true;
    }).toList();
  }

  /// Clear old events
  static void clearOldEvents({int keepDays = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    _events.removeWhere((e) => e.timestamp.isBefore(cutoff));
  }
}

/// Security Event model
class SecurityEvent {
  final DateTime timestamp;
  final String action;
  final int? userId;
  final String details;
  final bool success;

  const SecurityEvent({
    required this.timestamp,
    required this.action,
    required this.userId,
    required this.details,
    required this.success,
  });

  @override
  String toString() =>
      'SecurityEvent($timestamp, $action, userId: $userId, success: $success)';
}
