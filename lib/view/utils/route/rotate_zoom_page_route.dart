import 'package:flutter/material.dart';

/// 旋转 + 缩放效果
class RotateZoomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget widget;

  RotateZoomPageRoute({required this.widget, RouteSettings? settings}): super(
    transitionDuration: const Duration(milliseconds: 450),
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
      return RotationTransition(
          turns:Tween(begin:0.0, end:1.0)
              .animate(CurvedAnimation(
              parent: animation1,
              curve: Curves.fastOutSlowIn
          )),
          child:ScaleTransition(
            scale:Tween(begin: 0.0, end:1.0)
                .animate(CurvedAnimation(
                parent: animation1,
                curve:Curves.fastOutSlowIn
            )),
            child: FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: animation1,
                curve: Curves.easeInOut
            )), child: child),
          )
      );
    }
  );

}