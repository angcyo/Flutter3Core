part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/28
///
/// 用来预览[ElementPainter]的小部件
class CanvasElementWidget extends LeafRenderObjectWidget {
  final ElementPainter? elementPainter;
  final EdgeInsets? padding;
  final BoxFit? fit;

  const CanvasElementWidget(
    this.elementPainter, {
    super.key,
    this.padding = const EdgeInsets.all(kL),
    this.fit = BoxFit.contain,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      CanvasElementRenderObject(elementPainter, padding, fit);

  @override
  void updateRenderObject(
    BuildContext context,
    CanvasElementRenderObject renderObject,
  ) {
    renderObject
      ..elementPainter = elementPainter
      ..padding = padding
      ..fit = fit
      ..markNeedsPaint();
  }
}

class CanvasElementRenderObject extends RenderBox {
  ElementPainter? elementPainter;
  EdgeInsets? padding;
  BoxFit? fit;

  CanvasElementRenderObject(
    this.elementPainter,
    this.padding,
    this.fit,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    elementPainter?.let((painter) {
      final canvas = context.canvas;
      //debugger();
      painter.elementsBounds?.let((src) {
        final dst = offset & size;
        //canvas.drawRect(dst, Paint()..color = Colors.black12);
        //debugger();
        canvas.drawInRect(
          dst,
          src,
          () {
            painter.painting(canvas, const PaintMeta());
          },
          fit: fit,
          dstPadding: padding,
        );
      });

      //context.canvas.drawRect(offset & size, Paint());
    });
  }

  @override
  void performLayout() {
    if (elementPainter == null) {
      size = constraints.smallest;
    } else if (constraints.isTight) {
      size = constraints.biggest;
    } else {
      final elementsBounds = elementPainter?.elementsBounds;
      if (elementsBounds == null) {
        size = constraints.smallest;
      } else {
        size = constraints.constrainDimensions(
          elementsBounds.width,
          elementsBounds.height,
        );
      }
    }
  }
}
