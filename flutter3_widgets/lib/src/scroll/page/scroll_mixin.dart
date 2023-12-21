part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 快速创建一个具有[Scaffold]脚手架和[RScrollView]滚动的页面
///
mixin AbsScrollMixin {
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

  /// 构建顶部导航[AppBar]
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return globalConfig.appBarBuilder(
      context,
      this,
      title: buildTitle(context),
      /*elevation: 0,*/ //阴影高度
      /*flexibleSpace: linearGradientWidget(
          listOf(globalConfig.globalTheme.themeWhiteColor)),*/ //渐变背景
    );
  }

  //endregion AppBar

  //region Body

  /// 构建滚动内容
  WidgetList? buildScrollBody(BuildContext context) {
    return null;
  }

  /// 构建滚动内容
  Widget buildBody(BuildContext context, WidgetList? children) {
    return RScrollView(
      children: children ?? buildScrollBody(context) ?? [],
    );
  }

  //endregion Body

  /// 获取页面背景颜色
  Color? getBackgroundColor(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return globalConfig.globalTheme.whiteBgColor;
  }

  /// 构建脚手架[Scaffold]
  @api
  Widget buildScaffold(BuildContext context, WidgetList? children) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: getBackgroundColor(context),
      body: buildBody(context, children),
    );
  }
}
