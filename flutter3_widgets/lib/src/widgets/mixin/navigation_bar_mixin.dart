part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/02
///
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

  /// 构建导航栏
  /// [buildBottomNavigationBar]->[buildBottomNavigationBarItems]
  @callPoint
  @overridePoint
  List<BottomNavigationBarItem> buildBottomNavigationBarItems(
          BuildContext context) =>
      [];

  /// [kBottomNavigationBarHeight]
  @callPoint
  Widget buildBottomNavigationBar(
    BuildContext context, {
    List<BottomNavigationBarItem>? items,
    Color? selectedItemColor,
    Color? unselectedItemColor,
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
      backgroundColor: Colors.transparent,
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
