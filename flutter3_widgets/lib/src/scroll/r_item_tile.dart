part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

/// 用来实现[RItemTile]包裹, 比如添加边距等
typedef ItemTileWrapBuilder = Widget Function(
  BuildContext context,
  List<Widget> list,
  Widget child,
  int index,
);

/// 标识当前的元素, 不是[Sliver]布局
/// [RScrollView.ensureSliver]
mixin NotSliverTile {}

/// [RScrollView] 的子项
class RItemTile extends StatefulWidget {
  /// [rItemTile]
  /// [rDecoration]
  const RItemTile({
    super.key,
    this.sliverTransformType,
    this.child,
    this.childBuilder,
    this.isSliverItem = false,
    this.updateSignal,
    this.tag,
    //
    this.part = false,
    this.hide = false,
    //Divider
    this.bottomLineColor,
    this.bottomLineHeight,
    this.bottomLineMargin,
    this.bottomLeading,
    //SliverPadding
    this.sliverPadding,
    //DecoratedSliver
    this.sliverDecoration,
    this.sliverDecorationPosition = DecorationPosition.background,
    //SliverPersistentHeader / SliverAppBar
    this.headerPinned = false,
    this.headerFloating = false,
    this.useSliverAppBar = false,
    this.headerChildBuilder,
    this.headerFixedHeight = kMinInteractiveDimension,
    this.headerMaxHeight = kMinInteractiveDimension,
    this.headerMinHeight = kMinInteractiveDimension,
    this.headerDelegate,
    this.headerBarBackgroundColor,
    this.headerBarForegroundColor,
    this.headerBarTitleTextStyle = const TextStyle(fontSize: 14),
    //SliverList
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.firstPaddingLeft,
    this.firstPaddingTop,
    this.firstPaddingRight,
    this.firstPaddingBottom,
    this.lastPaddingLeft,
    this.lastPaddingTop,
    this.lastPaddingRight,
    this.lastPaddingBottom,
    //SliverGrid
    this.crossAxisCount = 0,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1.0,
    this.edgePaddingLeft,
    this.edgePaddingTop,
    this.edgePaddingRight,
    this.edgePaddingBottom,
    //SliverFillRemaining
    this.fillRemaining = false,
    this.fillHasScrollBody = false,
    this.fillOverscroll = false,
    this.fillExpand = false,
    //SliverMainAxisGroup
    this.groups,
    this.groupExpanded,
    //SliverReorderableList
    this.onTileReorder,
    this.onTileReorderStart,
    this.onTileReorderEnd,
    this.onTileReorderProxyDecorator,
    //
  });

  //region rebuild

  /// 用来触发重构的信号, 需要主动监听这个值的变化, 然后触发重构
  /// 这里的属性, 只是为了触发重构信号, 无功能实现
  /// [RebuildWidget]
  /// [ValueNotifier]
  /// [UpdateValueNotifier]
  /// [UpdateSignalNotifier]
  final UpdateValueNotifier? updateSignal;

  //endregion rebuild

  //region 基础

  /// 标签, 用来标记当前的元素
  final Object? tag;

  /// 是否要重新分割一部分
  final bool part;

  /// 是否要隐藏当前tile
  final bool hide;

  /// 强制指定子部件
  final Widget? child;

  /// 用来构建子部件的构建器
  final WidgetBuilder? childBuilder;

  /// [RItemTile]的类型, 决定用什么样的[Sliver]包裹[RItemTile]
  /// 如果不指定类型, 会沿用上一个[RItemTile]的类型
  /// [RScrollView]
  /// [RScrollConfig.transformChain]
  /// [RTileTransformChain]
  ///
  /// 需要实现[BaseTileTransform]自定义转换器
  final dynamic sliverTransformType;

  //endregion 基础

  //region 普通布局

  /// 决定是否直接塞到[CustomScrollView.slivers]中, 要不然就会放到[SliverList]中

  /// 是否是[Sliver]布局
  /// 需要使用[SliverToBoxAdapter]包裹
  final bool isSliverItem;

  //endregion 普通布局

  //region Divider style 下划线

  /// 底部分割线的颜色
  final Color? bottomLineColor;

  /// 线的高度, 也就是厚度
  /// [Divider.thickness]
  final double? bottomLineHeight;

  /// 线的偏移距离, 也就是下左右的边距. 不支持上边距
  final EdgeInsets? bottomLineMargin;

  /// 覆盖在底部的小部件, 比如分割线
  final Widget? bottomLeading;

