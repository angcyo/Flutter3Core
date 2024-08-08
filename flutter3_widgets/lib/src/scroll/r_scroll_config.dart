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
  WidgetList filterAndTransformTileList(
    BuildContext context,
    WidgetList children,
  ) {
    //过滤
    children = filterChain?.doFilter(children) ?? children;
    final transformChain = this.transformChain;
    final WidgetList result;
    if (transformChain != null) {
      transformChain.reset();
      //转换
      result = transformChain.doTransform(context, children);
    } else {
      result = children;
    }
    return result;
  }
}

/// 默认的滚动配置
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
