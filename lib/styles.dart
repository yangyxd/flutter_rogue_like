import 'dart:ui';

import 'package:flutter/services.dart';

/// 样式
class Styles {
  /// 全局默认字体
  static const String fontFamily = 'Roboto';

  /// 默认 Elevation
  static const double elevation = 0.3;

  /// 边框粗细
  static const double borderSize = 0.3;

  /// 列表分隔线高度
  static const double lineSize = 0.35;

  /// 分隔线高度
  static const double normalLineSize = 0.5;


  static SystemUiOverlayStyle uiStyle = const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xff000000),
    systemNavigationBarDividerColor: null,
    statusBarColor: Color(0x00000000),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  );

  /// 使用App样式
  static useAppStyle() {
    SystemChrome.setSystemUIOverlayStyle(uiStyle);
  }

}