  //endregion style

  //region SliverPadding

  /// [SliverList].[SliverGrid].[SliverFillRemaining].[SliverPersistentHeader]
  /// 所有sliver tile是否要包裹在[SliverPadding]小部件中
  /// [SliverPadding]
  final EdgeInsetsGeometry? sliverPadding;

  //endregion SliverPadding

  //region DecoratedSliver 装饰

  /// [DecoratedSliver]
  /// [BoxDecoration]
  /// [DecoratedSliver.position]
  final Decoration? sliverDecoration;

  /// [DecoratedSliver.decoration]
  final DecorationPosition sliverDecorationPosition;

  //endregion DecoratedSliver

  //region SliverPersistentHeader / SliverAppBar 悬浮头部

  /// 决定是否使用[SliverPersistentHeader]包裹[RItemTile]

  /// 当不指定[headerDelegate]时, 则使用默认的[SingleSliverPersistentHeaderDelegate]构建
  final SliverPersistentHeaderWidgetBuilder? headerChildBuilder;

  /// 是否使用固定的高度
  /// [SingleSliverPersistentHeaderDelegate.headerFixedHeight]
  final double? headerFixedHeight;

  /// 最大高度
  /// [SingleSliverPersistentHeaderDelegate.headerMaxHeight]
  final double headerMaxHeight;

  /// 最小高度
  /// [SingleSliverPersistentHeaderDelegate.headerMinHeight]
  final double headerMinHeight;

  //---

  /// [SliverAppBar] 也可以实现[headerPinned].[headerFloating]的效果.
  /// 使用[SliverMainAxisGroup]包裹,就可以实现Stick效果. 悬浮头部效果.

  /// [SliverPersistentHeader.delegate]
  final SliverPersistentHeaderDelegate? headerDelegate;

  /// 是否固定在顶部, 支持多个悬浮在顶部
  /// 开启后, 当滚动到元素时, 会固定在顶部.
  /// [SliverPersistentHeader.pinned]
  final bool headerPinned;

  /// 是否浮动在顶部, 支持多个
  /// 开启后, 元素不可见时, 向下滚动, 会先将元素滚动出来显示
  /// [SliverPersistentHeader.floating]
  final bool headerFloating;

  /// 决定是否使用[SliverAppBar]实现悬浮效果
  /// [SliverAppBar] 有2个间隙属性[SliverAppBar.titleSpacing]
  /// https://api.flutter.dev/flutter/material/SliverAppBar-class.html
  ///
  /// [NavigationToolbar]
  /// [NavigationToolbar.middleSpacing]
  /// [kMiddleSpacing]
  /// [RScrollView._wrapHeader]
  final bool useSliverAppBar;

  /// [SliverAppBar.backgroundColor]
  final Color? headerBarBackgroundColor;

  /// [SliverAppBar.foregroundColor]
  final Color? headerBarForegroundColor;

  /// [SliverAppBar.titleTextStyle]
  final TextStyle? headerBarTitleTextStyle;

  /// 是否启动悬浮头, [SliverPersistentHeader]
  /// 如果需要2个头之间能挤推, 则可能需要配合[SliverMainAxisGroup]一起使用
  /// [TileTransformMixin.buildHeaderTile]
  bool get isHeader => headerPinned || headerFloating;

  //endregion SliverPersistentHeader / SliverAppBar

  //region SliverMainAxisGroup 分组/折叠

  /// 是否展开当前的组
  /// 不为空时, 会将相同组的元素放到[SliverMainAxisGroup]中
  final bool? groupExpanded;

  /// 当前元素所属的组名称
  final List<String>? groups;

  /// 是否启动分组功能
  bool get isSliverMainAxisGroup => groupExpanded != null;

  //endregion SliverMainAxisGroup

  //region SliverFillRemaining 填充剩余空间

  /// 决定是否使用[SliverFillRemaining]包裹[RItemTile]

  /// 是否要填充剩余空间
  final bool fillRemaining;

  /// 是否有滚动体, 用来决定最大的高度
  /// [SliverFillRemaining.hasScrollBody]
  final bool fillHasScrollBody;

  /// Overscroll 时是否填充超出的空间
  /// 一定要有 Overscroll 才有效果, 列表中要有 [SliverList] 或者 [SliverGrid]
  /// 如果child使用[Container]并且设置了背景颜色, 那么此效果无效.
  /// 此时可以使用[SizedBox.expand]来包裹[Container]
  /// [SliverFillRemaining.fillOverscroll]
  final bool fillOverscroll;

