part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/02
///
/// 导航条的混入
/// [BottomNavigationBar]
/// 直接调用[buildBottomNavigationBar]
///
mixin NavigationBarMixin<T extends StatefulWidget> on State<T> {
  /// 当前选中的导航索引
  int currentNavigateIndexMixin = 0;

  @override
  void initState() {
    super.initState();
    _updateNavigationIndexFromPageView();
  }

  /// [PageViewMixin]
  void _updateNavigationIndexFromPageView() {
    if (this is PageViewMixin) {
      final pageViewController = (this as PageViewMixin).pageViewController;
      currentNavigateIndexMixin =
          (this as PageViewMixin).currentPageIndex ??
          pageViewController?.initialPage ??
          currentNavigateIndexMixin;
    }
  }

  //region --BottomNavigationBar--

  /// 在[_BottomNavigationBarState.build]中, 底部导航有最小的约束
  /// ```
  /// constraints: BoxConstraints(minHeight: kBottomNavigationBarHeight + additionalBottomPadding)
  /// ```
  @api
  double getNavigationBarMinHeight(BuildContext context) {
    /*final double additionalBottomPadding =
        MediaQuery.viewPaddingOf(context).bottom;
    return kBottomNavigationBarHeight + additionalBottomPadding;*/
    return kBottomNavigationBarHeight;
  }

  /// 构建导航栏
  /// [buildBottomNavigationBar]->[buildBottomNavigationBarItems]
  ///
  /// [BottomNavigationBarItem]必须要有`label`属性
  @callPoint
  @overridePoint
  List<BottomNavigationBarItem> buildBottomNavigationBarItems(
    BuildContext context,
  ) => [];

  /// - [normal] 默认时的小部件
  /// - [active] 选中时的小部件
  @api
  BottomNavigationBarItem buildBottomNavigationBarItem(
    Widget normal, {
    Widget? active,
    String? label,
    String? tooltip,
    Color? backgroundColor,
    //--flex
    Axis axis = .horizontal,
    Widget? before,
    Widget? after,
    double? gap = kH,
    //--decoration
    EdgeInsetsGeometry? decorationPadding,
    Widget? Function(Widget? child, bool active)? wrapDecorationAction,
    Decoration? decoration,
    Decoration? activeDecoration,
  }) {
    //是否需要装饰
    final hasDecoration = decoration != null || activeDecoration != null;
    if (hasDecoration) {
      wrapDecorationAction ??= (child, active) => child
          ?.iw()
          .insets(h: kX, v: kM, insets: decorationPadding)
          .decoration(active ? activeDecoration : decoration)
          .align(.center);
    } else {
      wrapDecorationAction = (child, active) => child;
    }
    if (axis == .horizontal) {
      return BottomNavigationBarItem(
        icon: wrapDecorationAction(
          normal.rowOf(null, before: before, after: after, gap: gap),
          false,
        )!,
        activeIcon: wrapDecorationAction(
          active?.rowOf(null, before: before, after: after, gap: gap),
          true,
        ),
        label: label ?? "",
        tooltip: tooltip,
        backgroundColor: backgroundColor,
      );
    }
    return BottomNavigationBarItem(
      icon: wrapDecorationAction(
        normal.columnOf(null, before: before, after: after, gap: gap),
        false,
      )!,
      activeIcon: wrapDecorationAction(
        active?.columnOf(null, before: before, after: after, gap: gap),
        true,
      ),
      label: label ?? "",
      tooltip: tooltip,
      backgroundColor: backgroundColor,
    );
  }

  /// [kBottomNavigationBarHeight] 固定高度 56.0
  @api
  @callPoint
  Widget buildBottomNavigationBar(
    BuildContext context, {
    //--
    double elevation = 0,
    Color? backgroundColor = Colors.transparent,
    //--
    List<BottomNavigationBarItem>? items,
    //--
    Color? selectedItemColor,
    Color? unselectedItemColor,
    //--
    double selectedIconSize = 24.0,
    double? unselectedIconSize,
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
  }) {
    final globalTheme = GlobalTheme.of(context);
    items ??= buildBottomNavigationBarItems(context);
    //--
    selectedItemColor ??= globalTheme.icoSelectedColor;
    unselectedItemColor ??= globalTheme.icoNormalColor;
    //--
    final showLabel =
        showSelectedLabels == true || showUnselectedLabels == true;
    unselectedIconSize ??= selectedIconSize;
    final unselectedIconTheme = IconTheme.of(
      context,
    ).copyWith(color: unselectedItemColor, size: selectedIconSize);
    final selectedIconTheme = unselectedIconTheme.copyWith(
      color: selectedItemColor,
      size: unselectedIconSize,
    );

    final unselectedLabelStyle = showLabel
        ? globalTheme.textBodyStyle.copyWith(color: unselectedItemColor)
        : null;
    final selectedLabelStyle = showLabel
        ? unselectedLabelStyle?.copyWith(color: selectedItemColor)
        : null;

    return BottomNavigationBar(
      items: items,
      elevation: elevation,
      currentIndex: clamp(currentNavigateIndexMixin, 0, items.length - 1),
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      iconSize: selectedIconSize,
      //--
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      //--
      selectedLabelStyle: selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
      //--
      selectedFontSize: selectedLabelStyle?.fontSize ?? 0,
      unselectedFontSize: unselectedLabelStyle?.fontSize ?? 0,
      //--
      selectedIconTheme: selectedIconTheme,
      unselectedIconTheme: unselectedIconTheme,
      //--
      showSelectedLabels: showSelectedLabels,
      showUnselectedLabels: showUnselectedLabels,
      //--
      onTap: (index) {
        onSelfNavigationIndexChanged(context, index);
      },
    );
  }

  /// 底部导航改变回调
  @overridePoint
  void onSelfNavigationIndexChanged(BuildContext context, int index) {
    assert(() {
      l.v('onSelfNavigationIndexChanged:$index');
      return true;
    }());
    currentNavigateIndexMixin = index;
    if (this is PageViewMixin) {
      (this as PageViewMixin).switchPageMixin(index);
    }
    context.tryUpdateState();
  }

  //endregion --BottomNavigationBar--
}
