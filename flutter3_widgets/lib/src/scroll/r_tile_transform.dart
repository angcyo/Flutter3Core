part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/14
///
/// 是否是[Sliver]小部件
bool isSliverWidget(Widget tile) {
  const systemSliverWidgetList = [
    SliverToBoxAdapter,
    SliverList,
    SliverGrid,
    SliverFixedExtentList,
    SliverPrototypeExtentList,
    SliverFillViewport,
    SliverFillRemaining,
    SliverAnimatedGrid,
    SliverAnimatedList,
    SliverPadding,
  ];
  return systemSliverWidgetList.contains(tile.runtimeType);
}

/// 确保是[Sliver]小部件
@minifyProguardFlag
Widget _ensureSliver(Widget tile) {
  bool isSliver = false;
  if (tile is RItemTile) {
    isSliver = tile.isSliverItem;
  }
  if (isSliver) {
    return tile;
  }
  //l.w("处理[${tile.runtimeType}][$tile]:${tile.toStringShort()}");
  //[SliverFillRemaining(child: Text, mode: [fillOverscroll])] SliverFillRemaining
  //打包之后会变成
  //[Instance of 'SliverFillRemaining'] Widget
  if (isSliverWidget(tile)) {
    return tile;
  } else if (tile is! NotSliverTile &&
          tile.runtimeType.toString().toLowerCase().contains("sliver")
      /*("$tile".toLowerCase().startsWith("sliver") ||
              "$tile".toLowerCase().startsWith("instance of 'sliver")) ||
      "$tile".toLowerCase().contains("sliver")*/
      ) {
    assert(() {
      l.d('未使用[SliverToBoxAdapter]包裹的[Sliver]小部件[${tile.runtimeType}]');
      return true;
    }());
    return tile;
  } else {
    return SliverToBoxAdapter(
      child: tile,
    );
  }
}

/// [_defaultTileTransformChain]
/// [RScrollView]中的[RItemTile]转换/变换
/// 输入一个/多个[RItemTile], 输出一个/多个[RItemTile]
class RTileTransformChain with TileTransformMixin {
  /// 1对1或多对1的转换, 组合到一个小部件中
  final List<BaseTileTransform> transformList;

  const RTileTransformChain(this.transformList);

  /// 执行转换
  @entryPoint
  WidgetList doTransform(BuildContext context, WidgetList children) {
    WidgetList result = [];

    BaseTileTransform? lastTransform;
    for (var i = 0; i < children.length; i++) {
      final tile = children[i];

      bool handle = false;

      //延用上一次的转换器
      BaseTileTransform? excludeTransform;
      if (lastTransform != null) {
        excludeTransform = lastTransform;
        //如果有上一个转换器
        final support = lastTransform.isSupportTransform(context, tile);
        if (support) {
          //支持当前的转换
          handle =
              lastTransform.transformTile(context, children, result, tile, i);
        } else {
          //不支持当前的转换
          lastTransform.endTransformIfNeed(context, children, result);
          lastTransform = null;
        }
      }
      //debugger();

      //查找新的转换器
      if (lastTransform == null) {
        for (final transform in transformList) {
          if (transform == excludeTransform) {
            continue;
          }
          final support = transform.isSupportTransform(context, tile);
          //debugger();
          if (support) {
            //debugger();
            lastTransform = transform;
            handle =
                transform.transformTile(context, children, result, tile, i);
            break;
          }
        }
        if (lastTransform == null) {
          if (tile is RItemTile) {
            if (tile.sliverTransformType != null) {
              assert(() {
                l.w('未找到对应的转换器转换type:[${tile.sliverTransformType}]');
                return true;
              }());
            }
          }
        }
      }

      // 未找到转换器时, 则进行默认的转换处理
      if (!handle) {
        //debugger();
        lastTransform?.endTransformIfNeed(context, children, result);
        lastTransform = null;
        Widget child = tile;
        if (tile is RItemTile) {
          child = buildTileWidget(context, tile, tile);
        }
        result.add(_ensureSliver(child));
      }
    }
    //debugger();
    lastTransform?.endTransformIfNeed(context, children, result);
    return result;
  }

  /// 重置
  @entryPoint
  void reset() {
    for (var element in transformList) {
      element.reset();
    }
  }
}

