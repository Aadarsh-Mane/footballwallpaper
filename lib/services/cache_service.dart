import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  final BaseCacheManager _cacheManager = CacheManager(
    Config(
      "customCache",
      stalePeriod: Duration(minutes: 20),
      maxNrOfCacheObjects: 10,
    ),
  );

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  Future<void> initializeCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClearTime = prefs.getInt('lastCacheClearTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration = Duration(days: 7).inMilliseconds;

    if (currentTime - lastClearTime > cacheDuration) {
      await _cacheManager.emptyCache();
      await prefs.setInt('lastCacheClearTime', currentTime);
    }
  }

  BaseCacheManager get cacheManager => _cacheManager;
}
