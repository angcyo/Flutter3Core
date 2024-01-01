part of flutter3_widgets;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/31
///
/// 混入一个[TabBar].[TabBarView]
/// [Tab]
/// [SingleTickerProviderStateMixin]
mixin TabBarMixin on TickerProvider {
  /// 界面集合, 这是必须要初始化的
  /// [buildTabBarView]
  /// [WidgetLifecycleEx.pageChildLifecycle]
  late WidgetList tabPageList = [];

  /// 支持任意[Widget]
  /// [Tab]
  /// [buildTabBar]
  late WidgetList tabItemList = [];

  /// tab控制器
  late TabController tabController = TabController(
      initialIndex: tabInitialIndex,
      length: min(
        tabPageList.length,
        tabItemList.length,
      ),
      vsync: this)
    ..addListener(() {
      onSelfTabChanged(tabController.index);
    });

  /// 获取初始化的tab索引
  int get tabInitialIndex => 0;

  /// 获取当前的tab索引
  int get tabIndex => tabController.index;

  /// tab切换回调
  @overridePoint
  void onSelfTabChanged(int index) {
    //pageController.jumpToPage(tabController.index);
    //tabController.animateTo(pageController.page?.round() ?? 0);
  }

  /// 构建[TabBar]
  /// [kTabLabelPadding]
  @callPoint
  TabBar buildTabBar(
    BuildContext context, {
    bool? isScrollable,
    TabAlignment? tabAlignment,
  }) {
    var globalTheme = GlobalTheme.of(context);
    return TabBar(
      tabs: tabItemList,
      //padding: EdgeInsets.all(kX),
      //整体内边距
      padding: EdgeInsets.zero,
      //tab内边距
      labelPadding: const EdgeInsets.symmetric(horizontal: kX),
      controller: tabController,
      automaticIndicatorColorAdjustment: true,
      indicatorColor: globalTheme.primaryColor,
      indicatorWeight: 2.0,
      //indicatorPadding: EdgeInsets.only(bottom: 10),
      //indicatorPadding: EdgeInsets.all(10),
      //indicator: strokeDecoration(),
      dividerHeight: 0,
      //dividerColor: ,
      unselectedLabelStyle: globalTheme.textBodyStyle,
      //labelColor:,
      labelStyle:
          globalTheme.textBodyStyle.copyWith(fontWeight: FontWeight.bold),
      //unselectedLabelColor: ,
      //unselectedLabelStyle:
      isScrollable: isScrollable ?? tabAlignment == TabAlignment.start,
      tabAlignment: tabAlignment,
    );
  }

  /// 构建[TabBarView]
  /// [WidgetLifecycleEx.pageLifecycle]
  @callPoint
  TabBarView buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: tabController,
      physics: null,
      viewportFraction: 1.0,
      children: tabPageList,
    );
  }
}
