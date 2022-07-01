import 'package:flutter/material.dart';

/// 无动画效果
class EmptyPageRoute<T> extends PageRouteBuilder<T> {
  final Widget widget;

  EmptyPageRoute({required this.widget, RouteSettings? settings}): super(
    transitionDuration: const Duration(microseconds: 100),
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
      return child;
    }
  );

}