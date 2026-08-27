import 'package:hive_flutter/hive_flutter.dart';

/// Generic key/value cache on top of a single Hive box. Every entry is
/// stamped with the time it was written so reads can enforce the 24h
/// expiry without needing a Hive TypeAdapter per cached shape — callers
/// hand over/receive plain maps and lists of primitives.
class HiveCacheService {
  static const String boxName = 'app_cache_box';
  static const Duration cacheDuration = Duration(hours: 24);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  Future<void> save(String key, dynamic data) async {
    await _box.put(key, {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Returns the cached payload for [key], or `null` if there's no entry
  /// or the entry is older than [cacheDuration].
  dynamic read(String key) {
    final entry = _box.get(key);
    if (entry == null) return null;
    final map = entry as Map;
    final cachedAt = DateTime.tryParse(map['cachedAt'] as String? ?? '');
    if (cachedAt == null) return null;
    if (DateTime.now().difference(cachedAt) > cacheDuration) return null;
    return map['data'];
  }

  Future<void> clear(String key) => _box.delete(key);
}
