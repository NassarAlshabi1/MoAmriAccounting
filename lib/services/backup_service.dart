import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:moamri_accounting/database/my_database.dart';

/// Backup Service
///
/// Provides database backup and restore functionality.
/// Supports local backups, export to file, and scheduled backups.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Backup directory name
  static const String _backupDir = 'MoAmri_Backups';

  /// Maximum number of backups to keep
  static const int maxBackupCount = 10;

  /// Get backup directory path
  Future<String> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, _backupDir));
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir.path;
  }

  /// Create a full backup of the database
  Future<BackupResult> createBackup({String? customName}) async {
    try {
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now();
      final fileName = customName ?? 
          'backup_${_formatTimestamp(timestamp)}.db';
      final backupPath = p.join(backupDir, fileName);

      // Copy database file
      final dbPath = await _getDatabasePath();
      final dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        return BackupResult(
          success: false,
          message: 'قاعدة البيانات غير موجودة',
        );
      }

      await dbFile.copy(backupPath);

      // Create metadata file
      await _createBackupMetadata(backupPath, timestamp);

      // Clean old backups
      await _cleanOldBackups();

      return BackupResult(
        success: true,
        message: 'تم إنشاء النسخة الاحتياطية بنجاح',
        backupPath: backupPath,
        timestamp: timestamp,
        fileSize: await _getFileSize(backupPath),
      );
    } catch (e) {
      debugPrint('Backup error: $e');
      return BackupResult(
        success: false,
        message: 'فشل في إنشاء النسخة الاحتياطية: $e',
      );
    }
  }

  /// Restore database from backup
  Future<BackupResult> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        return BackupResult(
          success: false,
          message: 'ملف النسخة الاحتياطية غير موجود',
        );
      }

      // Close current database connection
      await MyDatabase.close();

      // Get current database path
      final dbPath = await _getDatabasePath();
      final dbFile = File(dbPath);

      // Create a backup of current database before restore
      if (await dbFile.exists()) {
        final preRestoreBackup = '${dbPath}.pre_restore_${DateTime.now().millisecondsSinceEpoch}';
        await dbFile.copy(preRestoreBackup);
      }

      // Copy backup file to database location
      await backupFile.copy(dbPath);

      return BackupResult(
        success: true,
        message: 'تم استعادة النسخة الاحتياطية بنجاح',
        backupPath: backupPath,
      );
    } catch (e) {
      debugPrint('Restore error: $e');
      return BackupResult(
        success: false,
        message: 'فشل في استعادة النسخة الاحتياطية: $e',
      );
    }
  }

  /// Get list of available backups
  Future<List<BackupInfo>> getBackupList() async {
    try {
      final backupDir = await _getBackupDirectory();
      final dir = Directory(backupDir);
      
      if (!await dir.exists()) {
        return [];
      }

      final files = await dir.list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      final backups = <BackupInfo>[];
      
      for (final file in files) {
        final stat = await file.stat();
        final metadata = await _readBackupMetadata(file.path);
        
        backups.add(BackupInfo(
          path: file.path,
          fileName: p.basename(file.path),
          createdAt: stat.modified,
          fileSize: stat.size,
          metadata: metadata,
        ));
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return backups;
    } catch (e) {
      debugPrint('Error getting backup list: $e');
      return [];
    }
  }

  /// Delete a backup
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      final metadataFile = File('$backupPath.json');
      
      if (await file.exists()) {
        await file.delete();
      }
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
      
      return true;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }

  /// Export backup to external location (share)
  Future<void> exportBackup(String backupPath) async {
    try {
      await Share.shareXFiles(
        [XFile(backupPath)],
        subject: 'نسخة احتياطية - MoAmri Accounting',
      );
    } catch (e) {
      debugPrint('Error exporting backup: $e');
      rethrow;
    }
  }

  /// Import backup from external file
  Future<BackupResult> importBackup(String filePath) async {
    try {
      final sourceFile = File(filePath);
      
      if (!await sourceFile.exists()) {
        return BackupResult(
          success: false,
          message: 'الملف غير موجود',
        );
      }

      final backupDir = await _getBackupDirectory();
      final fileName = 'imported_${_formatTimestamp(DateTime.now())}.db';
      final destPath = p.join(backupDir, fileName);
      
      await sourceFile.copy(destPath);
      
      return BackupResult(
        success: true,
        message: 'تم استيراد النسخة الاحتياطية بنجاح',
        backupPath: destPath,
      );
    } catch (e) {
      debugPrint('Error importing backup: $e');
      return BackupResult(
        success: false,
        message: 'فشل في استيراد النسخة الاحتياطية: $e',
      );
    }
  }

  /// Get database path
  Future<String> _getDatabasePath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dbPath = await getDatabasesPath();
      return p.join(dbPath, 'myDb.db');
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      return p.join(appDir.path, 'databases', 'myDb.db');
    }
  }

  /// Create backup metadata file
  Future<void> _createBackupMetadata(String backupPath, DateTime timestamp) async {
    final metadataPath = '$backupPath.json';
    final metadata = {
      'version': '1.0',
      'timestamp': timestamp.toIso8601String(),
      'app_version': '1.0.0', // Should be from package info
      'platform': Platform.operatingSystem,
    };
    
    final file = File(metadataPath);
    await file.writeAsString(jsonEncode(metadata));
  }

  /// Read backup metadata
  Future<Map<String, dynamic>?> _readBackupMetadata(String backupPath) async {
    try {
      final metadataPath = '$backupPath.json';
      final file = File(metadataPath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clean old backups (keep only maxBackupCount)
  Future<void> _cleanOldBackups() async {
    final backups = await getBackupList();
    
    if (backups.length > maxBackupCount) {
      final toDelete = backups.skip(maxBackupCount);
      for (final backup in toDelete) {
        await deleteBackup(backup.path);
      }
    }
  }

  /// Format timestamp for filename
  String _formatTimestamp(DateTime dt) {
    return '${dt.year}${_pad(dt.month)}${_pad(dt.day)}_${_pad(dt.hour)}${_pad(dt.minute)}${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  /// Get file size
  Future<String> _getFileSize(String path) async {
    final file = File(path);
    final bytes = await file.length();
    return _formatFileSize(bytes);
  }

  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get total backup size
  Future<String> getTotalBackupSize() async {
    final backups = await getBackupList();
    int totalBytes = 0;
    for (final backup in backups) {
      totalBytes += backup.fileSize;
    }
    return _formatFileSize(totalBytes);
  }

  /// Schedule automatic backup (to be called on app startup/shutdown)
  Future<void> scheduleAutoBackup() async {
    // Check if auto backup is enabled
    // Check last backup time
    // Create backup if needed
    // This can be extended with shared_preferences for settings
  }
}

/// Backup Result
class BackupResult {
  final bool success;
  final String message;
  final String? backupPath;
  final DateTime? timestamp;
  final String? fileSize;

  BackupResult({
    required this.success,
    required this.message,
    this.backupPath,
    this.timestamp,
    this.fileSize,
  });
}

/// Backup Info
class BackupInfo {
  final String path;
  final String fileName;
  final DateTime createdAt;
  final int fileSize;
  final Map<String, dynamic>? metadata;

  BackupInfo({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    this.metadata,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
