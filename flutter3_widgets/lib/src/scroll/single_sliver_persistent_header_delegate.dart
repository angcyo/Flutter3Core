part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

typedef SliverPersistentHeaderWidgetBuilder = Widget Function(
  BuildContext context,
  double shrinkOffset,
  bool overlapsContent,
);

class SingleSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  /// 子部件
  final Widget? child;

  /// 子部件构建器
  final SliverPersistentHeaderWidgetBuilder? childBuilder;

  /// 是否使用固定的高度
  final double? fixedHeight;

  /// 最大高度
  final double headerMaxHeight;

  /// 最小高度
  final double headerMinHeight;

  SingleSliverPersistentHeaderDelegate({
    this.child,
    this.childBuilder,
    this.fixedHeight = kMinInteractiveDimension,
    this.headerMaxHeight = kToolbarHeight,
    this.headerMinHeight = kMinInteractiveDimension,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child ??
        (childBuilder?.call(context, shrinkOffset, overlapsContent)) ??
        const Placeholder();
  }

  @override
  double get maxExtent => fixedHeight ?? headerMaxHeight;

  @override
  double get minExtent => fixedHeight ?? headerMinHeight;

  @override
  bool shouldRebuild(
      covariant SingleSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.fixedHeight != fixedHeight ||
        oldDelegate.headerMinHeight != headerMinHeight ||
        oldDelegate.headerMaxHeight != headerMaxHeight;
  }
}
