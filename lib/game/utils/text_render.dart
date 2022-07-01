import 'package:flutter/material.dart';

import 'game.dart';

/// 文本显示
class TextRender {
  final TextPaint _textPaint;
  final String? text;
  final Vector2? position;
  final Anchor anchor;

  TextRender(
      {this.text,
      this.anchor = Anchor.topLeft,
      TextStyle style = const TextStyle(
          color: Colors.white, fontFamily: "mono", fontSize: 16),
      this.position})
      : _textPaint = TextPaint(style: style);

  void render(Canvas c, String? text, [Vector2? position]) {
    final txt = text ?? this.text;
    if (txt == null) return;
    final p = position ?? this.position;
    if (p == null) return;
    _textPaint.render(c, txt, p, anchor: anchor);
  }
}
