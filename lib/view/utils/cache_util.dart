// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;

import '../../consts.dart';
import '../../utils.dart';

/// 缓存管理工具类
class CacheUtil {
  static const String _basePath = 'cache';
  static String? _cacheBasePath, _cacheStoragePath;

  /// 缓存名称
  final String? cacheName;
  /// 基路径
  final String? basePath;
  /// 是否优先存储卡
  final bool? storage;

  CacheUtil({this.cacheName, this.basePath, this.storage});

  String? _cacheDir;

  Future<bool> tryRequestPermission() async {
    try {
      return await Utils.requestPermission();
    } catch (e) {
      return false;
    }
  }

  Future<String?> cacheDir([bool? allCache]) async {
    if (_cacheDir != null && allCache != true) return _cacheDir!;
    tryRequestPermission();
    var dir = await getCacheBasePath(storage);
    if (dir == null || dir.isEmpty) return null;
    dir = dir + _separator + Consts.appName;
    if (basePath == null || basePath!.isEmpty) {
      dir = dir + _separator + _basePath;
    } else {
      dir = dir + _separator + basePath!;
    }
    if (allCache == true) {
      return dir + _separator;
    }
    if (cacheName != null && cacheName!.isNotEmpty) {
      dir = dir + _separator + cacheName!.hashCode.toString();
    }
    _cacheDir = dir + _separator;
    if (kDebugMode) {
      print('cache dir: $_cacheDir');
    }
    return _cacheDir;
  }

  Future<String?> getFileName(String key, bool hashCodeKey) async {
    var dir = _cacheDir ?? await cacheDir();
    if (dir == null || dir.isEmpty) return null;
    return dir + (hashCodeKey ? '${key.hashCode}.data' : key);
  }

  String? getFileNameSync(String key, bool hashCodeKey) {
    var dir = _cacheDir;
    if (dir == null || dir.isEmpty) return null;
    return dir + (hashCodeKey ? '${key.hashCode}.data' : key);
  }

  /// 写入文件, 返回新文件的路径
  Future<String?> putFile(String key, File file) async {
    var fileName = await getFileName(key, false);
    if (fileName == null || fileName.isEmpty) {
      return null;
    }
    File? cacheFile = await createFile(fileName, path: _cacheDir);
    if (cacheFile == null) return null;
    final bytes = file.readAsBytesSync();
    await cacheFile.writeAsBytes(bytes);
    return fileName;
  }

  /// 写入文件, 返回新文件的路径
  Future<String?> putFileString(String key, String data) async {
    return await putFileBytes(key, const Utf8Encoder().convert(data));
  }

  /// 写入文件, 返回新文件的路径
  Future<String?> putFileBytes(String key, Uint8List? bytes) async {
    var fileName = await getFileName(key, false);
    if (fileName == null || fileName.isEmpty) {
      return null;
    }
    File? cacheFile = await createFile(fileName, path: _cacheDir);
    if (cacheFile == null) return null;
    await cacheFile.writeAsBytes(bytes ?? []);
    return fileName;
  }

