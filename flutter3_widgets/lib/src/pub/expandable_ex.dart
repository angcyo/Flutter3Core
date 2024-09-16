part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/22
///
/// 折叠/展开 支持动画的小部件
/// [ExpandableNotifier] 用来提供[ExpandableController]
/// [ScrollOnExpand] 展开或者收起时, 是否滚动到当前小部件
/// [ExpandablePanel] 展开/收起的小部件, 包含头部和内容,[ExpandableNotifier]
/// [ExpandableIcon] 展开/收起的图标带动画
extension ExpandableEx on Widget {
  /// 当前小部件需要控制折叠[collapse]和展开[expanded]小部件
  /// [header] 头部小部件
  /// [Expandable]
  Widget expanding({
    required Widget expanded,
    Widget? collapse,
    bool initialExpanded = false,
    ExpandableController? controller,
    ExpandableThemeData? theme,
    bool scrollOnExpand = true,
    bool scrollOnCollapse = true,
  }) {
    Widget expandable = (collapse ?? const Empty.zero()).orExpanded(
      expanded: expanded,
      controller: controller,
      theme: theme,
      wrapExpanded: false,
    );
    return ExpandableNotifier(
      controller: controller,
      initialExpanded: controller == null ? initialExpanded : null,
      child: ScrollOnExpand(
        scrollOnCollapse: scrollOnExpand,
        scrollOnExpand: scrollOnCollapse,
        theme: theme,
        child: [
          this,
          expandable,
        ].column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        )!,
      ),
    );
  }

  /// 当前小部件展开为[expanded]指定的小部件
  Widget orExpanded({
    required Widget expanded,
    ExpandableController? controller,
    ExpandableThemeData? theme,
    bool wrapExpanded = true,
    bool initialExpanded = false,
    bool scrollOnExpand = true,
    bool scrollOnCollapse = true,
  }) {
    //theme ??= const ExpandableThemeData(alignment: Alignment.topCenter);
    Widget result = Expandable(
      collapsed: this,
      expanded: expanded,
      controller: controller,
      theme: theme,
    );
    if (wrapExpanded) {
      result = ExpandableNotifier(
        controller: controller,
        initialExpanded: controller == null ? initialExpanded : null,
        child: ScrollOnExpand(
          scrollOnCollapse: scrollOnExpand,
          scrollOnExpand: scrollOnCollapse,
          theme: theme,
          child: result,
        ),
      );
    }
    return result;
  }
}
