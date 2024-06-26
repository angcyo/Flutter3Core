part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 快速创建一个具有[Scaffold]脚手架和[RScrollView]滚动的页面
/// [RScrollView]
/// [AbsScrollPage]
/// [RScrollPage] 刷新,加载更多
/// [RStatusScrollPage] 状态切换
///
/// [buildScaffold]
mixin AbsScrollPage {
  //region Page

  /// 构建脚手架[Scaffold]
  @api
  @entryPoint
  Widget buildScaffold(
    BuildContext context, {
    WidgetList? children,
  }) {
    //debugger();
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: getBackgroundColor(context),
      body: buildBody(context, children),
    );
  }

  /// 获取页面背景颜色
  @property
  Color? getBackgroundColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //final globalConfig = GlobalConfig.of(context);
    return globalTheme.whiteBgColor;
  }

  //endregion Page

  //region Body

  /// 构建滚动内容
  /// [buildScaffold]
  /// [RScrollPage.pageRScrollView]
  @property
  Widget buildBody(BuildContext context, WidgetList? children) {
    children ??= buildScrollBody(context);
    if (this is RScrollPage) {
      return (this as RScrollPage).pageRScrollView(children: children);
    }
    return RScrollView(
      /*physics: null,
      scrollBehavior: null,*/
      children: children ?? [],
    );
  }

  /// 如果没有指定[children]时, 则调用此方法构建滚动内容
  @property
  WidgetList? buildScrollBody(BuildContext context) {
    return null;
  }

  //endregion Body

  //region AppBar

  /// 获取页面标题
  @property
  String? getTitle(BuildContext context) {
    return runtimeType.toString();
  }

  /// 构建标题栏
  @property
  Widget? buildTitle(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return getTitle(context)?.text(
        style: globalConfig.globalTheme.textTitleStyle.copyWith(
      color: globalConfig.globalTheme.appBarForegroundColor,
    ));
  }

  /// 构建标题栏上的返回按钮
  @property
  Widget? buildLeading(BuildContext context) => null;

  /// 构建标题栏上的动作按钮
  @property
  List<Widget>? buildActions(BuildContext context) => null;

  /// 获取标题栏高度
  @property
  double? getAppBarElevation(BuildContext context) => null;

  /// 获取标题栏滚动时的阴影高度
  @property
  double? getAppBarScrolledUnderElevation(BuildContext context) =>
      getAppBarElevation(context);

  /// 获取标题栏阴影颜色
  @property
  Color? getAppBarShadowColor(BuildContext context) => null;

  /// 获取标题栏前景色
  @property
  Color? getAppBarForegroundColor(BuildContext context) => null;

  /// 获取标题栏背景色
  @property
  Color? getAppBarBackgroundColor(BuildContext context) => null;

  /// 构建渐变背景
  @property
  Widget? buildAppBarFlexibleSpace(BuildContext context) {
    /*final globalTheme = GlobalTheme.of(context);
    return linearGradientWidget(
        listOf(globalTheme.themeWhiteColor));*/
    /*return listOf(globalTheme.primaryColor, globalTheme.primaryColorDark),*/
    return null;
  }

  /// 构建顶部导航[AppBar]
  /// [AppBarBuilderFn]
  @property
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    //debugger();
    return globalConfig.appBarBuilder(
      context,
      this,
      leading: buildLeading(context),
      title: buildTitle(context),
      actions: buildActions(context),
      bottom: buildAppBarBottom(context),
      elevation: getAppBarElevation(context),
      scrolledUnderElevation: getAppBarScrolledUnderElevation(context),
      foregroundColor: getAppBarForegroundColor(context),
      backgroundColor: getAppBarBackgroundColor(context),
      //阴影高度
      shadowColor: getAppBarShadowColor(context),
      flexibleSpace: buildAppBarFlexibleSpace(context), //渐变背景
    );
  }

  /// 构建顶部导航[AppBar]
  @property
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return null;
  }

//endregion AppBar
}