  Future<void> removeFile(String key) async {
    var fileName = await getFileName(key, false);
    if (fileName == null || fileName.isEmpty) {
      return;
    }
    final f = File(fileName);
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  /// 写入 key
  Future<bool> put(String? key, String? value, [bool hashCodeKey = true]) async {
    if (key == null || key.isEmpty) {
      return false;
    }
    var _file = await getFileName(key, hashCodeKey);
    if (_file == null || _file.isEmpty) {
      return false;
    }
    File? _cacheFile = await createFile(_file, path: _cacheDir);
    if (_cacheFile == null) return false;
    if (value != null && value.isNotEmpty) {
      await _cacheFile.writeAsString(value, flush: false);
    }
    return true;
  }

  /// 获取 key 对应的数据
  Future<String?> get(String? key, [String? defaultValue, bool hashCodeKey = true]) async {
    if (key == null || key.isEmpty) {
      return defaultValue;
    }
    var _file = await getFileName(key, hashCodeKey);
    if (_file == null || _file.isEmpty) {
      return defaultValue;
    }
    File _cacheFile = File(_file);
    if (_cacheFile.existsSync()) {
      return _cacheFile.readAsStringSync();
    }
    return defaultValue;
  }

  Future<bool> putData(String key, Object value, [bool hashCodeKey = true]) async {
    return await put(key, jsonEncode(value), hashCodeKey);
  }

  bool existData(String? key, [bool hashCodeKey = true]) {
    if (key == null || key.isEmpty) return false;
    var _file = getFileNameSync(key, hashCodeKey);
    if (_file == null || _file.isEmpty) return false;
    return File(_file).existsSync();
  }

  Future<dynamic> getData(String key, [Object? defaultValue, bool hashCodeKey = true]) async {
    final value = await get(key, null, hashCodeKey);
    if (value == null || value.isEmpty) return defaultValue;
    return jsonDecode(value);
  }

  Future<List<T>> getListData<T>(String key, [bool hashCodeKey = true]) async {
    final value = await get(key, null, hashCodeKey);
    if (value == null || value.isEmpty) return [];
    final _data = jsonDecode(value);
    if (_data != null && _data is List) {
      return _data as List<T>;
    }
    return [];
  }

  setInt(String key, int value) async {
    await putData(key, {'value': value, 'type': 'int'}, false);
  }

  setDouble(String key, double value) async {
    await putData(key, {'value': value, 'type': 'double'}, false);
  }

  setBool(String key, bool value) async {
    await putData(key, {'value': value, 'type': 'bool'}, false);
  }

  setStringList(String key, List<String> value) async {
    await putData(key, {'value': value, 'type': 'sl'}, false);
  }

  setString(String key, String value) async {
    await put(key, value, false);
  }

  String? getSync(String? key, [String? defaultValue, bool hashCodeKey = true]) {
    if (key == null || key.isEmpty) {
      return defaultValue;
    }
    var _file = getFileNameSync(key, hashCodeKey);
    if (_file == null || _file.isEmpty) {
      return defaultValue;
    }
    File _cacheFile = File(_file);
    if (_cacheFile.existsSync()) {
      return _cacheFile.readAsStringSync();
    }
    return defaultValue;
  }

  dynamic getDataSync(String key, [Object? defaultValue]) {
    final value = getSync(key, null, false);
    if (value == null || value.isEmpty) return defaultValue;
    return jsonDecode(value);
  }

  int? getInt(String key) {
    final value = getDataSync(key, null);
    if (value != null && value is Map && (value)['type'] == 'int') {
      return (value)['value'] as int;
    } else {
      return null;
    }
  }

  bool? getBool(String key) {
    final value = getDataSync(key, null);
    if (value != null && value is Map && value['type'] == 'bool') {
      return (value)['value'] as bool;
    } else {
      return null;
    }
  }

  List<String>? getStringList(String key) {
    final value = getDataSync(key, null);
    if (value != null && value is Map && value['type'] == 'sl') {
      return ((value)['value'] as List<dynamic>).map((e) {
        return e.toString();
      }).toList();
    } else {
      return null;
    }
    // await putData(key, {'value': value, 'type': 'sl'}, false);
  }

  /// 清理缓存
  /// [allCache] 清除所有缓存
  Future<void> clear({bool? allCache}) async {
    try {
      await Utils.requestPermission();
      var dir = await cacheDir(allCache);
      if (dir == null || dir.isEmpty) return;
      Directory _dir = Directory(dir);
      if (!_dir.existsSync()) return;
      await _dir.delete(recursive: true).then((value) {
        // print(value);
      }).catchError((_) => _);
    } catch (_) {}
  }

  /// 路径分隔符
  static String get _separator => Platform.pathSeparator;

  /// 获取缓存放置目录 (写了一堆，提升兼容性）
  static Future<String?> getCacheBasePath([bool? storage]) async {
    if (_cacheStoragePath == null) {
      try {
        if (Utils.desktop) {
          _cacheStoragePath = (await path.getApplicationDocumentsDirectory()).path;
        } else if (Platform.isAndroid) {
          _cacheStoragePath =  (await path.getExternalStorageDirectory())?.path;
          if (_cacheStoragePath != null && _cacheStoragePath!.isNotEmpty) {
            const _subStr = 'storage/emulated/0/';
            var index = _cacheStoragePath!.indexOf(_subStr);
            if (index >= 0) {
              _cacheStoragePath =
                  _cacheStoragePath!.substring(0, index + _subStr.length - 1);
            }
          }
        } else {
          _cacheStoragePath = (await path.getApplicationDocumentsDirectory()).path;
        }
      } catch (_) {}
    }
    if (_cacheBasePath == null) {
      _cacheBasePath = (await path.getApplicationDocumentsDirectory()).path;
      if (_cacheBasePath == null || _cacheBasePath!.isEmpty) {
        _cacheBasePath = (await path.getApplicationSupportDirectory()).path;
        if (_cacheBasePath == null || _cacheBasePath!.isEmpty) {
          _cacheBasePath = (await path.getTemporaryDirectory()).path;
        }
      }
      if (_cacheStoragePath == null || _cacheStoragePath!.isEmpty) {
        _cacheStoragePath = _cacheBasePath;
      }
    }
    return storage == true ? _cacheStoragePath : _cacheBasePath;
  }

  static String getFilePath(final String file) {
    return path.dirname(file) + _separator;
  }

  static bool existPath(final String _path) {
    return Directory(_path).existsSync();
  }

  static Future<bool> createPath(final String path) async {
    return (await Directory(path).create(recursive: true)).exists();
  }

  static Future<File?> createFile(final String file, {String? path}) async {
    try {
      String _path = path ?? getFilePath(file);
      if (!existPath(_path)) {
        if (!await createPath(_path)) {
          return null;
        }
      }
      return await File(file).create(recursive: true);
    } catch (_) {
      return null;
    }
  }

}