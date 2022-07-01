import 'dart:io';
import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'view/utils/route/empty_page_route.dart';
import 'view/utils/route/fade_page_route.dart';
import 'view/utils/route/rotate_zoom_page_route.dart';
import 'view/utils/route/slider_page_route.dart';
import 'view/utils/route/zoom_page_route.dart';

export 'styles.dart';
export 'view/utils/map_utils.dart';

/// 事件bus
EventBus eventBus = EventBus();

/// 公共函数库
class Utils {
  Utils._();

  /// 运行模式： true 为 debug 模式
  static const bool debug =
      kDebugMode; // !(bool.fromEnvironment("dart.vm.product"));

  /// 当前是否为桌面模式
  static bool get desktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 当前时间戳（毫秒）
  static int get currentTimestamp => DateTime.now().millisecondsSinceEpoch;

  /// 延时指定毫秒
  static sleep(int milliseconds, [VoidCallback? callback]) async {
    if (milliseconds == 0) {
      if (callback != null) callback();
    }
    await Future.delayed(Duration(milliseconds: milliseconds), callback);
  }

  static int random(int max) {
    return Random().nextInt(max) + 1;
  }

  static String randomCode([int len = 8]) {
    const String chars =
        "0123456789abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZa";
    String result = '';
    for (int i = 0; i < len; i++) {
      final j = random(chars.length - 1);
      result += chars.substring(j, j + 1);
    }
    return result;
  }

  static String uuid() {
    final t = currentTimestamp.toString();
    return randomCode(18) + t.substring(t.length - 6) + randomCode(8);
  }

  /// 判断字符串是否为空
  static bool empty(String? src) {
    return src == null || src.isEmpty ? true : false;
  }

  /// 列表转化
  static List<T> toList<T, E>(
      List<dynamic>? source, T Function(E v, int index) generator) {
    var items = <T>[];
    if (source != null && source.isNotEmpty) {
      for (var i = 0; i < source.length; i++) {
        items.add(generator(source[i], i));
      }
    }
    return items;
  }

  /// 复制到剪粘板
  static copy(BuildContext context, String data, {bool? showHint}) {
    Clipboard.setData(ClipboardData(text: data));
    if (showHint != false) toast('复制成功');
  }

  /// 退出应用
  static exitApp() {
    try {
      SystemNavigator.pop();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    try {
      exit(0);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// 显示 Toast 消息
  static toast(String msg,
      {Duration? duration,
      ToastPosition position = ToastPosition.bottom,
      bool? dismissOtherToast}) {
    if (!empty(msg)) {
      showToast(msg,
          position: position,
          duration: duration,
          dismissOtherToast: dismissOtherToast);
    }
  }

  /// 是否拥有焦点
  static hasFocus(BuildContext? context) {
    var f = context == null ? null : FocusScope.of(context);
    return f != null && f.hasFocus;
  }

  /// 清除输入焦点
  static unFocus(BuildContext? context) {
    final f = context == null ? null : FocusScope.of(context);
    if (f != null && f.hasFocus) {
      f.unfocus(disposition: UnfocusDisposition.scope);
    }
  }

  /// 开始一个命名路由页面，并等待结束
  static Future<Object?> startNamedPage<T>(
    BuildContext context,
    String name, {
    Object? arguments,
    LaunchMode launchMode = LaunchMode.standard,
  }) {
    unFocus(context);
    if (launchMode == LaunchMode.standard) {
      return Navigator.pushNamed(
        context,
        name,
        arguments: arguments,
      );
    } else {
      return Navigator.pushNamedAndRemoveUntil(
        context,
        name,
        (route) {
          var isFirst = route.isFirst;
          var routeName = route.settings.name;
          var isSingleTop = launchMode == LaunchMode.singleTop;
          return routeName != name || (isSingleTop && !isFirst);
        },
        arguments: arguments,
      );
    }
  }

  /// 开始一个页面
  /// [isReplacement] 是否用新的页面替换当前页面
  /// [result] replacement 为 true 时，返回上一个页面的数据
  static void startPage(BuildContext context, Widget page,
      {PageAnimation? animation, bool replacement = false, result}) {
    if (replacement) {
      Navigator.pushReplacement(context, getPageRoute(animation, page),
          result: result);
    } else {
      Navigator.push(context, getPageRoute(animation, page));
    }
  }

  /// 开始一个页面，并等待结束
  static Future<T?> startPageWait<T extends Object>(
      BuildContext context, Widget page,
      {PageAnimation? animation}) async {
    unFocus(context);
    return await Navigator.push<T>(context, getPageRoute<T>(animation, page));
  }

  static PageRoute<T> getPageRoute<T>(PageAnimation? animation, Widget page) {
    final route = RouteSettings(name: page.toString());
    PageRoute<T> defaultPageRoute() {
      if (Platform.isIOS) {
        return CupertinoPageRoute<T>(
            builder: (context) => page, settings: route);
      } else {
        return MaterialPageRoute<T>(builder: (_) => page, settings: route);
      }
    }

    if (animation == null) {
      return defaultPageRoute();
    }
    switch (animation) {
      case PageAnimation.fade:
        return FadePageRoute<T>(widget: page, settings: route);
      case PageAnimation.empty:
        return EmptyPageRoute<T>(widget: page, settings: route);
      case PageAnimation.sliderLeft:
        return SliderPageRoute<T>(
            transition: SliderPageRouteType.left,
            builder: (_) => page,
            settings: route);
      case PageAnimation.sliderTop:
        return SliderPageRoute<T>(
            transition: SliderPageRouteType.top,
            builder: (_) => page,
            settings: route);
      case PageAnimation.sliderRight:
        return SliderPageRoute<T>(
            transition: SliderPageRouteType.right,
            builder: (_) => page,
            settings: route);
      case PageAnimation.sliderBottom:
        return SliderPageRoute<T>(
            transition: SliderPageRouteType.bottom,
            builder: (_) => page,
            settings: route);
      case PageAnimation.zoom:
        return ZoomPageRoute<T>(widget: page, settings: route);
      case PageAnimation.rotateZoom:
        return RotateZoomPageRoute<T>(widget: page, settings: route);
      default:
        return defaultPageRoute();
    }
  }

  /// 获取屏幕宽度
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取屏幕高度
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 获取系统状态栏高度
  static double getSysStatsHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 请求权限
  static Future<bool> requestPermission(
      {Permission permission = Permission.storage,
      bool desktopIgnore = true}) async {
    if (desktop && desktopIgnore == true) return true;
    try {
      if (await permission.isGranted || await permission.isDenied) {
        final v = await permission.request();
        if (v != PermissionStatus.granted) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 页面切换动画类型
enum PageAnimation {
  /// 无动画
  empty,

  /// 淡入淡出 (默认)
  fade,

  /// 左入左出
  sliderLeft,

  /// 左入左出
  sliderRight,

  /// 上入上出
  sliderTop,

  /// 下入下出
  sliderBottom,

  /// 缩放
  zoom,

  /// 旋转缩放
  rotateZoom
}

enum LaunchMode {
  standard,
  singleTop,
  singleTask,
}
