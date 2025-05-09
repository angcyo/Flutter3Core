part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/07
///

/// 加载圈圈最小的尺寸大小
const double kMinLoadingIndicatorDimension = 28.0;
const double kStrokeLoadingIndicatorDimension = 36.0;

/// [CircularProgressIndicator]
/// [StrokeLoadingWidget]
class LoadingIndicator extends StatelessWidget {
  final Size? size;

  /// 当前进度的值, 如果有. [0.0-1.0]
  /// 指定表示明确的进度, null未指定表示不明确的进度.
  final double? progressValue;

  /// 是否使用系统样式
  final bool useSystemStyle;

  /// 颜色
  final Color? color;

  /// [CircularProgressIndicator]的约束
  final BoxConstraints? progressConstraints;

  const LoadingIndicator({
    super.key,
    this.size,
    this.progressValue,
    this.useSystemStyle = true,
    this.color,
    this.progressConstraints,
  });

  @override
  Widget build(BuildContext context) {
    double? width = size?.width ??
        (useSystemStyle
            ? kMinLoadingIndicatorDimension
            : kStrokeLoadingIndicatorDimension);
    double? height = size?.height ??
        (useSystemStyle
            ? kMinLoadingIndicatorDimension
            : kStrokeLoadingIndicatorDimension);
    final globalTheme = GlobalTheme.of(context);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: width,
        height: height,
        child: useSystemStyle
            ? CircularProgressIndicator(
                value: progressValue == -1 ? null : progressValue,
                color: color ?? globalTheme.accentColor,
                constraints: progressConstraints,
                strokeWidth: 2,
              )
            : StrokeLoadingWidget(
                progress: progressValue == -1 ? null : progressValue,
                color: color ?? Colors.white,
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
  final double? progressValue;
  final Color? color;

  const LoadingWrapWidget({
    super.key,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.progressValue,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator = GlobalConfig.of(context)
        .loadingIndicatorBuilder(context, this, progressValue, color);
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

  /// 指定加载中的小部件, 不指定则使用默认的转圈圈小部件
  final Widget? loading;

  /// 本体
  final Widget child;

  /// 当前进度的值, 如果有.
  final double? progressValue;

  final Color? color;

  const LoadingStateWidget({
    super.key,
    this.loading,
    this.progressValue,
    this.color,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    Widget loading = this.loading ??
        GlobalConfig.of(context)
            .loadingIndicatorBuilder(context, this, progressValue, color);
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

/// 加载指示器的样式
///
/// [LoadingIndicator]
enum LoadingIndicatorStyle {
  /// 系统圆环样式
  circularProgressSystem,

  ///
  strokeLoading,
  ;
}
