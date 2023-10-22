import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/10/22
///

/// 为子布局绘制背景色
class ChildBackgroundWidget extends SingleChildRenderObjectWidget {
  const ChildBackgroundWidget({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderChildBackground();

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
  }
}

class _RenderChildBackground extends RenderProxyBox {
  @override
  void performLayout() {
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //context.canvas.drawColor(Colors.red, BlendMode.color);
    if (child != null) {
      //final themeData = Theme.of(context);
      l.i(child!.parentData);
      l.d("offset:$offset size:$size childSize:${child!.size}");
      final paint = Paint()
        ..color = Colors.red
        ..shader = const LinearGradient(
          colors: [Colors.red, Colors.blue],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
      //context.canvas.drawPaint(paint);
      //l.d(offset & size);
      //l.d(size.toRect(offset));
      //context.canvas.drawRect(child!.size.toRect(offset), paint);
      context.canvas.drawRRect(child!.size.toRect(offset).toRRect(8), paint);
    }
    super.paint(context, offset);
  }
}
