part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/14
///
/// 是否是[Sliver]小部件
bool isSliverWidget(Widget tile) {
  const systemSliverWidgetList = [
    SliverSafeArea,
    SliverAppBar,
    SliverToBoxAdapter,
    SliverPersistentHeader,
    SliverList,
    SliverGrid,
    SliverFixedExtentList,
    SliverPrototypeExtentList,
    SliverFillViewport,
    SliverFillRemaining,
    SliverAnimatedGrid,
    SliverAnimatedList,
    SliverPadding,
    DecoratedSliver,
    SliverAnimatedPaintExtent,
    SliverAnimatedSwitcher,
    SliverAnimatedSwitcher,
    SliverStack,
    SliverFadeTransition,
    SliverClip,
    SliverCrossAxisGroup,
    SliverConstrainedCrossAxis,
    SliverCrossAxisExpanded,
    SliverCrossAxisConstrained,
    SliverPositioned,
    PinnedHeaderSliver,
    SliverPinnedHeader,
    SliverResizingHeader,
    PreferredSizeSliverAppBar,
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
    return doTransformChildren(context, children, null);
  }

  /// 执行转换, 将输入的[children]转换成想要的[WidgetList]
  @api
  WidgetList doTransformChildren(
    BuildContext context,
    WidgetList children,
    RItemTile? parentTile,
  ) {
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
          //debugger();
          //支持当前的转换
          handle = _transformTile(
            lastTransform,
            context,
            children,
            result,
            tile,
            i,
            parentTile,
          );
        } else {
          //不支持当前的转换
          lastTransform.endTransformIfNeed(context, children, result, false);
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
            handle = _transformTile(
              transform,
              context,
              children,
              result,
              tile,
              i,
              parentTile,
            );
            break;
          }
        }
        //--
        if (lastTransform == null) {
          if (tile is RItemTile) {
            if (tile.sliverType != null) {
              assert(() {
                l.w('未找到对应的转换器转换type:[${tile.sliverType}]');
                return true;
              }());
            }
          }
        }
      }

      // 未找到转换器时, 则进行默认的转换处理
      if (!handle) {
        //debugger();
        lastTransform?.endTransformIfNeed(context, children, result, false);
        lastTransform = null;
        Widget child = tile;
        if (tile is RItemTile) {
          child = buildTileWidget(context, tile, tile);
        }
        if (parentTile == null) {
          result.add(_ensureSliver(child));
        } else {
          //如果具有parent, 则不进行[SliverToBoxAdapter]包裹
          //如果需要ensureSliver, 请在transform内部处理
          result.add(child);
        }
      }
    }
    //debugger();
    lastTransform?.endTransformIfNeed(context, children, result, false);
    return result;
  }

  /// [doTransformChildren]
  bool _transformTile(
    BaseTileTransform transform,
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
    RItemTile? parentTile,
  ) {
    final handle = transform.transformTile(
      context,
      origin,
      result,
      tile,
      index,
      parentTile,
    );
    if (tile is RItemTile) {
      final childTiles = tile.childTiles;
      if (childTiles != null) {
        //处理[RItemTile.childTiles]
        //debugger();
        final childResult = doTransformChildren(context, childTiles, tile);
        //debugger();
        for (var j = 0; j < childResult.length; j++) {
          final childTile = childResult[j];
          final childHandle = transform.transformTile(
            context,
            childTiles,
            childResult,
            childTile,
            j,
            tile,
          );
          if (!childHandle) {
            assert(() {
              l.w("注意[childTile]未被[${tile.sliverType}]处理.");
              return true;
            }());
          }
        }
      }
    }
    return handle;
  }

  /// 重置
  @entryPoint
  void reset() {
    for (final element in transformList) {
      element.reset(false);
    }
  }
}