  /// 是否要使用[SizedBox.expand]包裹[SliverFillRemaining]的child
  /// 解决[fillOverscroll]的问题
  final bool fillExpand;

  //endregion SliverFillRemaining

  //region SliverList

  /// 决定是否使用[SliverList]组合[RItemTile]
  /// [SliverList.list]

  /// [SliverChildListDelegate.addAutomaticKeepAlives]
  final bool addAutomaticKeepAlives;

  /// [SliverChildListDelegate.addRepaintBoundaries]
  final bool addRepaintBoundaries;

  /// [SliverChildListDelegate.addSemanticIndexes]
  final bool addSemanticIndexes;

  /// 只在[SliverList]中有效
  /// 列表第一个位置的padding
  /// [buildListWrapChild]
  final double? firstPaddingLeft;
  final double? firstPaddingTop;
  final double? firstPaddingRight;
  final double? firstPaddingBottom;

  /// 列表最后一个位置的padding
  final double? lastPaddingLeft;
  final double? lastPaddingTop;
  final double? lastPaddingRight;
  final double? lastPaddingBottom;

  //endregion SliverList

  //region SliverGrid

  /// 决定是否使用[SliverGrid]组合[RItemTile]
  /// [SliverGrid.count]

  /// 交叉轴的数量, 比如网格的列数. 不为0时开启功能.
  /// 列数相同的[RItemTile]会被合并到同一个[SliverGrid]中,
  /// 并且默认使用第一个[RItemTile]的属性配置[SliverGrid].
  /// [SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount]
  final int crossAxisCount;

  /// 主轴间隙, 如果方向是垂直的, 则是行间隙, 如果方向是水平的, 则是列间隙
  /// [SliverGridDelegateWithFixedCrossAxisCount.mainAxisSpacing]
  final double mainAxisSpacing;

  /// 交叉轴间隙
  /// [SliverGridDelegateWithFixedCrossAxisCount.crossAxisSpacing]
  final double crossAxisSpacing;

  /// [SliverGridDelegateWithFixedCrossAxisCount.childAspectRatio]
  final double childAspectRatio;

  /// 当item在网格的边界时, 是否需要处理填充距离. 此方式的填充会占用tile的高度
  /// 只在[SliverGrid]中有效
  /// 为`null`时, 自动根据[mainAxisSpacing].[crossAxisSpacing]设置.
  /// 要关闭此功能, 请设置为0
  /// [Padding]
  /// [EdgeInsets]
  /// [buildGridWrapChild]
  final double? edgePaddingLeft;
  final double? edgePaddingTop;
  final double? edgePaddingRight;
  final double? edgePaddingBottom;

  //endregion SliverGrid

  //region SliverReorderableList

  /// 2.排序的回调
  final ReorderCallback? onTileReorder;

  /// 1.开始排序时的回调
  final IndexCallback? onTileReorderStart;

  /// 3.结束排序时的回调
  final IndexCallback? onTileReorderEnd;

  /// 用来装饰拖拽的小部件, 可以修改拖拽时显示的小部件
  final ReorderItemProxyDecorator? onTileReorderProxyDecorator;

  //endregion SliverReorderableList

  /// 构建子部件
  /// [_RItemTileState.build]
  Widget buildChild(BuildContext context) {
    return child ??
        childBuilder?.call(context) ??
        (!isSliverItem
            ? const SliverToBoxAdapter(child: Empty())
            : const Empty());
  }

  //---

  Widget? _buildBottomWidget(BuildContext context) {
    return bottomLeading ??
        (bottomLineColor == null
            ? null
            : Divider(
                height: bottomLineMargin?.bottom,
                thickness: bottomLineHeight,
                indent: bottomLineMargin?.left,
                endIndent: bottomLineMargin?.right,
                color: bottomLineColor,
              ));
  }

