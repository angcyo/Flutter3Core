part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/07
///

/// 加载圈圈最小的尺寸大小
const double kMinLoadingIndicatorDimension = 24.0;

class LoadingIndicator extends StatelessWidget {
  final Size? size;

  const LoadingIndicator({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    double? width = size?.width ?? kMinLoadingIndicatorDimension;
    double? height = size?.height ?? kMinLoadingIndicatorDimension;
    var globalTheme = GlobalTheme.of(context);
    return UnconstrainedBox(
      child: SizedBox(
        width: width,
        height: height,
        child: CircularProgressIndicator(
          color: globalTheme.accentColor,
          strokeWidth: 2,
        ),
      ),
    ).repaintBoundary();
  }
}

/// 加载圈圈包裹小部件
class LoadingWrapWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const LoadingWrapWidget({
    super.key,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator =
        GlobalConfig.of(context).loadingIndicatorBuilder(context);
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      child: indicator,
    );
  }
}

/// 如果是加载中, 则显示转圈圈, 否则显示本体
class LoadingStateWidget extends StatelessWidget {
  /// 是否加载中
  final bool isLoading;

  /// 指定加载中的小部件
  final Widget? loading;

  /// 本体
  final Widget child;

  const LoadingStateWidget({
    super.key,
    this.loading,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    Widget loading = this.loading ??
        GlobalConfig.of(context).loadingIndicatorBuilder(context);
    return AnimatedSwitcher(
      duration: kDefaultAnimationDuration,
      child: isLoading ? loading : child,
    );
  }
}

extension LoadingWidgetEx on Widget {
  /// 加载圈圈包裹小部件
  Widget loadingWidget(
    bool isLoading, {
    Widget? loading,
  }) {
    return LoadingStateWidget(
      isLoading: isLoading,
      loading: loading,
      child: this,
    );
  }
}

extension LoadingValueListenableEx on ValueListenable<bool> {
  /// 加载圈圈包裹小部件
  Widget loadingWidget({
    required Widget child,
    Widget? loading,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: this,
      builder: (context, value, child) {
        return LoadingStateWidget(
          isLoading: value,
          loading: loading,
          child: child!,
        );
      },
      child: child,
    );
  }
}
