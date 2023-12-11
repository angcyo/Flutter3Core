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
  final double? headerFixedHeight;

  /// 最大高度
  final double headerMaxHeight;

  /// 最小高度
  final double headerMinHeight;

  final TickerProvider? vSync;

  SingleSliverPersistentHeaderDelegate({
    this.child,
    this.childBuilder,
    this.vSync,
    this.headerFixedHeight = kMinInteractiveDimension,
    this.headerMaxHeight = kToolbarHeight,
    this.headerMinHeight = kMinInteractiveDimension,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child ??
        (childBuilder?.call(context, shrinkOffset, overlapsContent)) ??
        const Placeholder();
  }

  @override
  double get maxExtent => headerFixedHeight ?? headerMaxHeight;

  @override
  double get minExtent => headerFixedHeight ?? headerMinHeight;

  @override
  TickerProvider? get vsync => vSync;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      super.snapConfiguration;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      super.stretchConfiguration;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      super.showOnScreenConfiguration;

  @override
  bool shouldRebuild(
      covariant SingleSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.headerFixedHeight != headerFixedHeight ||
        oldDelegate.headerMinHeight != headerMinHeight ||
        oldDelegate.headerMaxHeight != headerMaxHeight;
  }
}
