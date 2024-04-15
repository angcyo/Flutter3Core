part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/15
///

/// 滚动配置, 比如过滤器/转换器等
class RScrollConfig {
  /// [RItemTile] 的列表过滤器
  /// 用来过滤[children]
  /// [_defaultTileFilterChain]
  RTileFilterChain? filterChain;

  /// [RItemTile] 的转换链
  /// 用来转换[filterChain]过滤后的[children]
  /// [_defaultTileTransformChain]
  RTileTransformChain? transformChain;

  RScrollConfig({
    this.filterChain,
    this.transformChain,
  });
}

/// 默认的过滤链
RTileFilterChain _defaultTileFilterChain =
    const RTileFilterChain([ItemTileFilter()]);

/// 默认的转换链
RTileTransformChain _defaultTileTransformChain = RTileTransformChain([
  SliverListTransform(),
  SliverGridTransform(),
  SliverMainAxisGroupTransform(),
]);

/// 默认的滚动配置
RScrollConfig defaultScrollConfig = RScrollConfig(
  filterChain: _defaultTileFilterChain,
  transformChain: _defaultTileTransformChain,
);