mixin TileTransformMixin {
  //region ---build---

  /// 构建[RItemTile]描述的简单子部件
  /// [ensureSliverTile] 是否要保证返回的tile是sliver布局
  ///
  /// [buildTileWidget]
  /// [buildTileListWidget]
  Widget buildTileWidget(
    BuildContext context,
    Widget? tile,
    Widget child, {
    bool ignoreSliverPadding = false,
    bool ignoreSliverDecoration = false,
    bool ignoreSliverHeader = false,
    bool ignoreSliverFillRemaining = false,
    bool ensureSliverTile = false,
  }) {
    Widget result = child;
    if (tile is RItemTile) {
      if (!ignoreSliverDecoration) {
        result = wrapSliverDecoration(
          tile.sliverDecoration,
          tile.sliverDecorationPosition,
          result,
        );
      }
      if (!ignoreSliverPadding) {
        result = wrapSliverPadding(tile.sliverPadding, result);
      }
      if (!ignoreSliverHeader) {
        result = wrapHeaderTile(context, tile, result);
      }
      if (!ignoreSliverFillRemaining) {
        result = wrapSliverFillRemaining(context, tile, result);
      }
    }
    if (ensureSliverTile) {
      result = _ensureSliver(result);
    }
    return result;
  }

  /// 构建一组[RItemTile]描述的简单子部件
  /// [buildTileWidget]
  /// [buildTileListWidget]
  WidgetIterable buildTileListWidget(
    BuildContext context,
    WidgetIterable tileList, {
    bool ensureSliverTile = false,
  }) {
    return tileList.map((e) => e is RItemTile
        ? buildTileWidget(
            context,
            e,
            e,
            ensureSliverTile: ensureSliverTile,
          )
        : e);
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
          floating: tile.headerFloating,
          pinned: tile.headerPinned,
          titleSpacing: 0,
          toolbarHeight: height,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: tile.headerBarBackgroundColor,
          foregroundColor: tile.headerBarForegroundColor,
          expandedHeight: null,
          collapsedHeight: null,
          titleTextStyle: tile.headerBarTitleTextStyle,
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
          pinned: tile.headerPinned,
          floating: tile.headerFloating,
        );
      }
      return SliverPersistentHeader(
        delegate: tile.headerDelegate!,
        pinned: tile.headerPinned,
        floating: tile.headerFloating,
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
      sliver: _ensureSliver(sliverChild),
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
      sliver: _ensureSliver(sliverChild),
    );
  }

//endregion ---Sliver装饰---
}

/// 将一组变换好的小部件, 转换成另外一个小部件, 如果需要的话
/// [BaseWrapTileTransform]
abstract class BaseTileTransform with TileTransformMixin {
  /// 父[RItemTile],通常在指定了[RItemTile.childTiles]时, 会有值
  RItemTile? parentTile;

  /// 用来描述第一个元素的配置信息, 如果是[Group]组件, 则通常用来描述[Group]整体的样式
  RItemTile? firstTile;

  /// 收集到的[RItemTile], 用来读取配置.
  /// 有可能是[RItemTile],也有可能是普通的[Widget]
  List<Widget> tileList = [];

  /// 构造函数
  BaseTileTransform();

  /// 未指定变换类型的[tile]是否可以被处理
  @property
  bool isSupportDefaultTile(RItemTile tile) {
    if (tile.sliverType != null) {
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
  ///   [warpTile] 被[BaseWrapTileTransform]包裹后的小部件, 也有可能没有包裹
  /// [parentTile] 父容器的tile. 指定了[RItemTile.childTiles]时有效
  /// 返回true, 表示处理了
  /// 返回false, 表示未处理
  @entryPoint
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
    RItemTile? parentTile,
  );

  /// 结束当前的变化, 如果需要处理的话
  /// [fromPart] 是否是下一段
  @entryPoint
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    bool fromPart,
  );

  /// 重置
  /// [fromPart] 是否是下一段
  @property
  void reset(bool fromPart) {
    tileList = [];
    if (!fromPart) {
      firstTile = null;
      parentTile = null;
    }
  }
}

