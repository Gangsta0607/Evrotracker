import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracking_result.dart'; // Убедитесь, что путь верный

class TrackingCacheService {
  static const _cacheDuration = Duration(minutes: 30);

  // Получить результат из кэша
  Future<TrackingResult?> get(String trackNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'cache_$trackNumber';
    final cachedData = prefs.getString(key);
    if (cachedData == null) return null;

    try {
      final jsonMap = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(jsonMap['timestamp']);

      // Проверяем, не истек ли срок действия кэша
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        prefs.remove(key); // Удаляем просроченный кэш
        return null;
      }

      return TrackingResult.fromJson(jsonMap['data']);
    } catch (e) {
      return null; // Ошибка парсинга, считаем кэш невалидным
    }
  }

  // Сохранить результат в кэш
  Future<void> set(String trackNumber, TrackingResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'cache_$trackNumber';

    final dataToCache = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': result.toJson(),
    };

    await prefs.setString(key, jsonEncode(dataToCache));
  }
}