  /// [SliverListTransform]
  Widget buildListWrapChild(
    BuildContext context,
    WidgetIterable list,
    Widget child,
    int index,
  ) {
    final first = list.firstOrNull;
    final last = list.lastOrNull;
    final length = list.length;

    double left = 0.0;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;

    Widget? bWidget;

    if (first is RItemTile) {
      //底部需要堆叠的小部件
      if (length == 1) {
        //只有一个
        left = first.firstPaddingLeft ?? first.lastPaddingLeft ?? left;
        top = first.firstPaddingTop ?? first.lastPaddingTop ?? top;
        right = first.firstPaddingRight ?? first.lastPaddingRight ?? right;
        bottom = first.firstPaddingBottom ?? first.lastPaddingBottom ?? bottom;
      } else if (index == 0) {
        //第一个
        left = first.firstPaddingLeft ?? left;
        top = first.firstPaddingTop ?? top;
        right = first.firstPaddingRight ?? right;
        bottom = first.firstPaddingBottom ?? bottom;
      }
    }

    if (length > 1 && index < length - 1) {
      bWidget = _buildBottomWidget(context) ??
          (first as RItemTile?)?._buildBottomWidget(context);
    }

    if (last is RItemTile && length > 1 && index == length - 1) {
      //最后一个
      left = last.lastPaddingLeft ?? left;
      top = last.lastPaddingTop ?? top;
      right = last.lastPaddingRight ?? right;
      bottom = last.lastPaddingBottom ?? bottom;
    }

    Widget result = child;

    // 有值
    if (left != 0 || top != 0 || right != 0 || bottom != 0) {
      result = child.paddingLTRB(left, top, right, bottom);
    }

    //stack
    if (bWidget != null) {
      result = Stack(
        alignment: Alignment.bottomCenter,
        children: [result, bWidget],
      );
    }

    //clip
    if (first is RItemTile) {
      var decoration = first.sliverDecoration;
      if (decoration is BoxDecoration) {
        var borderRadius = decoration.borderRadius;
        if (length == 1) {
          result = result.clip(borderRadius: borderRadius);
        } else if (borderRadius is BorderRadius) {
          if (index == 0) {
            result = result.clip(
                borderRadius: BorderRadius.only(
              topLeft: borderRadius.topLeft,
              topRight: borderRadius.topRight,
            ));
          } else if (index == length - 1) {
            result = result.clip(
                borderRadius: BorderRadius.only(
              bottomLeft: borderRadius.bottomLeft,
              bottomRight: borderRadius.bottomRight,
            ));
          }
        }
      }
    }

    return result;
  }

  /// [SliverGridTransform]
  Widget buildGridWrapChild(
    BuildContext context,
    WidgetIterable list,
    Widget child,
    int index,
  ) {
    final first = list.firstOrNull;
    if (first is RItemTile) {
      final isEdgeLeft = index % first.crossAxisCount == 0;
      final isEdgeRight =
          index % first.crossAxisCount == first.crossAxisCount - 1;
      final isEdgeTop = index < first.crossAxisCount;
      //总行数
      final int totalRow = (list.length / first.crossAxisCount).ceil();
      //最后一行索引
      final int lastRowIndex = totalRow - 1;
      //当前行数
      final int currentRow = (index / first.crossAxisCount).floor();
      final isEdgeBottom = currentRow == lastRowIndex;
      final isEdge = isEdgeLeft || isEdgeRight || isEdgeTop || isEdgeBottom;
      if (isEdge) {
        //需要padding
        final double left =
            isEdgeLeft ? first.edgePaddingLeft ?? first.crossAxisSpacing : 0;
        final double top =
            isEdgeTop ? first.edgePaddingTop ?? first.mainAxisSpacing : 0;
        final double right =
            isEdgeRight ? first.edgePaddingRight ?? first.crossAxisSpacing : 0;
        final double bottom =
            isEdgeBottom ? first.edgePaddingBottom ?? first.mainAxisSpacing : 0;

        // 有值
        if (left != 0 || top != 0 || right != 0 || bottom != 0) {
          return child.paddingLTRB(left, top, right, bottom);
        }
      }
    }
    return child;
  }

  /// 当[anchor]隐藏时, 自己是否要隐藏
  /// [ItemTileFilter]
  bool isHideFrom(Widget anchor) {
    return false;
  }

  /// 当前的元素, 是否属于指定的组
  /// [ItemTileFilter]
  bool isInGroup(RItemTile? tile, [List<String>? groups]) {
    var thisGroups = this.groups;
    if (thisGroups == null) {
      return false;
    }
    if (thisGroups.isEmpty) {
      //没有指定组, 则当前元素属于任意组
      return true;
    }

    if (tile != null) {
      if (thisGroups.hasSameElement(tile.groups)) {
        return true;
      }
      if (thisGroups.hasSameElement(groups)) {
        return true;
      }
    }
    return false;
  }

