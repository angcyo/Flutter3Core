part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

/// [CustomPaint] widget
/// [CustomPainter] 回调对象

/// https://book.flutterchina.club/chapter6/sliver.html#_6-11-1-sliver-%E5%B8%83%E5%B1%80%E5%8D%8F%E8%AE%AE
class SliverPaintWidget extends LeafRenderObjectWidget {
  /// Sliver要占用的长度, 为0也不影响绘制的回调
  /// [SliverGeometry.paintExtent]
  final double sliverExtent;

  /// 绘制的起始原点, 可以实现固定在某个位置, 不随滚动而滚动
  /// [SliverGeometry.paintOrigin]
  final double? sliverPaintOrigin;

  /// 绘制的回调
  final PainterFn? painter;

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
  PainterFn? painter;
  double sliverExtent;
  double? sliverPaintOrigin;

  SliverPaintRender(
    this.painter,
    this.sliverExtent,
    this.sliverPaintOrigin,
  );

  /// --[SliverConstraints]--
  /// [SliverConstraints.axisDirection].[SliverConstraints.axis] 布局的方向. [AxisDirection.down]新增元素放在底下
  /// [SliverConstraints.growthDirection] 排序方向. [GrowthDirection.forward]
  /// [SliverConstraints.crossAxisDirection] 交叉轴方向. [AxisDirection.right]
  /// [SliverConstraints.userScrollDirection] 用户当前正在滚动的方向.
  ///   - [ScrollDirection.reverse] 正常情况下:手指往上滑动产生的滚动
  ///   - [ScrollDirection.forward] 正常情况下:手指往下滑动产生的滚动
  ///   - [ScrollDirection.idle] 滚动停止
  ///
  /// [SliverConstraints.overlap] 当前sliver之前置顶了的偏移像素
  ///
  /// [SliverConstraints.scrollOffset] 当前sliver的滚动偏移量, 并非容器的滚动偏移量
  /// [SliverConstraints.precedingScrollExtent] 当前sliver前面的滚动偏移量, 通常会是前面所有sliver的高度之和
  /// [SliverConstraints.remainingPaintExtent] 当前sliver剩余可绘制的空间高度, 到容器底部的高度.
  ///
  /// [SliverConstraints.crossAxisExtent] 容器的交叉轴的范围(宽度)
  /// [SliverConstraints.viewportMainAxisExtent] 容器的可视区域范围(高度)
  ///
  /// [SliverConstraints.cacheOrigin] 缓存区开始的位置[0.0], 一般会等于-[SliverConstraints.scrollOffset]
  /// [SliverConstraints.remainingCacheExtent] 剩余缓存区的范围
  ///
  /// --[SliverGeometry]--
  /// [SliverGeometry.scrollExtent] 当前sliver可以滚动的高度, 那么滚动此sliver时会消耗这么多的滚动量
  /// [SliverGeometry.layoutExtent] 当前sliver在布局中的占用高度
  /// [SliverGeometry.cacheExtent] 在[SliverConstraints.remainingCacheExtent]中需要消耗的范围
  ///
  /// [SliverGeometry.paintExtent] 当前sliver的绘制高度, 视觉高度. 如果视觉高度为0时, 则不可见, 不会触发[paint]方法
  /// [SliverGeometry.maxPaintExtent] 当前sliver最大绘制的高度必须>=[SliverGeometry.paintExtent]
  /// [SliverGeometry.visible] 是否强制触发[paint]方法, 否则只有[SliverGeometry.paintExtent]>0时才绘制
  /// [SliverGeometry.paintOrigin] 绘制偏移距离[0.0], 这个值正常情况应该是[SliverConstraints.overlap]. -[SliverConstraints.scrollOffset]
  ///
  /// [SliverGeometry.crossAxisExtent] 在[SliverCrossAxisGroup]中有效
  ///
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
      visible: painter != null ? true : null,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final SliverConstraints constraints = this.constraints;
    final SliverGeometry? geometry = this.geometry;
    final size = Size(
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