mixin TileTransformMixin {
  //region ---build---

  /// 构建[RItemTile]描述的简单子部件
  /// [buildTileWidget]
  /// [buildTileListWidget]
  Widget buildTileWidget(BuildContext context, Widget? tile, Widget child) {
    if (tile is RItemTile) {
      Widget result = wrapSliverPaddingDecorationTile(tile, child);
      result = wrapHeaderTile(context, tile, result);
      result = wrapSliverFillRemaining(context, tile, result);
      return result;
    }
    return child;
  }

  /// 构建一组[RItemTile]描述的简单子部件
  /// [buildTileWidget]
  /// [buildTileListWidget]
  WidgetIterable buildTileListWidget(
      BuildContext context, WidgetIterable tileList) {
    return tileList
        .map((e) => e is RItemTile ? buildTileWidget(context, e, e) : e);
  }

  /// 悬浮头包裹, 如果需要的话
  /// [SliverAppBar]内部也是使用[SliverPersistentHeader]实现的
  /// [SliverPersistentHeader]
  /// [child] 可以等于[tile]
  Widget? buildHeaderTile(BuildContext context, Widget? tile, Widget child) {
    if (tile is RItemTile) {
      if (tile.useSliverAppBar) {
        var height = tile.headerFixedHeight ?? tile.headerMinHeight;
        return SliverAppBar(
          title: child,
          floating: tile.floating,
          pinned: tile.pinned,
          titleSpacing: 0,
          toolbarHeight: height,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: tile.headerBackgroundColor,
          foregroundColor: tile.headerForegroundColor,
          expandedHeight: null,
          collapsedHeight: null,
          titleTextStyle: tile.headerTitleTextStyle,
          primary: false,
          snap: false,
        );
      }
      if (tile.headerDelegate == null) {
        return SliverPersistentHeader(
          delegate: SingleSliverPersistentHeaderDelegate(
            child: child,
            childBuilder: tile.headerChildBuilder,
            headerFixedHeight: tile.headerFixedHeight,
            headerMaxHeight: tile.headerMaxHeight,
            headerMinHeight: tile.headerMinHeight,
          ),
          pinned: tile.pinned,
          floating: tile.floating,
        );
      }
      return SliverPersistentHeader(
        delegate: tile.headerDelegate!,
        pinned: tile.pinned,
        floating: tile.floating,
      );
    }
    return null;
  }

  /// 使用[SliverFillRemaining]包裹, 如果需要的话
  Widget? buildSliverFillRemaining(
    BuildContext context,
    Widget? tile,
    Widget child,
  ) {
    if (tile is RItemTile) {
      if (tile.fillRemaining) {
        if (tile.fillExpand) {
          //child = SizedBox.expand(child: tile);
          child = SliverExpandWidget(child: child);
        }
        child = SliverFillRemaining(
          /*key: UniqueKey(), */
          hasScrollBody: tile.fillHasScrollBody,
          fillOverscroll: tile.fillOverscroll,
          child: child,
        );
        return child;
      }
    }
    return null;
  }

  //region ---build---

  //region ---tile处理---

  /// [buildSliverFillRemaining]
  Widget wrapSliverFillRemaining(
    BuildContext context,
    RItemTile? tile,
    Widget sliverChild,
  ) =>
      tile?.fillRemaining == true
          ? buildSliverFillRemaining(context, tile, sliverChild) ?? sliverChild
          : sliverChild;

  /// [buildHeaderTile]
  Widget wrapHeaderTile(
    BuildContext context,
    RItemTile? tile,
    Widget sliverChild,
  ) =>
      tile?.isHeader == true
          ? buildHeaderTile(context, tile, sliverChild) ?? sliverChild
          : sliverChild;

  //endregion ---tile处理---

  //region ---Sliver装饰---

  /// 判断tile是否需要padding和装饰
  /// [sliverChild] 需要包装的sliverChild, 必须是sliver小部件
  /// [SliverPadding]
  /// [DecoratedSliver]
  /// [wrapSliverPadding]
  /// [wrapSliverDecoration]
  Widget wrapSliverPaddingDecorationTile(
    RItemTile? tile,
    Widget sliverChild,
  ) =>
      tile == null
          ? sliverChild
          : wrapSliverPadding(
              tile.sliverPadding,
              wrapSliverDecoration(
                tile.sliverDecoration,
                tile.sliverDecorationPosition,
                sliverChild,
              ),
            );

  /// 装饰当前的[sliverChild]
  /// [DecoratedSliver]
  Widget wrapSliverDecoration(
    Decoration? decoration,
    DecorationPosition decorationPosition,
    Widget sliverChild,
  ) {
    //debugger();
    if (decoration == null) {
      return sliverChild;
    }

    return DecoratedSliver(
      decoration: decoration,
      position: decorationPosition,
      sliver: sliverChild,
    );
  }

  /// 间隙填充当前的[sliverChild]
  /// [SliverPadding]
  Widget wrapSliverPadding(
    EdgeInsetsGeometry? sliverPadding,
    Widget sliverChild,
  ) {
    if (sliverPadding == null) {
      return sliverChild;
    }

    return SliverPadding(
      padding: sliverPadding,
      sliver: sliverChild,
    );
  }

//endregion ---Sliver装饰---
}

