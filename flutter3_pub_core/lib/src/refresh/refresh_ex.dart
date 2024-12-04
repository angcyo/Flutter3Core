part of '../../flutter3_pub_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/04
///
/// ```
/// EasyRefresh(
///   header: MaterialHeader(),
///   footer: MaterialFooter(),
///   child: ListView(),
///   ....
/// );
/// // Global
/// EasyRefresh.defaultHeaderBuilder = () => ClassicHeader();
/// EasyRefresh.defaultFooterBuilder = () => ClassicFooter();
/// ```
bool isInitDefaultRefreshStyle = false;

/// 初始化默认的[EasyRefresh]样式
void initDefaultRefresh() {
  if (!isInitDefaultRefreshStyle || isDebug) {
    EasyRefresh.defaultHeaderBuilder = () => MaterialHeader(
          clamping: true,
          springRebound: false,
          color: GlobalConfig.def.globalTheme.accentColor,
        );
    EasyRefresh.defaultFooterBuilder = () => MaterialFooter(
          clamping: true,
          springRebound: false,
          color: GlobalConfig.def.globalTheme.accentColor,
        );
    isInitDefaultRefreshStyle = true;
  }
}

extension RefreshEx on Widget {
  /// 包裹一层[EasyRefresh]组件
  /// 被包裹的组件不能使用自定义的[physics],
  /// 必须使用null, 或者[childBuilder]回调的[physics]才能下拉刷新
  ///
  /// [onLoadData] 刷新/加载更多的回调, 返回值[IndicatorResult]
  ///
  /// [_EasyRefreshState._scrollBehaviorBuilder]
  ///
  ///
  Widget refresh({
    bool enableRefresh = true,
    bool enableLoad = false,
    FutureOr Function(bool isRefresh)? onLoadData,
    //--
    EasyRefreshController? controller,
    Header? header,
    Footer? footer,
    //--
  }) {
    initDefaultRefresh();
    /*return EasyRefresh.builder(
      childBuilder: (context, physics) {
        //_ERScrollPhysics -> AlwaysScrollableScrollPhysics
        debugger();
        return this;
      },
    );*/
    return EasyRefresh(
      //--
      onRefresh: enableRefresh
          ? () async {
              if (onLoadData == null) {
                return IndicatorResult.success;
              } else {
                return onLoadData.call(true);
              }
            }
          : null,
      //--
      onLoad: enableLoad
          ? () async {
              if (onLoadData == null) {
                return IndicatorResult.noMore;
              } else {
                return onLoadData.call(false);
              }
            }
          : null,
      //--
      controller: controller,
      header: header,
      footer: footer,
      //--
      child: this,
    );
  }
}