  @override
  State<RItemTile> createState() => _RItemTileState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('part', part));
    properties.add(DiagnosticsProperty<bool>('hide', hide));
    properties.add(DiagnosticsProperty<Object>('tag', tag));
    properties.add(DiagnosticsProperty<dynamic>(
        'sliverTransformType', sliverTransformType));
    properties.add(DiagnosticsProperty<bool>('isSliverItem', isSliverItem));
    properties
        .add(DiagnosticsProperty<Color?>('bottomLineColor', bottomLineColor));
    properties.add(
        DiagnosticsProperty<double?>('bottomLineHeight', bottomLineHeight));
    properties.add(
        DiagnosticsProperty<EdgeInsets?>('bottomLineMargin', bottomLineMargin));
    properties
        .add(DiagnosticsProperty<Widget?>('bottomLeading', bottomLeading));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>(
        'sliverPadding', sliverPadding));
    properties.add(
        DiagnosticsProperty<Decoration?>('sliverDecoration', sliverDecoration));
    properties.add(DiagnosticsProperty<DecorationPosition>(
        'sliverDecorationPosition', sliverDecorationPosition));
    properties.add(DiagnosticsProperty<bool>('groupExpanded', groupExpanded));
    properties.add(DiagnosticsProperty<List<String>?>('groups', groups));
    properties.add(DiagnosticsProperty<bool>('isGroup', isSliverMainAxisGroup));
    properties.add(DiagnosticsProperty<bool>('fillRemaining', fillRemaining));
    properties
        .add(DiagnosticsProperty<bool>('fillHasScrollBody', fillHasScrollBody));
    properties.add(DiagnosticsProperty<bool>('fillOverscroll', fillOverscroll));
    properties.add(DiagnosticsProperty<bool>('fillExpand', fillExpand));
    properties.add(DiagnosticsProperty<bool>(
        'addAutomaticKeepAlives', addAutomaticKeepAlives));
    properties.add(DiagnosticsProperty<bool>(
        'addRepaintBoundaries', addRepaintBoundaries));
    properties.add(
        DiagnosticsProperty<bool>('addSemanticIndexes', addSemanticIndexes));
    properties.add(DiagnosticsProperty<int>('crossAxisCount', crossAxisCount));
    properties
        .add(DiagnosticsProperty<double>('mainAxisSpacing', mainAxisSpacing));
    properties
        .add(DiagnosticsProperty<double>('crossAxisSpacing', crossAxisSpacing));
    properties
        .add(DiagnosticsProperty<double>('childAspectRatio', childAspectRatio));
    properties
        .add(DiagnosticsProperty<double?>('edgePaddingLeft', edgePaddingLeft));
    properties
        .add(DiagnosticsProperty<double?>('edgePaddingTop', edgePaddingTop));
    properties.add(
        DiagnosticsProperty<double?>('edgePaddingRight', edgePaddingRight));
    properties.add(
        DiagnosticsProperty<double?>('edgePaddingBottom', edgePaddingBottom));
    properties.add(DiagnosticsProperty<SliverPersistentHeaderWidgetBuilder?>(
        'headerChildBuilder', headerChildBuilder));
    properties.add(
        DiagnosticsProperty<double?>('headerFixedHeight', headerFixedHeight));
    properties
        .add(DiagnosticsProperty<double>('headerMaxHeight', headerMaxHeight));
    properties
        .add(DiagnosticsProperty<double>('headerMinHeight', headerMinHeight));
    properties.add(DiagnosticsProperty<SliverPersistentHeaderDelegate?>(
        'headerDelegate', headerDelegate));
    properties.add(DiagnosticsProperty<bool>('pinned', headerPinned));
    properties.add(DiagnosticsProperty<bool>('floating', headerFloating));
    properties
        .add(DiagnosticsProperty<bool>('useSliverAppBar', useSliverAppBar));
    properties.add(DiagnosticsProperty<Color?>(
        'headerBackgroundColor', headerBarBackgroundColor));
    properties.add(DiagnosticsProperty<Color?>(
        'headerForegroundColor', headerBarForegroundColor));
    properties.add(DiagnosticsProperty<TextStyle?>(
        'headerTitleTextStyle', headerBarTitleTextStyle));
  }
}

class _RItemTileState extends State<RItemTile> {
  @override
  Widget build(BuildContext context) {
    return widget.buildChild(context);
  }
}

