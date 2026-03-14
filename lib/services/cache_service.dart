import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Cache Service
///
/// Provides caching capabilities to improve app performance.
/// Uses GetStorage for local caching with TTL (Time To Live) support.
class CacheService extends GetxService {
  static CacheService get to => Get.find();
  
  final _storage = GetStorage();
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'cache_ts_';
  static const String _defaultTTL = 'default_ttl';

  /// Default TTL in seconds (30 minutes)
  static const int defaultTTLSeconds = 1800;

  /// Initialize cache service
  Future<CacheService> init() async {
    await GetStorage.init();
    return this;
  }

  /// Store data in cache with optional TTL
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
  }) async {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';
    
    final json = jsonEncode(data);
    await _storage.write(cacheKey, json);
    
    // Store expiration timestamp
    final expirationTime = DateTime.now().add(ttl ?? const Duration(seconds: defaultTTLSeconds));
    await _storage.write(timestampKey, expirationTime.millisecondsSinceEpoch);
  }

  /// Get data from cache
  T? get<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';
    
    // Check if cache exists
    if (!_storage.hasData(cacheKey)) {
      return null;
    }

    // Check if cache has expired
    if (_isExpired(timestampKey)) {
      remove(key);
      return null;
    }

    // Parse and return cached data
    try {
      final json = _storage.read(cacheKey) as String;
      final map = jsonDecode(json) as Map<String, dynamic>;
      return fromJson(map);
    } catch (e) {
      remove(key);
      return null;
    }
  }

  /// Get list from cache
  List<T>? getList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';
    
    if (!_storage.hasData(cacheKey)) {
      return null;
    }

    if (_isExpired(timestampKey)) {
      remove(key);
      return null;
    }

    try {
      final json = _storage.read(cacheKey) as String;
      final list = jsonDecode(json) as List;
      return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      remove(key);
      return null;
    }
  }

  /// Get or set cache (lazy loading)
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    // Try to get from cache first
    final cached = get<T>(key, fromJson);
    if (cached != null) {
      return cached;
    }

    // Fetch fresh data
    final data = await fetcher();
    await set(key, data, ttl: ttl);
    return data;
  }

  /// Get or set list (lazy loading)
  Future<List<T>>> getOrSetList<T>(
    String key,
    Future<List<T>>> Function() fetcher, {
    Duration? ttl,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final cached = getList<T>(key, fromJson);
    if (cached != null) {
      return cached;
    }

    final data = await fetcher();
    await set(key, data, ttl: ttl);
    return data;
  }

  /// Check if cache entry is expired
  bool _isExpired(String timestampKey) {
    if (!_storage.hasData(timestampKey)) {
      return true;
    }

    final expirationTime = _storage.read(timestampKey) as int;
    return DateTime.now().millisecondsSinceEpoch > expirationTime;
  }

  /// Remove specific cache entry
  Future<void> remove(String key) async {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';
    await _storage.remove(cacheKey);
    await _storage.remove(timestampKey);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    final keys = _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
        await _storage.remove(key);
      }
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpired() async {
    final keys = _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith(_timestampPrefix)) {
        if (_isExpired(key)) {
          final cacheKey = key.replaceFirst(_timestampPrefix, _cachePrefix);
          await _storage.remove(cacheKey);
          await _storage.remove(key);
        }
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final keys = _storage.getKeys();
    int totalEntries = 0;
    int expiredEntries = 0;

    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        totalEntries++;
        final timestampKey = key.replaceFirst(_cachePrefix, _timestampPrefix);
        if (_isExpired(timestampKey)) {
          expiredEntries++;
        }
      }
    }

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'validEntries': totalEntries - expiredEntries,
    };
  }
}

/// Cache Keys Constants
class CacheKeys {
  static const String materials = 'materials';
  static const String categories = 'categories';
  static const String customers = 'customers';
  static const String currencies = 'currencies';
  static const String debts = 'debts';
  static const String invoices = 'invoices';
  static const String dashboardStats = 'dashboard_stats';
  static const String recentTransactions = 'recent_transactions';
  static const String storeData = 'store_data';
}

/// Cache Durations
class CacheDurations {
  static const Duration short = Duration(minutes: 5);
  static const Duration medium = Duration(minutes: 30);
  static const Duration long = Duration(hours: 2);
  static const Duration veryLong = Duration(hours: 24);
}
