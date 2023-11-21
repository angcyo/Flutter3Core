part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

/// [CustomPaint] widget
/// [CustomPainter] 回调对象

/// https://book.flutterchina.club/chapter6/sliver.html#_6-11-1-sliver-%E5%B8%83%E5%B1%80%E5%8D%8F%E8%AE%AE
class SliverPaintWidget extends SingleChildRenderObjectWidget {
  /// Sliver要占用的长度, 为0也不影响绘制的回调
  /// [SliverGeometry.paintExtent]
  final double sliverExtent;

  /// 绘制的起始原点, 可以实现固定在某个位置, 不随滚动而滚动
  /// [SliverGeometry.paintOrigin]
  final double? sliverPaintOrigin;

  /// 绘制的回调
  final Painter? painter;

  const SliverPaintWidget({
    super.key,
    this.painter,
    this.sliverExtent = 0,
    this.sliverPaintOrigin,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => SliverPaintRender(
        painter,
        sliverExtent,
        sliverPaintOrigin,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    SliverPaintRender renderObject,
  ) {
    renderObject
      ..painter = painter
      ..sliverExtent = sliverExtent
      ..sliverPaintOrigin = sliverPaintOrigin;
  }
}

class SliverPaintRender extends RenderSliverSingleBoxAdapter {
  Painter? painter;
  double sliverExtent;
  double? sliverPaintOrigin;

  SliverPaintRender(
    this.painter,
    this.sliverExtent,
    this.sliverPaintOrigin,
  );

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    //geometry = SliverGeometry.zero;
    geometry = SliverGeometry(
      //可以滚动的长度, 比如自身长度10, 但是可以滚动的长度时100, 那么滚动100之后, 才会开始偏移后面child
      scrollExtent: 0,
      //可以绘制的长度, 垂直方向表示高度
      paintExtent: sliverExtent,
      maxPaintExtent: sliverExtent,
      // 绘制的坐标原点，相对于自身布局位置 //防止吸附在0的位置
      paintOrigin: sliverPaintOrigin ?? -constraints.scrollOffset,
      //这个为true, 才会触发paint
      visible: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final SliverConstraints constraints = this.constraints;
    final SliverGeometry? geometry = this.geometry;
    var size = Size(
      constraints.crossAxisExtent,
      geometry?.paintExtent ?? 0,
    );
    /*l.i(constraints);
    l.w("$offset $geometry");
    context.canvas.drawRect(offset & size, Paint()..color = Colors.redAccent);
    context.canvas.drawRect(
        Size(
          constraints.crossAxisExtent,
          constraints.viewportMainAxisExtent,
        ).toRect(),
        Paint()..color = Colors.black54);*/
    painter?.call(
      context.canvas,
      offset & size,
      Rect.fromLTWH(
        0,
        0,
        constraints.crossAxisExtent,
        constraints.viewportMainAxisExtent,
      ),
    );
  }
}
