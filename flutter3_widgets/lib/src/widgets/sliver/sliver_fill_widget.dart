part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/29
///
/// 在[CustomScrollView]中撑满整个布局的Sliver系小部件
/// - 使用[CustomScrollView]全屏的约束, 约束child[RenderBox]非Sliver小部件
///
/// - [SliverFillRemaining]
///   - [RenderSliverFillRemaining]
class SliverFillWidget extends SingleChildRenderObjectWidget {
  /// 最小范围
  final double minExtent;

  /// 排除范围
  final double excludeExtent;

  const SliverFillWidget({
    super.key,
    super.child,
    this.minExtent = double.infinity,
    this.excludeExtent = 0.0,
  });

  @override
  RenderSliverFill createRenderObject(BuildContext context) =>
      RenderSliverFill()
        ..minExtent = minExtent
        ..excludeExtent = excludeExtent;

  @override
  void updateRenderObject(BuildContext context, RenderSliverFill renderObject) {
    renderObject
      ..minExtent = minExtent
      ..excludeExtent = excludeExtent;
  }
}

/// - [RenderSliverFillRemaining]
class RenderSliverFill extends RenderSliverSingleBoxAdapter {
  double minExtent = double.infinity;
  double excludeExtent = 0;

  RenderSliverFill({super.child});

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    // The remaining space in the viewportMainAxisExtent. Can be <= 0 if we have
    // scrolled beyond the extent of the screen.
    double extent =
        constraints
            .viewportMainAxisExtent /*- constraints.precedingScrollExtent*/ -
        excludeExtent;

    if (child != null) {
      /*final double childExtent = switch (constraints.axis) {
        Axis.horizontal => child!.getMaxIntrinsicWidth(
          constraints.viewportMainAxisExtent,
        ),
        Axis.vertical => child!.getMaxIntrinsicHeight(
          constraints.crossAxisExtent,
        ),
      };

      // If the childExtent is greater than the computed extent, we want to use
      // that instead of potentially cutting off the child. This allows us to
      // safely specify a maxExtent.
      extent = max(extent, childExtent);*/
      child!.layout(
        constraints.asBoxConstraints(
          minExtent: minExtent.isInfinite ? extent : minExtent,
          maxExtent: extent,
        ),
      );
    }

    assert(
      extent.isFinite,
      'The calculated extent for the child of SliverFillRemaining is not finite. '
      'This can happen if the child is a scrollable, in which case, the '
      'hasScrollBody property of SliverFillRemaining should not be set to '
      'false.',
    );
    final double paintedChildSize = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: extent,
    );
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: 0.0,
      to: extent,
    );
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
      hasVisualOverflow:
          extent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
      cacheExtent: cacheExtent,
    );
    if (child != null) {
      setChildParentData(child!, constraints, geometry!);
    }
  }
}