extension RItemTileExtension on Widget {
  /// 列表item
  /// [RItemTile.buildListWrapChild]
  ///
  /// [SliverList.builder]
  RItemTile rListTile({
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? firstPaddingLeft,
    double? firstPaddingTop,
    double? firstPaddingRight,
    double? firstPaddingBottom,
    double? lastPaddingLeft,
    double? lastPaddingTop,
    double? lastPaddingRight,
    double? lastPaddingBottom,
    //--
    bool hide = false,
    bool part = false,
    UpdateValueNotifier? updateSignal,
    bool enablePadding = false,
    EdgeInsetsGeometry? sliverPadding,
    dynamic sliverTransformType = SliverList,
  }) {
    return RItemTile(
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      firstPaddingLeft: firstPaddingLeft,
      firstPaddingTop: firstPaddingTop,
      firstPaddingRight: firstPaddingRight,
      firstPaddingBottom: firstPaddingBottom,
      lastPaddingLeft: lastPaddingLeft,
      lastPaddingTop: lastPaddingTop,
      lastPaddingRight: lastPaddingRight,
      lastPaddingBottom: lastPaddingBottom,
      sliverPadding: sliverPadding ??
          (enablePadding
              ? EdgeInsets.only(
                  left: firstPaddingLeft ?? lastPaddingLeft ?? 0.0,
                  top: firstPaddingTop ?? 0.0,
                  right: firstPaddingRight ?? lastPaddingRight ?? 0.0,
                  bottom: lastPaddingBottom ?? 0.0,
                )
              : null),
      hide: hide,
      part: part,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      sliverTransformType: sliverTransformType,
      child: this,
    );
  }

  /// 网格item
  /// [gridCount] 网格的列数
  /// [childAspectRatio] child宽高比(w/h), <1时,高度高; >1时,宽度高;
  /// [mainAxisSpacing] 主轴间隙, 如果方向是垂直的, 则是行间隙, 如果方向是水平的, 则是列间隙
  /// [crossAxisSpacing] 交叉轴间隙
  /// [RItemTile.buildGridWrapChild]
  ///
  /// [SliverGrid.builder]
  RItemTile rGridTile(
    int gridCount, {
    double childAspectRatio = 1,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? edgePaddingTop,
    double? edgePaddingBottom,
    double? edgePaddingLeft,
    double? edgePaddingRight,
    //--
    bool hide = false,
    bool part = false,
    UpdateValueNotifier? updateSignal,
    bool enablePadding = false,
    EdgeInsetsGeometry? sliverPadding,
    dynamic sliverTransformType = SliverGrid,
  }) {
    mainAxisSpacing ??= 0;
    crossAxisSpacing ??= mainAxisSpacing;
    return RItemTile(
      crossAxisCount: gridCount,
      sliverTransformType: sliverTransformType,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      edgePaddingTop: edgePaddingTop,
      edgePaddingBottom: edgePaddingBottom,
      edgePaddingLeft: edgePaddingLeft,
      edgePaddingRight: edgePaddingRight,
      sliverPadding: sliverPadding ??
          (enablePadding
              ? EdgeInsets.symmetric(
                  vertical: mainAxisSpacing,
                  horizontal: crossAxisSpacing,
                )
              : null),
      hide: hide,
      part: part,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      child: this,
    );
  }

