part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

/// [SliverPersistentHeaderDelegate]
typedef SliverPersistentHeaderWidgetBuilder = Widget Function(
  BuildContext context,
  double shrinkOffset,
  bool overlapsContent,
);

class SingleSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  /// 是否要顶掉其他部件

  @experimental
  final bool edgeOut;

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
    this.edgeOut = true,
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
    Widget result = child ??
        (childBuilder?.call(context, shrinkOffset, overlapsContent)) ??
        const Placeholder();
    /*if (edgeOut) {
      var state = Scrollable.of(context);

      ///整个 item 的大小
      var itemHeight = headerHeight + contentHeight;

      ///当前顶部的位置
      var position = state.position.pixels ~/ itemHeight;

      ///当前和挂着的 header 相邻的 item 位置
      var offsetPosition = (state.position.pixels + headerHeight) ~/ itemHeight;

      ///当前和挂着的 header 相邻的 item ，需要改变的偏移
      var changeOffset = state.position.pixels - offsetPosition * itemHeight;

      /// header 动态显示需要的高度
      var height = offsetPosition == (widget.index + 1)
          ? (changeOffset < 0)
              ? -changeOffset
              : widget.headerHeight
          : widget.headerHeight;

      result = Visibility(
        visible: (position <= widget.index),
        child: new Transform.translate(
          offset: Offset(0, -(widget.headerHeight - height)),
          child: widget.child,
        ),
      );
    }*/
    return result;
  }

  @override
  double get maxExtent => headerFixedHeight ?? headerMaxHeight;

  @override
  double get minExtent => headerFixedHeight ?? headerMinHeight;

  @override
  TickerProvider? get vsync => vSync;

  ///
  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      super.snapConfiguration;

  ///
  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      super.stretchConfiguration;

  ///
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