/// 将[RItemTile]转换成[SliverMainAxisGroup]
class SliverMainAxisGroupTransform extends BaseTileTransform {
  RItemTile? headerTile;
  Widget? headerWidget;

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      (tile.sliverType == SliverMainAxisGroup ||
          (tile.sliverType == null &&
              (tileList.isNotEmpty || headerWidget != null)));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    bool fromPart,
  ) {
    if (tileList.isNotEmpty || headerWidget != null) {
      result.add(_buildTransformSliverMainAxisGroupWrap(
        context,
        headerTile,
        headerWidget,
        tileList,
      ));
      reset(fromPart);
    }
  }

  @override
  void reset(bool fromPart) {
    super.reset(fromPart);
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
    RItemTile? parentTile,
  ) {
    this.parentTile = parentTile;
    if (tile is RItemTile) {
      firstTile ??= tile;

      if (tile.part) {
        //强行使用分开标识
        endTransformIfNeed(context, origin, result, true);
      }

      if (tile.isNoChild) {
        //no op
      } else if (tile.isHeader) {
        //分组的头
        if (headerTile != null) {
          //之前已经有一个组了
          endTransformIfNeed(context, origin, result, true);
        }
        headerTile = tile;
        headerWidget = buildTileWidget(
          context,
          tile,
          tile,
          ignoreSliverPadding: true,
          ignoreSliverDecoration: true,
        );
      } else {
        tileList.add(buildTileWidget(
          context,
          tile,
          tile,
          ignoreSliverPadding: true,
          ignoreSliverDecoration: true,
        ));
      }
      return true;
    } else if (parentTile != null) {
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 一组[sliverChild]
  /// [SliverMainAxisGroup]
  /// [buildTileListWidget]
  /// [buildListWrapChild]
  Widget _buildTransformSliverMainAxisGroupWrap(
    BuildContext context,
    RItemTile? headerTile,
    Widget? headerWidget,
    WidgetList sliverChild,
  ) {
    //debugger();

    List<Widget> newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          ensureSliverTile: true,
          tile.buildListWrapChild(
            context,
            sliverChild,
            tile,
            index,
            firstAnchor: headerTile,
          ),
        ));
      } else {
        newList.add(_ensureSliver(tile));
      }
    });

    return wrapSliverPaddingDecorationTile(
      headerTile ?? firstTile,
      SliverMainAxisGroup(slivers: [
        if (headerWidget != null) headerWidget,
        ...newList,
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
      (tile.sliverType == SliverList || isSupportDefaultTile(tile));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    bool fromPart,
  ) {
    if (tileList.isNotEmpty) {
      result.add(_buildTransformSliverListWrap(context, tileList));
      reset(fromPart);
    }
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
    RItemTile? parentTile,
  ) {
    this.parentTile = parentTile;
    if (tile is RItemTile) {
      //debugger(when: tile.tag == "debug");
      if (tile.part || tile.childTiles != null) {
        //强行使用分开标识/具有子元素
        endTransformIfNeed(context, origin, result, true);
        firstTile = null;
      }
      if (tile.childTiles == null) {
        tileList.add(tile);
      } else {
        //自身是一个容器, 此时自身不进行处理
        firstTile = tile;
      }
      return true;
    } else if (parentTile != null) {
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverList]
  /// [SliverAnimatedList]
  Widget _buildTransformSliverListWrap(
    BuildContext context,
    WidgetIterable sliverChild,
  ) {
    RItemTile first = firstTile ??
        sliverChild.firstWhere(
          (element) => element is RItemTile,
          orElse: () => const RItemTile(),
        ) as RItemTile;
    //debugger(when: first.tag == "debug");

    final List<Widget> newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          ignoreSliverDecoration: true,
          ignoreSliverPadding: true,
          tile.buildListWrapChild(
            context,
            sliverChild,
            tile,
            index,
            firstAnchor: firstTile ?? parentTile,
          ),
        ));
      } else {
        newList.add(tile);
      }
    });
    return wrapSliverPaddingDecorationTile(
        first,
        /*SliverList.list(
        addAutomaticKeepAlives: first.addAutomaticKeepAlives,
        addRepaintBoundaries: first.addRepaintBoundaries,
        addSemanticIndexes: first.addSemanticIndexes,
        children: newList,
      ),*/
        SliverList.builder(
          addAutomaticKeepAlives: first.addAutomaticKeepAlives,
          addRepaintBoundaries: first.addRepaintBoundaries,
          addSemanticIndexes: first.addSemanticIndexes,
          itemCount: newList.length,
          itemBuilder: (context, index) {
            return newList.getOrNull(index);
          },
        ));
  }
}

