import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> save(String key, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await _prefs.setString(key, jsonString);
  }

  Map<String, dynamic>? load(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String key) async {
    await _prefs.remove(key);
  }
}
