part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/10
///
/// [RenderSliver]
/// [SliverToBoxAdapter]
extension SliverWidgetEx on Widget {
  /// - [SliverToBoxAdapter]
  Widget sliver({Key? key}) => SliverToBoxAdapter(key: key, child: this);
}
