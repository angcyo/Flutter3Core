part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 快速创建一个具有[Scaffold]脚手架和[RScrollView]滚动的页面
/// [RScrollView]
/// [AbsScrollPage]
/// [RScrollPage]
/// [RStatusScrollPage]
mixin AbsScrollPage {
  //region AppBar

  /// 获取页面标题
  String? getTitle(BuildContext context) {
    return runtimeType.toString();
  }

  /// 构建标题栏
  Widget? buildTitle(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return getTitle(context)?.text(
        style: globalConfig.globalTheme.textTitleStyle
            .copyWith(color: globalConfig.globalTheme.appBarForegroundColor));
  }

  /// 获取标题栏高度
  double? getAppBarElevation(BuildContext context) {
    return null;
  }

  /// 获取标题栏阴影颜色
  Color? getAppBarShadowColor(BuildContext context) {
    return null;
  }

  /// 获取标题栏前景色
  Color? getAppBarForegroundColor(BuildContext context) {
    return null;
  }

  /// 获取标题栏背景色
  Color? getAppBarBackgroundColor(BuildContext context) {
    return null;
  }

  /// 构建渐变背景
  Widget? buildAppBarFlexibleSpace(BuildContext context) {
    /*final globalTheme = GlobalTheme.of(context);
    return linearGradientWidget(
        listOf(globalTheme.themeWhiteColor));*/
    return null;
  }

  /// 构建顶部导航[AppBar]
  /// [AppBarBuilderFn]
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    //debugger();
    return globalConfig.appBarBuilder(
      context,
      this,
      title: buildTitle(context),
      bottom: buildAppBarBottom(context),
      elevation: getAppBarElevation(context),
      foregroundColor: getAppBarForegroundColor(context),
      backgroundColor: getAppBarBackgroundColor(context),
      //阴影高度
      shadowColor: getAppBarShadowColor(context),
      flexibleSpace: buildAppBarFlexibleSpace(context), //渐变背景
    );
  }

  /// 构建顶部导航[AppBar]
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return null;
  }

  //endregion AppBar

  //region Body

  /// 构建滚动内容
  WidgetList? buildScrollBody(BuildContext context) {
    return null;
  }

  /// 构建滚动内容
  /// [buildScaffold]
  /// [RScrollPage.pageRScrollView]
  Widget buildBody(BuildContext context, WidgetList? children) {
    children ??= buildScrollBody(context);
    if (this is RScrollPage) {
      return (this as RScrollPage).pageRScrollView(children: children);
    }
    return RScrollView(
      children: children ?? [],
    );
  }

  //endregion Body

  //region Page

  /// 获取页面背景颜色
  Color? getBackgroundColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //final globalConfig = GlobalConfig.of(context);
    return globalTheme.whiteBgColor;
  }

  /// 构建脚手架[Scaffold]
  @api
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

//endregion Page
}
