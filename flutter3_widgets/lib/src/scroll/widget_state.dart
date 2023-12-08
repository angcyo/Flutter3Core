part of flutter3_widgets;

///
/// 情感图状态控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

enum WidgetState {
  /// 加载中状态
  loading,

  /// 正常数据状态
  none,

  /// 空数据状态
  empty,

  /// 错误状态
  error;

  /*const WidgetState([this.data]);

  final dynamic data;*/
}

mixin WidgetStateMixin {
  /// 当前的状态
  final ValueNotifier<WidgetState> widgetStateValue =
      ValueNotifier(WidgetState.none);

  /// 当前的错误信息
  dynamic error;

  /// 调用此方法更新状态
  /// 通过监听[widgetStateValue]的变化, 来更新UI
  @callPoint
  void updateWidgetState(WidgetState state, [dynamic error]) {
    if (state == WidgetState.error) {
      this.error = error;
    }
    widgetStateValue.value = state;
  }

  /// 根据不同的状态, 构建不同的Widget
  late WidgetBuilder buildWidgetStateWidget = (context) {
    var widgetState = widgetStateValue.value;
    switch (widgetState) {
      case WidgetState.loading:
        return buildLoadingWidgetState(context);
      case WidgetState.empty:
        return buildEmptyWidgetStateWidget(context);
      case WidgetState.error:
        return buildErrorWidgetStateWidget(context, error);
      default:
        return const Placeholder();
    }
  };

  /// 细分的[WidgetState.loading]状态
  late WidgetBuilder buildLoadingWidgetState = (context) {
    var globalConfig = GlobalConfig.of(context);
    return globalConfig.loadingIndicatorBuilder(context);
  };

  /// 细分的[WidgetState.empty]状态
  late WidgetBuilder buildEmptyWidgetStateWidget = (context) {
    return Container();
  };

  /// 细分的[WidgetState.error]状态
  late Widget Function(BuildContext context, dynamic error)
      buildErrorWidgetStateWidget = (context, error) {
    return Container();
  };
}
