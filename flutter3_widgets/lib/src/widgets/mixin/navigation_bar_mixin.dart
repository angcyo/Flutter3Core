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
      currentNavigateIndexMixin = (this as PageViewMixin).currentPageIndex ??
          pageViewController?.initialPage ??
          currentNavigateIndexMixin;
    }
  }

  //region --BottomNavigationBar--

  /// 在[_BottomNavigationBarState.build]中, 底部导航有最小的约束
  /// ```
  /// constraints: BoxConstraints(minHeight: kBottomNavigationBarHeight + additionalBottomPadding)
  /// ```
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
          BuildContext context) =>
      [];

  /// [kBottomNavigationBarHeight]
  @callPoint
  Widget buildBottomNavigationBar(
    BuildContext context, {
    //--
    Color? backgroundColor,
    //--
    List<BottomNavigationBarItem>? items,
    //--
    Color? selectedItemColor,
    Color? unselectedItemColor,
    //--
    bool? showSelectedLabels,
    bool? showUnselectedLabels,
  }) {
    final globalTheme = GlobalTheme.of(context);
    items ??= buildBottomNavigationBarItems(context);
    //--
    selectedItemColor ??= globalTheme.icoSelectedColor;
    unselectedItemColor ??= globalTheme.icoNormalColor;
    //--
    final unselectedIconTheme =
        IconTheme.of(context).copyWith(color: unselectedItemColor);
    final selectedIconTheme =
        unselectedIconTheme.copyWith(color: selectedItemColor);

    final unselectedLabelStyle =
        globalTheme.textBodyStyle.copyWith(color: unselectedItemColor);
    final selectedLabelStyle =
        unselectedLabelStyle.copyWith(color: selectedItemColor);

    return BottomNavigationBar(
      items: items,
      elevation: 0,
      currentIndex: currentNavigateIndexMixin,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          backgroundColor ?? context.darkOr(null, Colors.transparent),
      //--
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      //--
      selectedLabelStyle: selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
      //--
      selectedFontSize: selectedLabelStyle.fontSize ?? 14.0,
      unselectedFontSize: unselectedLabelStyle.fontSize ?? 14.0,
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
