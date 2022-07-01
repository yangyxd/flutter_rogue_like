import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils.dart';
import 'cache_util.dart';

/// SharedPreferences 本地存储
class LocalStorage {

  static SharedPreferences? prefs;
  static CacheUtil? cache;
  static bool isInit = false;

  static bool get isCache => Platform.isWindows || Platform.isMacOS;

  static Future<void> init() async {
    if (isInit) {
      if (kDebugMode) {
        print("init LocalStorage.");
      }
    }
    if (Utils.desktop) {
      if (cache == null) {
        cache = CacheUtil(cacheName: 'prefs.json', storage: true);
        await Utils.requestPermission();
        await cache!.cacheDir();
      }
    } else {
      prefs ??= await SharedPreferences.getInstance();
    }
    isInit = true;
  }

  static Future<bool> set(String key, value) async {
    try {
      if (isCache) {
        if (value is int) {
          await cache!.setInt(key, value);
        } else if (value is double) {
          await cache!.setDouble(key, value);
        } else if (value is bool) {
          await cache!.setBool(key, value);
        } else if (value is List<String>) {
          await cache!.setStringList(key, value);
        } else if (value is Map) {
          await cache!.setString(key, const JsonEncoder().convert(value));
        } else if (value is List) {
          await cache!.setString(key, const JsonEncoder().convert(value));
        } else {
          await cache!.setString(key, value);
        }
      } else {
        if (value is int) {
          await prefs!.setInt(key, value);
        } else if (value is double) {
          await prefs!.setDouble(key, value);
        } else if (value is bool) {
          await prefs!.setBool(key, value);
        } else if (value is List<String>) {
          await prefs!.setStringList(key, value);
        } else if (value is Map) {
          await prefs!.setString(key, const JsonEncoder().convert(value));
        } else if (value is List) {
          await prefs!.setString(key, const JsonEncoder().convert(value));
        } else {
          await prefs!.setString(key, value);
        }
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("SharedDataUtils set err: $key, $value");
      }
      return false;
    }
  }

  static save(String key, value) {
    set(key, value);
  }

  static String get(String key, [String defaultValue = '']) {
    try {
      final value = isCache ? cache!.getSync(key, null, false) : prefs!.get(key);
      if (value == null) return defaultValue;
      return value.toString();
    } catch (e) {
      return defaultValue;
    }
  }

  static String getString(String key, [String defaultValue = '']) {
    return get(key, defaultValue);
  }

  static int getInt(String key, [int defaultValue = 0]) {
    try {
      var value = isCache ? cache!.getInt(key) : prefs!.get(key);
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.round();
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    try {
      var value = isCache ? cache!.getBool(key) : prefs!.get(key);
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value == "true" || value == "yes" || value == "1";
      }
      if (value is int) {
        return value != 0;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static double getFloat(String key, [double defaultValue = 0.0]) {
    try {
      var value = isCache ? cache!.getDataSync(key) : prefs!.get(key);
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }

  static Map<dynamic, dynamic>? getMap(String key, [Map<dynamic, dynamic>? defaultValue]) {
    try {
      var value = isCache ? cache!.getDataSync(key) : prefs!.get(key);
      if (value == null) return defaultValue;
      if (value is String) return const JsonDecoder().convert(value);
    } catch (_) {}
    return defaultValue;
  }

  static List<dynamic> getList(String key, [List<dynamic>? defaultValue]) {
    try {
      var value = isCache ? cache!.getDataSync(key) : prefs!.get(key);
      if (value == null) return defaultValue ?? [];
      if (value is List<String>) return value;
      if (value is String) return const JsonDecoder().convert(value);
    } catch (_) {}
    return defaultValue ?? [];
  }

  static List<String> getStringList(String key, [List<String>? defaultValue]) {
    try {
      var value = isCache ? cache!.getStringList(key) : prefs!.getStringList(key);
      if (value == null) return defaultValue ?? [];
      return value;
    } catch (_) {}
    return defaultValue ?? [];
  }

  static remove(String key) async {
    try {
      if (isCache) {
        if (cache!.existData(key, false)) {
          cache!.removeFile(key);
        }
      } else if (prefs!.containsKey(key)) {
        await prefs!.remove(key);
      }
    } catch (_) {}
  }

}