/// 将一组变换好的小部件, 转换成另外一个小部件, 如果需要的话
/// [BaseWrapTileTransform]
abstract class BaseTileTransform with TileTransformMixin {
  /// 收集到的[RItemTile], 用来读取配置.
  /// 有可能是[RItemTile],也有可能是普通的[Widget]
  List<Widget> tileList = [];

  /// 构造函数
  BaseTileTransform();

  /// 未指定变换类型的[tile]是否可以被处理
  @property
  bool isSupportDefaultTile(RItemTile tile) {
    if (tile.sliverTransformType != null) {
      return false;
    }
    if (tile.fillRemaining) {
      return false;
    }
    return tileList.isNotEmpty;
  }

  /// 询问是否支持[tile]的变换/转换
  /// 返回true, 表示支持, 则之后的[tile]将会交给self处理
  @entryPoint
  bool isSupportTransform(BuildContext context, Widget tile);

  /// 执行转换,
  /// [isSupportTransform] 返回true后, 才会执行此方法
  /// [origin] 原始的小部件列表
  /// [result] 输出转换后的小部件列表
  /// [tile] 当前的小部件, 在[origin]中的, 极大可能是[RItemTile]
  /// [warpTile] 被[BaseWrapTileTransform]包裹后的小部件, 也有可能没有包裹
  /// 返回true, 表示处理了
  /// 返回false, 表示未处理
  @entryPoint
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
  );

  /// 结束当前的变化, 如果需要处理的话
  @entryPoint
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
  );

  /// 重置
  @property
  void reset() {
    tileList = [];
  }
}

/// 将[RItemTile]转换成[SliverMainAxisGroup]
class SliverMainAxisGroupTransform extends BaseTileTransform {
  RItemTile? headerTile;
  Widget? headerWidget;

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      (tile.sliverTransformType == SliverMainAxisGroup ||
          (tile.sliverTransformType == null &&
              (tileList.isNotEmpty || headerWidget != null)));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
  ) {
    if (tileList.isNotEmpty || headerWidget != null) {
      result.add(buildTransformWrapWidget(
        context,
        headerTile,
        headerWidget,
        tileList,
      ));
      reset();
    }
  }

  @override
  void reset() {
    super.reset();
    headerTile = null;
    headerWidget = null;
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
  ) {
    if (tile is RItemTile) {
      if (tile.part) {
        //强行使用分开标识
        endTransformIfNeed(context, origin, result);
      }
      if (tile.isHeader) {
        //分组的头
        if (headerTile != null) {
          //之前已经有一个组了
          endTransformIfNeed(context, origin, result);
        }
        headerTile = tile;
        headerWidget = buildTileWidget(context, tile, tile);
      } else {
        tileList.add(buildTileWidget(context, tile, tile));
      }
      return true;
    }
    return false;
  }

  /// 一组[sliverChild]
  /// [SliverMainAxisGroup]
  /// [buildSliverGrid]
  Widget buildTransformWrapWidget(
    BuildContext context,
    RItemTile? headerTile,
    Widget? headerWidget,
    WidgetList sliverChild,
  ) {
    //debugger();
    return wrapSliverPaddingDecorationTile(
      headerTile,
      SliverMainAxisGroup(slivers: [
        if (headerWidget != null) headerWidget,
        ...buildTileListWidget(context, sliverChild),
      ]),
    );
  }
}

