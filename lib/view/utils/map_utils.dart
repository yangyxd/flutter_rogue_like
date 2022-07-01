// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:ui';

/// Map 扩展
extension MapExtension on Map {
  /// 取对象
  _Set<Object?> get o => _Set((key) => key == null ? null : this[key]);
  /// 取字符串
  _Set<String> get s => _Set((key) => getString(key));
  /// 取整数
  _Set<int> get i => _Set<int>((key) => getInt(key));
  /// 取浮点数
  _Set<double> get f => _Set<double>((key) => getFloat(key));
  /// 取日期时间
  _Set<DateTime?> get d => _Set<DateTime?>((key) => getDateTime(key));
  /// 取列表
  _Set<List<dynamic>> get list => _Set<List<dynamic>>((key) => getList(key, (item) => item));

  /// 获取字符串
  String getString(final String? key, [final String defaultValue = '']) {
    if (key == null) return defaultValue;
    var _v = this[key];
    if (_v == null) return defaultValue;
    if (_v is String) return _v;
    return "$_v";
  }

  /// 获取整数
  int getInt(final String? key, [final int defaultValue = 0]) {
    if (key == null) return defaultValue;
    var _v = this[key];
    if (_v == null) return defaultValue;
    if (_v is int) return _v;
    return toInt("$_v", 0);
  }

  /// 获取浮点数
  double getFloat(final String? key, [final double defaultValue = 0.0]) {
    if (key == null) return defaultValue;
    return toFloat(this[key], defaultValue);
  }

  /// 获取时间
  DateTime? getDateTime(final String? key, [final DateTime? defaultValue]) {
    if (key == null) return defaultValue;
    Object? v = this[key];
    if (v == null) return defaultValue;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return toDateTime("$v", defaultValue);
  }

  /// 获取列表
  /// [initClassCallback] - 根据item生成[T]类实例
  List<T> getList<T>(final String? key, T Function(dynamic item)? initClassCallback) {
    List<T> items = [];
    if (key == null) return items;
    Object? _items = this[key];
    if (_items != null && (_items is List) && initClassCallback != null) {
      for (var item in _items) {
        items.add(initClassCallback(item));
      }
    }
    return items;
  }

  /// 转为 JSON 字符串
  String toJson() {
    return const JsonEncoder().convert(this);
  }

  /// Json 对象转为 Map
  static Map fromJson(final String data) {
    return const JsonDecoder().convert(data);
  }

  /// 字符串转为整数
  static int toInt(Object? value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    try {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.parse(value as String);
    } catch (e) {
      return defaultValue;
    }
  }

  /// 字符串转为整数
  static double toFloat(Object? value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }

  /// 将对象转为字符串，如果是浮点数，小数点后没有值只当成整数
  static String toStr(Object? value, [String defaultValue = ""]) {
    if (value == null) return defaultValue;
    if (value is double) {
      if (value == value.toInt()) return value.toInt().toString();
      return value.toString();
    }
    if (value is Color) return '0x' + value.value.toRadixString(16);
    return value.toString();
  }

  /// 字符串转为日期时间
  static DateTime? toDateTime(String str, [DateTime? defaultValue]) {
    try {
      return DateTime.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }
}

class _Set<T> {
  final T Function(String? key) onGetData;
  _Set(this.onGetData);

  T operator [](final String? key) {
    return onGetData(key);
  }
}
