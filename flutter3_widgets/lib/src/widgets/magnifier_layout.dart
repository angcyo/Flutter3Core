part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 放大镜布局
class MagnifierLayout extends SingleChildRenderObjectWidget {
  /// 放大倍数
  final double factor;

  /// 放大镜的大小, 直径
  final double size;

  const MagnifierLayout({
    super.key,
    super.child,
    this.factor = 4,
    this.size = 80,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      MagnifierLayoutRender(
        magnifierFactor: factor,
        magnifierSize: size,
      );

  @override
  void updateRenderObject(
      BuildContext context, MagnifierLayoutRender renderObject) {
    renderObject
      ..magnifierFactor = factor
      ..magnifierSize = size
      ..markNeedsPaint();
  }
}

/// 核心渲染对象
class MagnifierLayoutRender extends RenderProxyBox {
  /// 放大倍数
  double magnifierFactor;

  /// 放大镜的大小, 直径
  double magnifierSize;

  MagnifierLayoutRender({
    this.magnifierFactor = 4,
    this.magnifierSize = 80,
  });

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  /// 手势坐标点
  Offset? touchPointer;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    //l.d('${event.position} ${event.localPosition} ${event.delta}');
    if (event.isTouchEvent) {
      if (event.isPointerFinish) {
        touchPointer = null;
      } else {
        touchPointer = event.localPosition;
      }
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);

    if (child != null && touchPointer != null) {
      final left = clamp(touchPointer!.dx - magnifierSize / 2, offset.dx,
          size.width - magnifierSize);
      final top = clamp(touchPointer!.dy - magnifierSize / 2, offset.dy,
          size.height - magnifierSize);
      final rect = Rect.fromLTWH(left, top, magnifierSize, magnifierSize);

      final translate = Matrix4.identity();
      translate.translate(-touchPointer!.dx, -touchPointer!.dy);

      final scale = Matrix4.identity();
      scale.scale(magnifierFactor, magnifierFactor);

      final clipPath = Path()..addOval(rect);
      // context.canvas.withTranslate(0, 100, () {
        // context.canvas.withClipPath(clipPath, () {
        context.canvas.withMatrix(scale * translate, () {
          super.paint(context, offset);
        });
        // });
      // });
    }
  }
}
