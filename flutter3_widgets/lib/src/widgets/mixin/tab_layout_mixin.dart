part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/09
///
/// [TabLayout]
/// 直接调用[buildTabLayout]
///
/// [onSelfTabIndexChanged]重写回调
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
  final UpdateSignalNotifier tabSelectedUpdateSignal =
      UpdateSignalNotifier(null);

  @override
  void dispose() {
    _tabLayoutControllerMixin.dispose();
    if (tabLayoutController != _tabLayoutControllerMixin) {
      tabLayoutController.dispose();
    }
    tabSelectedUpdateSignal.dispose();
    super.dispose();
  }

  //region --TabLayout--

  /// 构建子页面, 重写此方法需要手动处理指示器[buildTabLayoutIndicator]
  /// [buildTabLayout]->[buildTabLayoutChildren]
  /// [index] 当前选中的索引
  @callPoint
  @overridePoint
  WidgetList buildTabLayoutChildren(BuildContext context, int index) => [];

  /// 构建指示器
  @overridePoint
  Widget? buildTabLayoutIndicator(BuildContext context) =>
      buildGradientFillIndicator(context);

  //--

  /// 构建一个渐变颜色的指示器
  /// [fillColor] 使用纯色, 不使用渐变
  /// [fillDecoration]
  /// [buildTabLayoutIndicator]
  ///
  /// [buildGradientFillIndicator]
  /// [buildBottomLineIndicator]
  /// [buildBottomLineGradientIndicator]
  @api
  Widget buildGradientFillIndicator(
    BuildContext context, {
    Color? fillColor,
    List<Color>? colors,
    double? borderRadius = kDefaultBorderRadiusXX,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return DecoratedBox(
      decoration: fillDecoration(
        color: fillColor,
        radius: borderRadius,
        gradient: fillColor == null
            ? linearGradient(colors ??
                [
                  globalTheme.primaryColor,
                  globalTheme.primaryColorDark,
                ])
            : null,
      ),
    ).tabItemData(
      itemType: TabItemType.indicator,
      enableIndicatorFlow: true,
    );
  }

  /// 构建一个填充线条的指示器
  /// [fillDecoration]
  /// [buildTabLayoutIndicator]
  ///
  /// [buildGradientFillIndicator]
  /// [buildBottomLineIndicator]
  /// [buildBottomLineGradientIndicator]
  @api
  Widget buildBottomLineIndicator(
    BuildContext context, {
    double height = 2,
    double? width,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<Color>? colors,
    double? borderRadius = kDefaultBorderRadiusXX,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return DecoratedBox(
      decoration: fillDecoration(
        color: globalTheme.accentColor,
        radius: borderRadius,
        gradient: linearGradient(colors ??
            [
              globalTheme.accentColor,
              globalTheme.accentColor,
            ]),
      ),
    ).tabItemData(
      itemType: TabItemType.indicator,
      alignment: Alignment.bottomCenter,
      itemConstraints: LayoutBoxConstraints.fixedHeight(
        maxHeight: height,
        widthType: width != null ? ConstraintsType.fixedSize : null,
        maxWidth: width ?? double.infinity,
      ),
      enableIndicatorFlow: true,
      padding: padding,
      margin: margin,
    );
  }

  /// [width] 宽度
  ///
  /// [buildGradientFillIndicator]
  /// [buildBottomLineIndicator]
  /// [buildBottomLineGradientIndicator]
  @api
  Widget buildBottomLineGradientIndicator(
    BuildContext context, {
    double height = 2,
    double? width,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<Color>? colors,
    double? borderRadius = kDefaultBorderRadiusXX,
    bool enableIndicatorFlow = true,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return DecoratedBox(
      decoration: fillDecoration(
        color: globalTheme.accentColor,
        radius: borderRadius,
        gradient: linearGradient(colors ??
            context.darkOr(
              [
                globalTheme.lineLightColor,
                globalTheme.lineColor,
              ],
              [
                globalTheme.primaryColor,
                globalTheme.primaryColorDark,
              ],
            )!),
      ),
    ).tabItemData(
      itemType: TabItemType.indicator,
      alignment: Alignment.bottomCenter,
      itemConstraints: LayoutBoxConstraints.fixedHeight(
        maxHeight: height,
        widthType: width != null ? ConstraintsType.fixedSize : null,
        maxWidth: width ?? double.infinity,
      ),
      enableIndicatorFlow: enableIndicatorFlow,
      padding: padding,
      margin: margin,
    );
  }

  /// 构建[TabLayout]
  /// [gap] 间隙
  /// [autoClick] 是否自动处理点击事件
  ///
  /// [children].[childrenBuilder]或者[buildTabLayoutChildren]构建内容
  /// [childrenBuilder]可以根据[tabLayoutController.index]动态构建内容
  /// [tabSelectedUpdateSignal]
  ///
  /// [indicator]或者[buildTabLayoutIndicator]构建指示器
  ///
  @callPoint
  Widget buildTabLayout(
    BuildContext context, {
    List<Widget>? children,
    IndexChildrenBuilder? childrenBuilder,
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
    bool autoTextBold = false /*是否自动设置选中文本加粗*/,
    bool autoTextAnimate = true /*是否使用文本样式变化动画*/,
    bool firstIndexNotify = false /*首次mount时, 是否需要通知*/,
    void Function(int from, int to)? onIndexChangedAction,
    //--
    bool? pageViewAnimate,
    //--
    Color? normalTintColor /*正常时时的着色*/,
    Color? selectedTintColor /*选中时的着色*/,
  }) {
    return () {
      List<Widget>? body =
          children ?? childrenBuilder?.call(context, tabLayoutController.index);
      if (body != null) {
        if (autoTextBold) {
          final globalTheme = GlobalTheme.of(context);
          //--
          selectedTextStyle ??= globalTheme.textGeneralStyle;
          selectedTextStyle =
              selectedTextStyle!.copyWith(fontWeight: FontWeight.bold);
          //--
          normalTextStyle ??= globalTheme.textGeneralStyle;
          normalTextStyle =
              normalTextStyle!.copyWith(fontWeight: FontWeight.normal);
        }

        //选中文本样式支持
        if (selectedTextStyle != null) {
          body = body
              .mapIndex((child, index) => child.textStyle(
                    isTabIndexSelected(index)
                        ? selectedTextStyle
                        : normalTextStyle,
                    animate: autoTextAnimate,
                  ))
              .toList();
        }

        //着色支持
        if (normalTintColor != null || selectedTintColor != null) {
          body = body
              .mapIndex((child, index) => child.colorFiltered(
                    color: isTabIndexSelected(index)
                        ? selectedTintColor
                        : normalTintColor,
                  ))
              .toList();
        }

        if (autoClick) {
          body = body
              .mapIndex((child, index) => child.click(() {
                    if (this is PageViewMixin) {
                      tabLayoutController.selectedItem(
                        index,
                        animate: pageViewAnimate,
                        /*animate: (this as PageViewMixin).isPageViewNoAnimate
                            ? false
                            : null,*/
                        pageController:
                            (this as PageViewMixin).pageViewController,
                      );
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
        firstIndexNotify: firstIndexNotify,
        onIndexChanged: (from, to) {
          onSelfTabIndexChanged(context, from, to);
          onIndexChangedAction?.call(from, to);
        },
        children: body == null
            ? buildTabLayoutChildren(context, tabLayoutController.index)
            : [
                ...body,
                indicator ?? buildTabLayoutIndicator(context),
              ].filterNull(),
      );
    }.rebuild(
      tabSelectedUpdateSignal,
      enable: selectedTextStyle != null || autoTextBold || autoTextAnimate,
    );
  }

  /// 当前选中的tab的索引
  int get currentTabLayoutIndex => tabLayoutController.index;

  /// 指定的索引是否是tab选中的
  @api
  bool isTabIndexSelected(int index) => currentTabLayoutIndex == index;

  /// 选中指定的索引
  @api
  void selectedTabIndex(int index, {bool? animate}) {
    tabLayoutController.selectedItem(index, animate: animate);
  }

  /// tab索引改变回调
  @overridePoint
  void onSelfTabIndexChanged(BuildContext context, int from, int to) {
    tabSelectedUpdateSignal.updateValue(to);
    assert(() {
      l.v('onSelfTabIndexChanged:$from->$to');
      return true;
    }());
  }

//endregion --TabLayout--
}