  /// [RItemTile]的快捷构造方法
  /// 默认情况下没有任务约束的[RItemTile]会被[SliverToBoxAdapter]包裹, 这样就没有懒加载
  /// 推荐使用[rListTile].[rGridTile]
  /// [RItemTile.buildListWrapChild]
  ///
  /// [SliverToBoxAdapter]
  RItemTile rItemTile({
    Key? key,
    Widget? child,
    WidgetBuilder? childBuilder,
    bool isSliverItem = false,
    bool hide = false,
    bool part = false,
    Color? bottomLineColor,
    double? bottomLineHeight,
    EdgeInsets? bottomLineMargin,
    Widget? bottomLeading,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    int crossAxisCount = 0,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    double childAspectRatio = 1.0,
    SliverPersistentHeaderWidgetBuilder? headerChildBuilder,
    double? headerFixedHeight,
    double headerMaxHeight = kMinInteractiveDimension,
    double headerMinHeight = kMinInteractiveDimension,
    SliverPersistentHeaderDelegate? headerDelegate,
    bool pinned = false,
    bool floating = false,
    bool fillRemaining = false,
    bool fillHasScrollBody = false,
    bool fillOverscroll = false,
    bool fillExpand = false,
    double? firstPaddingLeft,
    double? firstPaddingTop,
    double? firstPaddingRight,
    double? firstPaddingBottom,
    double? lastPaddingLeft,
    double? lastPaddingTop,
    double? lastPaddingRight,
    double? lastPaddingBottom,
    double? edgePaddingLeft,
    double? edgePaddingTop,
    double? edgePaddingRight,
    double? edgePaddingBottom,
    bool? groupExpanded /*如果是组, 是否展开当前组*/,
    UpdateValueNotifier? updateSignal,
    List<String>? groups = const [],
    dynamic sliverTransformType,
  }) {
    return RItemTile(
      key: key,
      childBuilder: childBuilder,
      isSliverItem: isSliverItem,
      sliverTransformType: sliverTransformType,
      hide: hide,
      part: part,
      bottomLineColor: bottomLineColor,
      bottomLineHeight: bottomLineHeight,
      bottomLineMargin: bottomLineMargin,
      bottomLeading: bottomLeading,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      headerChildBuilder: headerChildBuilder,
      headerFixedHeight: headerFixedHeight,
      headerMaxHeight: headerMaxHeight,
      headerMinHeight: headerMinHeight,
      headerDelegate: headerDelegate,
      headerPinned: pinned,
      headerFloating: floating,
      fillRemaining: fillRemaining,
      fillHasScrollBody: fillHasScrollBody,
      fillOverscroll: fillOverscroll,
      fillExpand: fillExpand,
      firstPaddingLeft: firstPaddingLeft,
      firstPaddingTop: firstPaddingTop,
      firstPaddingRight: firstPaddingRight,
      firstPaddingBottom: firstPaddingBottom,
      lastPaddingLeft: lastPaddingLeft,
      lastPaddingTop: lastPaddingTop,
      lastPaddingRight: lastPaddingRight,
      lastPaddingBottom: lastPaddingBottom,
      edgePaddingLeft: edgePaddingLeft,
      edgePaddingTop: edgePaddingTop,
      edgePaddingRight: edgePaddingRight,
      edgePaddingBottom: edgePaddingBottom,
      groupExpanded: groupExpanded,
      groups: groups,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      child: child ?? this,
    );
  }

  /// 悬浮头, 使用此特性时, 建议指定child的大小, 并且设置成和[headerFixedHeight]一致
  /// [TileTransformMixin.buildHeaderTile]
  RItemTile rFloated({
    bool pinned = true,
    bool floating = false,
    bool useSliverAppBar = false,
    SliverPersistentHeaderWidgetBuilder? headerChildBuilder,
    double? headerFixedHeight,
    double? headerMaxHeight,
    double? headerMinHeight,
    SliverPersistentHeaderDelegate? headerDelegate,
    Color? headerBarBackgroundColor,
    Color? headerBarForegroundColor,
    TextStyle? headerBarTitleTextStyle = const TextStyle(fontSize: 14),
    UpdateValueNotifier? updateSignal,
    dynamic sliverTransformType = SliverMainAxisGroup,
  }) {
    return RItemTile(
      headerPinned: pinned,
      headerFloating: floating,
      headerChildBuilder: headerChildBuilder,
      headerFixedHeight: headerFixedHeight,
      headerMaxHeight:
          headerMaxHeight ?? headerFixedHeight ?? kMinInteractiveDimension,
      headerMinHeight: headerMinHeight ?? headerFixedHeight ?? 0,
      headerDelegate: headerDelegate,
      headerBarBackgroundColor: headerBarBackgroundColor,
      headerBarForegroundColor: headerBarForegroundColor,
      headerBarTitleTextStyle: headerBarTitleTextStyle,
      useSliverAppBar: useSliverAppBar,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      sliverTransformType: sliverTransformType,
      child: this,
    );
  }

