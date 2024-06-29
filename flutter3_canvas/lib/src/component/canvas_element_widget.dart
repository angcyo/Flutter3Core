part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/28
///
/// 用来预览[ElementPainter]的小部件
class CanvasElementWidget extends LeafRenderObjectWidget {
  final EdgeInsets? padding;

  final ElementPainter? elementPainter;

  const CanvasElementWidget(
    this.elementPainter, {
    super.key,
    this.padding = const EdgeInsets.all(kL),
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _CanvasElementRenderObject(elementPainter, padding);

  @override
  void updateRenderObject(
    BuildContext context,
    _CanvasElementRenderObject renderObject,
  ) {
    renderObject
      ..elementPainter = elementPainter
      ..padding = padding
      ..markNeedsPaint();
  }
}

class _CanvasElementRenderObject extends RenderBox {
  ElementPainter? elementPainter;
  EdgeInsets? padding;

  _CanvasElementRenderObject(this.elementPainter, this.padding);

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    elementPainter?.let((painter) {
      final canvas = context.canvas;
      painter.elementsBounds?.let((src) {
        final dst = offset & size;
        //canvas.drawRect(dst, Paint()..color = Colors.black12);
        //debugger();
        canvas.drawInRect(dst, src, () {
          painter.painting(canvas, PaintMeta());
        }, fit: BoxFit.contain, dstPadding: padding);
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