/// 将[RItemTile]收集到成[SliverGrid]
class SliverGridTransform extends BaseTileTransform {
  SliverGridTransform();

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      tile.sliverType == SliverGrid &&
      tile.crossAxisCount > 0;

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    bool fromPart,
  ) {
    if (tileList.isNotEmpty) {
      result.add(_buildTransformSliverGridWrap(context, tileList));
      reset(fromPart);
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
    RItemTile? parentTile,
  ) {
    this.parentTile = parentTile;
    if (tile is RItemTile) {
      if (tile.part || tile.childTiles != null) {
        //强行使用分开标识/具有子元素
        endTransformIfNeed(context, origin, result, true);
        firstTile = null;
      }
      if (lastCrossAxisCount != null &&
          tile.crossAxisCount != lastCrossAxisCount) {
        //crossAxisCount不相同
        endTransformIfNeed(context, origin, result, true);
        firstTile = null;
      }
      //debugger();
      if (tile.childTiles == null) {
        tileList.add(tile);
      } else {
        //自身是一个容器, 此时自身不进行处理
        firstTile = tile;
      }
      return true;
    } else if (parentTile != null) {
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverGrid]
  /// [SliverAnimatedGrid]
  Widget _buildTransformSliverGridWrap(
    BuildContext context,
    WidgetIterable sliverChild,
  ) {
    RItemTile first = firstTile ??
        sliverChild.firstWhere(
          (element) => element is RItemTile,
          orElse: () => const RItemTile(),
        ) as RItemTile;

    WidgetList newList = [];
    sliverChild.forEachIndexed((index, tile) {
      //debugger();
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          ignoreSliverDecoration: true,
          ignoreSliverPadding: true,
          tile.buildGridWrapChild(
            context,
            sliverChild,
            tile,
            index,
            firstAnchor: parentTile,
          ),
        ));
      } else {
        newList.add(tile);
      }
    });
    //debugger();
    return wrapSliverPaddingDecorationTile(
        first,
        /*SliverGrid.count(
        crossAxisCount: first.crossAxisCount,
        mainAxisSpacing: first.mainAxisSpacing,
        crossAxisSpacing: first.crossAxisSpacing,
        childAspectRatio: first.childAspectRatio,
        children: newList,
      ),*/
        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: first.crossAxisCount,
            mainAxisSpacing: first.mainAxisSpacing,
            crossAxisSpacing: first.crossAxisSpacing,
            childAspectRatio: first.childAspectRatio,
          ),
          itemCount: newList.length,
          itemBuilder: (context, index) {
            return newList.getOrNull(index);
          },
        ));
  }
}

/// 将[RItemTile]收集到成[SliverReorderableList]
class SliverReorderableListTransform extends BaseTileTransform {
  SliverReorderableListTransform();

  @override
  bool isSupportTransform(BuildContext context, Widget tile) =>
      tile is RItemTile &&
      (tile.sliverType == SliverReorderableList || isSupportDefaultTile(tile));

  @override
  void endTransformIfNeed(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    bool fromPart,
  ) {
    if (tileList.isNotEmpty) {
      result.add(_buildTransformSliverReorderableListWrap(context, tileList));
      reset(fromPart);
    }
  }

  @override
  bool transformTile(
    BuildContext context,
    WidgetList origin,
    WidgetList result,
    Widget tile,
    int index,
    RItemTile? parentTile,
  ) {
    this.parentTile = parentTile;
    if (tile is RItemTile) {
      if (tile.part || tile.childTiles != null) {
        //强行使用分开标识/具有子元素
        endTransformIfNeed(context, origin, result, true);
        firstTile = null;
      }
      if (tile.childTiles == null) {
        tileList.add(tile);
      } else {
        //自身是一个容器, 此时自身不进行处理
        firstTile = tile;
      }
      return true;
    } else if (parentTile != null) {
      tileList.add(tile);
      return true;
    }
    return false;
  }

  /// 构建成[SliverList]
  /// [SliverAnimatedList]
  Widget _buildTransformSliverReorderableListWrap(
    BuildContext context,
    WidgetIterable sliverChild,
  ) {
    RItemTile first = firstTile ??
        sliverChild.firstWhere(
          (element) => element is RItemTile,
          orElse: () => const RItemTile(),
        ) as RItemTile;

    List<Widget> newList = [];
    sliverChild.forEachIndexed((index, tile) {
      if (tile is RItemTile) {
        newList.add(buildTileWidget(
          context,
          tile,
          ignoreSliverDecoration: true,
          ignoreSliverPadding: true,
          tile.buildListWrapChild(
            context,
            sliverChild,
            tile,
            index,
            firstAnchor: firstTile ?? parentTile,
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
          proxyDecorator: first.onTileReorderProxyDecorator,
          itemCount: newList.length,
          itemBuilder: (context, index) {
            return newList[index].childKeyed(ValueKey(index));
          },
        ));
  }
}
