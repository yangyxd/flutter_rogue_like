import 'package:flutter/material.dart';

// 滑动效果
class SliderPageRoute<T> extends MaterialPageRoute<T> {
  /// 动画类型
  final SliderPageRouteType transition;

  SliderPageRoute(
      {required WidgetBuilder builder,
      RouteSettings? settings,
      required this.transition})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute) return child;
    if (transition == SliderPageRouteType.left) {
      return SlideTransition(
          position: animation.drive(getAni(0)), child: child);
    } else if (transition == SliderPageRouteType.right) {
      return SlideTransition(
          position: animation.drive(getAni(1)), child: child);
    } else if (transition == SliderPageRouteType.top) {
      return SlideTransition(
          position: animation.drive(getAni(2)), child: child);
    } else if (transition == SliderPageRouteType.bottom) {
      return SlideTransition(
          position: animation.drive(getAni(3)), child: child);
    }
    return child;
  }

  static final tweenItems = [
    Tween<Object>(begin: const Offset(-1.0, 0.0), end: Offset.zero), // left in
    Tween<Object>(begin: const Offset(1.0, 0.0), end: Offset.zero), // right in
    Tween<Object>(begin: const Offset(0.0, -1.0), end: Offset.zero), // top in
    Tween<Object>(begin: const Offset(0.0, 1.0), end: Offset.zero), // bottom in
  ];

  Tween<Object> getTween(int flag) {
    return tweenItems[flag];
  }

  Animatable<Offset> getAni(int flag) {
    return getTween(flag).chain(CurveTween(curve: Curves.ease))
        as Animatable<Offset>;
  }
}

enum SliderPageRouteType { left, top, right, bottom }