/// 将[RItemTile]收集到成[SliverList]
class SliverListTransform extends BaseTileTransform {
  SliverListTransform();

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      (tile.sliverTransformType == SliverList || isSupportDefaultTile(tile));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
  ) {
    if (tileList.isNotEmpty) {
      result.add(buildTransformWrapWidget(context, tileList));
      reset();
    }
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
  ) {
    if (tile is RItemTile) {
      if (tile.part) {
        //强行使用分开标识
        endTransformIfNeed(context, origin, result);
      }
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverList]
  /// [SliverAnimatedList]
  Widget buildTransformWrapWidget(
      BuildContext context, WidgetIterable sliverChild) {
    RItemTile first = sliverChild.firstWhere(
      (element) => element is RItemTile,
      orElse: () => const RItemTile(),
    ) as RItemTile;

    List<Widget> newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          tile.buildListWrapChild(
            context,
            sliverChild,
            tile,
            index,
          ),
        ));
      } else {
        newList.add(tile);
      }
    });
    return wrapSliverPaddingDecorationTile(
        first,
        SliverList.list(
          addAutomaticKeepAlives: first.addAutomaticKeepAlives,
          addRepaintBoundaries: first.addRepaintBoundaries,
          addSemanticIndexes: first.addSemanticIndexes,
          children: newList,
        ));
  }
}

/// 将[RItemTile]收集到成[SliverGrid]
class SliverGridTransform extends BaseTileTransform {
  SliverGridTransform();

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      tile.sliverTransformType == SliverGrid &&
      tile.crossAxisCount > 0;

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
  ) {
    if (tileList.isNotEmpty) {
      result.add(buildTransformWrapWidget(context, tileList));
      reset();
    }
  }

  /// 最后一个[RItemTile]的[SliverGrid]的[crossAxisCount]
  int? get lastCrossAxisCount {
    final last = tileList.lastOrNull;
    if (last is RItemTile) {
      return last.crossAxisCount;
    }
    return null;
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
  ) {
    if (tile is RItemTile) {
      if (tile.part) {
        //强行使用分开标识
        endTransformIfNeed(context, origin, result);
      }
      if (lastCrossAxisCount != null &&
          tile.crossAxisCount != lastCrossAxisCount) {
        //crossAxisCount不相同
        endTransformIfNeed(context, origin, result);
      }
      //debugger();
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverGrid]
  /// [SliverAnimatedGrid]
  Widget buildTransformWrapWidget(
      BuildContext context, WidgetIterable sliverChild) {
    RItemTile first = sliverChild.firstWhere(
      (element) => element is RItemTile,
      orElse: () => const RItemTile(),
    ) as RItemTile;

    WidgetList newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          tile.buildGridWrapChild(
            context,
            sliverChild,
            tile,
            index,
          ),
        ));
      } else {
        newList.add(tile);
      }
    });
    return wrapSliverPaddingDecorationTile(
        first,
        SliverGrid.count(
          crossAxisCount: first.crossAxisCount,
          mainAxisSpacing: first.mainAxisSpacing,
          crossAxisSpacing: first.crossAxisSpacing,
          childAspectRatio: first.childAspectRatio,
          children: newList,
        ));
  }
}

/// 将[RItemTile]收集到成[SliverReorderableList]
class SliverReorderableListTransform extends BaseTileTransform {
  SliverReorderableListTransform();

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      (tile.sliverTransformType == SliverReorderableList ||
          isSupportDefaultTile(tile));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
  ) {
    if (tileList.isNotEmpty) {
      result.add(buildTransformWrapWidget(context, tileList));
      reset();
    }
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
  ) {
    if (tile is RItemTile) {
      if (tile.part) {
        //强行使用分开标识
        endTransformIfNeed(context, origin, result);
      }
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverList]
  /// [SliverAnimatedList]
  Widget buildTransformWrapWidget(
    BuildContext context,
    WidgetIterable sliverChild,
  ) {
    RItemTile first = sliverChild.firstWhere(
      (element) => element is RItemTile,
      orElse: () => const RItemTile(),
    ) as RItemTile;

    List<Widget> newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          tile.buildListWrapChild(
            context,
            sliverChild,
            tile,
            index,
          ),
        ));
      } else {
        newList.add(tile);
      }
    });
    return wrapSliverPaddingDecorationTile(
        first,
        SliverReorderableList(
          onReorder: first.onTileReorder ??
              (int oldIndex, int newIndex) {
                assert(() {
                  l.d("oldIndex:$oldIndex newIndex:$newIndex");
                  /*if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = newList.removeAt(oldIndex);
                  newList.insert(newIndex, item);*/
                  return true;
                }());
              },
          onReorderStart: first.onTileReorderStart,
          onReorderEnd: first.onTileReorderEnd,
          itemCount: newList.length,
          itemBuilder: (context, index) {
            return newList[index].childKeyed(ValueKey(index));
          },
        ));
  }
}
