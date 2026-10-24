import 'package:flutter/material.dart';

import '../../flutter3_flame.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/23
///
/// 用来渲染精灵[Sprite]的小部件
class SpriteWidget extends StatelessWidget {
  ///精灵
  final Sprite? sprite;

  /// 渲染大小
  final Size? renderSize;

  const SpriteWidget({super.key, this.sprite, this.renderSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size:
          renderSize ??
          (sprite == null
              ? Size.zero
              : Size(sprite!.srcSize.x, sprite!.srcSize.y)),
      painter: SpritePainter(sprite),
    );
  }
}

class SpritePainter extends CustomPainter {
  final Sprite? sprite;

  SpritePainter(this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    sprite?.render(canvas, size: Vector2(size.width, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is SpritePainter) {
      return sprite != oldDelegate.sprite;
    }
    return false;
  }
}
