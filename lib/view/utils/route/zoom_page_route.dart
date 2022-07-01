import 'package:flutter/material.dart';

/// 缩放效果
class ZoomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget widget;

  ZoomPageRoute({required this.widget, RouteSettings? settings}): super(
    transitionDuration: const Duration(milliseconds: 500),
    settings: settings,
    pageBuilder: (context, ani1, ani2) {
      return widget;
    },
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2,
        Widget child)
    {
      return ScaleTransition(
          scale: animation1.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease))),
          child: FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation1,
            curve: Curves.easeInOut
      )), child: child));
    }
  );

}