  /// 分组/悬浮分组头
  /// [groupExpanded] 启动分组的关键
  /// [headerHeight] 头部固定的高度
  /// [useSliverAppBar] 是否使用[SliverAppBar]实现[pinned]功能
  ///
  /// [SliverMainAxisGroup]
  RItemTile rGroup({
    bool? groupExpanded = true,
    bool pinned = true,
    bool floating = false,
    bool useSliverAppBar = true,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    double headerHeight = kMinInteractiveHeight,
    List<String>? groups,
    Color? fillColor,
    double borderRadius = kDefaultBorderRadiusXX,
    EdgeInsetsGeometry? sliverPadding,
    Decoration? sliverDecoration,
    DecorationPosition sliverDecorationPosition = DecorationPosition.background,
    UpdateValueNotifier? updateSignal,
    dynamic sliverTransformType = SliverMainAxisGroup,
  }) {
    return RItemTile(
      groups: groups,
      headerFixedHeight: headerHeight,
      headerMaxHeight: headerHeight,
      headerMinHeight: headerHeight,
      groupExpanded: groupExpanded,
      headerPinned: pinned,
      headerFloating: floating,
      useSliverAppBar: useSliverAppBar,
      headerBarBackgroundColor: headerBackgroundColor,
      headerBarForegroundColor: headerForegroundColor,
      sliverPadding: sliverPadding,
      sliverDecoration: sliverDecoration ??
          (fillColor == null
              ? null
              : fillDecoration(
                  color: fillColor,
                  borderRadius: borderRadius,
                )),
      sliverDecorationPosition: sliverDecorationPosition,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      sliverTransformType: sliverTransformType,
      child: this,
    );
  }

  /// 装饰
  /// [fillColor].[borderRadius] 简单替代[sliverDecoration]
  /// [BoxDecoration]
  /// [rItemTile]
  /// [rDecoration]
  /// [DecoratedSliver]
  RItemTile rDecoration({
    bool part = false,
    Color? fillColor,
    double borderRadius = kDefaultBorderRadiusXX,
    EdgeInsetsGeometry? sliverPadding,
    Decoration? sliverDecoration,
    DecorationPosition sliverDecorationPosition = DecorationPosition.background,
    Color? bottomLineColor,
    double? bottomLineHeight,
    EdgeInsets? bottomLineMargin,
    Widget? bottomLeading,
    UpdateValueNotifier? updateSignal,
  }) {
    return RItemTile(
      part: part,
      sliverPadding: sliverPadding,
      sliverDecoration: sliverDecoration ??
          fillDecoration(
            color: fillColor,
            borderRadius: borderRadius,
          ),
      sliverDecorationPosition: sliverDecorationPosition,
      bottomLeading: bottomLeading,
      bottomLineColor: bottomLineColor,
      bottomLineHeight: bottomLineHeight,
      bottomLineMargin: bottomLineMargin,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      child: this,
    );
  }

  /// 填充底部剩余空间
  RItemTile rFill({
    bool fillRemaining = true,
    bool fillHasScrollBody = false,
    bool fillOverscroll = false,
    bool fillExpand = true,
    UpdateValueNotifier? updateSignal,
  }) {
    return RItemTile(
      fillRemaining: fillRemaining,
      fillHasScrollBody: fillHasScrollBody,
      fillOverscroll: fillOverscroll,
      fillExpand: fillExpand,
      updateSignal: updateSignal ?? RScrollPage.consumeRebuildBeanSignal(),
      child: this,
    );
  }

  /// 支持排序的item
  /// [items] 列表数据, 如果指定了则自动更新数据. 且列表必须是可以改变的.
  ///
  /// `Unsupported operation: Cannot remove from a fixed-length list`
  ///
  /// 使用[ReorderableDragStartListener]包裹实现按下拖拽
  /// 使用[ReorderableDelayedDragStartListener]包裹实现长按拖拽
  ///
  /// ```
  /// ListTile(
  ///   trailing: ReorderableDragStartListener(
  ///     index: items.indexOf(item),
  ///     child: const Icon(Icons.drag_handle_outlined),
  ///   ),
  ///   title: Text(item),
  /// ).material().rReorder(onReorder),
  /// ```
  ///
  /// [SliverReorderableList]
  RItemTile rReorder(
    ReorderCallback onTileReorder, {
    Key? key,
    List? items,
    IndexCallback? onTileReorderStart,
    IndexCallback? onTileReorderEnd,
    dynamic sliverTransformType = SliverReorderableList,
  }) {
    ReorderCallback reorderCallback = onTileReorder;
    if (items != null) {
      //自动排序处理
      reorderCallback = (int oldIndex, int newIndex) {
        assert(() {
          l.d("拖拽排序,oldIndex:$oldIndex newIndex:$newIndex");
          return true;
        }());
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = items.removeAt(oldIndex);
        items.insert(newIndex, item);

        //回调出去, 并手动更新界面
        onTileReorder(oldIndex, newIndex);
      };
    }
    return RItemTile(
      key: key,
      onTileReorder: reorderCallback,
      onTileReorderStart: onTileReorderStart,
      onTileReorderEnd: onTileReorderEnd,
      sliverTransformType: sliverTransformType,
      child: this,
    );
  }
}
