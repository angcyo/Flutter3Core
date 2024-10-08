part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/15
///

/// 滚动配置, 比如过滤器/转换器等
/// [RTileFilterChain]
/// [RTileTransformChain]
class RScrollConfig {
  /// [RItemTile] 的列表过滤器
  /// 用来过滤[children]
  /// [_defaultTileFilterChain]
  final RTileFilterChain? filterChain;

  /// [RItemTile] 的转换链
  /// 用来转换[filterChain]过滤后的[children]
  /// [_defaultTileTransformChain]
  final RTileTransformChain? transformChain;

  const RScrollConfig({
    this.filterChain,
    this.transformChain,
  });

  /// 向过滤一遍[children], 然后转换一遍[children]得到新的[children]
  @api
  @entryPoint
  WidgetList filterAndTransformTileList(
    BuildContext context,
    WidgetList children,
  ) {
    //debugger();
    //过滤链
    children = filterChain?.doFilter(children) ?? children;
    //转换链
    final transformChain = this.transformChain;
    final WidgetList result;
    if (transformChain != null) {
      transformChain.reset() /*重置转换器缓存*/;
      //转换
      //debugger();
      result = transformChain.doTransform(context, children);
    } else {
      //这里的[children]应该全是sliver, 否则会报错.
      result = children;
    }
    return result;
  }
}

/// 默认的滚动配置
/// [_RScrollViewState._transformTileList]入口点
RScrollConfig defaultScrollConfig = RScrollConfig(
  filterChain: _defaultTileFilterChain,
  transformChain: _defaultTileTransformChain,
);

//--

/// 默认的过滤链
const RTileFilterChain _defaultTileFilterChain =
    RTileFilterChain([ItemTileFilter()]);

/// 默认的转换链
RTileTransformChain _defaultTileTransformChain = RTileTransformChain([
  SliverListTransform(),
  SliverGridTransform(),
  SliverMainAxisGroupTransform(),
  SliverReorderableListTransform(),
]);
