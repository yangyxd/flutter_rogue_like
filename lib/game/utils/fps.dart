import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// FPS 信息
class Fps extends FpsComponent {
  final _textPaint = TextPaint(
    style: const TextStyle(
        color: Colors.yellow,
        fontSize: 10.0,
        fontFamily: 'mono',
        shadows: [
          Shadow(color: Colors.black87, offset: Offset(2, 2), blurRadius: 4)
        ]
    ),
  );

  /// 对象数量
  static int _objNum = 0;

  @override
  void render(Canvas c) {
    _textPaint.render(c, "FPS: ${fps.toInt().toString()}, OBJECT: $_objNum", Vector2(10, 10));
  }

}

mixin FpsMixin on Component {
  @override
  Future<void>? add(Component component) {
    Fps._objNum++;
    return super.add(component);
  }

  @override
  void onRemove() {
    Fps._objNum--;
    super.onRemove();
  }

  void clearChildren() {
    children.toList().forEach((e) {
      remove(e);
    });
  }
}