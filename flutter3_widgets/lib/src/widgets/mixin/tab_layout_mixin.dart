part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/09
///
/// [TabLayout]
mixin TabLayoutMixin {
  /// [TabLayout] tab控制
  TabLayoutController get tabLayoutController;

  /// 构建子页面, 重写此方法需要手动处理指示器[buildTabLayoutIndicator]
  /// [buildTabLayout]->[buildTabLayoutChildren]
  @callPoint
  @overridePoint
  WidgetList buildTabLayoutChildren(BuildContext context) => [];

  /// 构建指示器
  @overridePoint
  Widget buildTabLayoutIndicator(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return DecoratedBox(
      decoration: fillDecoration(
        color: globalTheme.accentColor,
        gradient: linearGradient(
            [globalTheme.primaryColor, globalTheme.primaryColorDark]),
      ),
    ).tabItemData(
      itemType: TabItemType.indicator,
      enableIndicatorFlow: true,
    );
  }

  /// 构建[TabLayout]
  /// [autoClick] 是否自动处理点击事件
  @callPoint
  Widget buildTabLayout(
    BuildContext context, {
    List<Widget>? children,
    double gap = 0,
    String? autoEqualWidthRange,
    bool autoEqualWidth = false,
    Decoration? bgDecoration,
    Decoration? contentBgDecoration,
    EdgeInsets? padding,
    bool autoClick = true,
  }) {
    if (children != null) {
      if (autoClick) {
        children = children
            .mapIndex((child, index) => child.click(() {
                  tabLayoutController.selectedItem(index);
                }))
            .toList();
      }
    }
    return TabLayout(
      tabLayoutController: tabLayoutController,
      gap: gap,
      autoEqualWidth: autoEqualWidth,
      autoEqualWidthRange: autoEqualWidthRange,
      bgDecoration: bgDecoration,
      contentBgDecoration: contentBgDecoration,
      padding: padding,
      children: children == null
          ? buildTabLayoutChildren(context)
          : [
              ...children,
              buildTabLayoutIndicator(context),
            ],
    );
  }
}
