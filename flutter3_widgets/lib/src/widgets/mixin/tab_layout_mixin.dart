part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/09
///
/// [TabLayout]
/// 直接调用[buildTabLayout]
///
/// [PageViewMixin]
/// [TabLayoutMixin]
///
mixin TabLayoutMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  /// [tabLayoutController]
  late final TabLayoutController _tabLayoutControllerMixin =
      TabLayoutController(vsync: this);

  /// [TabLayout] tab控制
  TabLayoutController get tabLayoutController => _tabLayoutControllerMixin;

  /// tab选中之后的更新信号
  final UpdateSignalNotifier _tabSelectedUpdateSignal =
      UpdateSignalNotifier(null);

  @override
  void dispose() {
    _tabLayoutControllerMixin.dispose();
    if (tabLayoutController != _tabLayoutControllerMixin) {
      tabLayoutController.dispose();
    }
    _tabSelectedUpdateSignal.dispose();
    super.dispose();
  }

  //region --TabLayout--

  /// 构建子页面, 重写此方法需要手动处理指示器[buildTabLayoutIndicator]
  /// [buildTabLayout]->[buildTabLayoutChildren]
  @callPoint
  @overridePoint
  WidgetList buildTabLayoutChildren(BuildContext context) => [];

  /// 构建指示器
  @overridePoint
  Widget? buildTabLayoutIndicator(BuildContext context) {
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
    Widget? indicator /*指示器*/,
    TextStyle? selectedTextStyle /*选中之后的文本样式*/,
    TextStyle? normalTextStyle /*正常的文本样式*/,
  }) {
    return () {
      List<Widget>? body = children;
      if (body != null) {
        if (selectedTextStyle != null) {
          body = body
              .mapIndex((child, index) => child.textStyle(
                  isTabIndexSelected(index)
                      ? selectedTextStyle
                      : normalTextStyle))
              .toList();
        }

        if (autoClick) {
          body = body
              .mapIndex((child, index) => child.click(() {
                    if (this is PageViewMixin) {
                      tabLayoutController.selectedItem(index,
                          pageController:
                              (this as PageViewMixin).pageViewController);
                    } else {
                      tabLayoutController.selectedItem(index);
                    }
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
        onIndexChanged: onSelfTabIndexChanged,
        children: body == null
            ? buildTabLayoutChildren(context)
            : [
                ...body,
                indicator ?? buildTabLayoutIndicator(context),
              ].filterNull(),
      );
    }.rebuild(_tabSelectedUpdateSignal, enable: selectedTextStyle != null);
  }

  /// 指定的索引是否是tab选中的
  bool isTabIndexSelected(int index) => tabLayoutController.index == index;

  /// tab索引改变回调
  @overridePoint
  void onSelfTabIndexChanged(int from, int to) {
    _tabSelectedUpdateSignal.updateValue(to);
    assert(() {
      l.v('onSelfTabIndexChanged:$from->$to');
      return true;
    }());
  }

//endregion --TabLayout--
}
