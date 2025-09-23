part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/27
///
/// 进度状态通知, 底层发送进度, 上层做出响应
/// [PullBackWidget] 下拉进度
class ProgressStateNotification extends Notification {
  /// 通过[tag]视情况处理通知
  /// [PullBackWidget] 路由下拉返回通知
  final dynamic tag;

  /// 当前的进度[0~1]
  /// [-1]:不确定的进度
  final double? progress;

  /// 进度的颜色
  final Color? color;

  /// 进度的背景颜色
  final Color? backgroundColor;

  /// 进度条的高度
  final double? height;

  /// 是否有错误
  final dynamic error;

  const ProgressStateNotification({
    this.tag,
    this.progress,
    this.color,
    this.backgroundColor,
    this.height,
    this.error,
  });
}

/// 监听进度通知,并自动刷新进度状态的小部件
/// [ProgressStateNotification]
class ProgressStateWidget extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? childBuilder;
  final ProgressStateNotification? notification;

  //--
  /// 进度的颜色
  final Color? color;
  final Color? errorColor;

  /// 进度条的高度
  final double? height;

  const ProgressStateWidget({
    super.key,
    this.child,
    this.childBuilder,
    this.notification,
    //--
    this.color,
    this.errorColor,
    this.height,
  });

  @override
  State<ProgressStateWidget> createState() => _ProgressStateWidgetState();
}

class _ProgressStateWidgetState extends State<ProgressStateWidget> {
  ProgressStateNotification? _notification;

  @override
  void initState() {
    _notification = widget.notification;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProgressStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final isError = _notification?.error != null;
    final value = _notification?.progress;
    final progress = LinearProgressIndicator(
      value: isError ? 1 : (value == null || value == -1 ? null : value),
      backgroundColor: _notification?.backgroundColor ?? Colors.transparent,
      color: isError
          ? widget.errorColor ?? globalTheme.errorColor
          : (_notification?.color ?? widget.color ?? globalTheme.accentColor),
    );
    return NotificationListener<ProgressStateNotification>(
      onNotification: (notification) {
        _notification = notification;
        updateState();
        return true;
      },
      child:
          (widget.childBuilder != null
                  ? LayoutBuilder(
                      builder: (ctx, constraintsType) =>
                          widget.childBuilder!(ctx),
                    )
                  : widget.child)!
              .stackOf(
                progress
                    .size(
                      width: double.infinity,
                      height: _notification?.height ?? widget.height ?? 2,
                    )
                    .offstage(
                      _notification == null || _notification?.progress == null,
                    ),
                alignment: Alignment.topCenter,
              ),
    );
  }
}

/// 进度当前的状态期
enum ProgressStateType {
  /// 正常
  normal,

  /// 开始了
  start,

  /// 加载中
  loading,

  /// 完成 complete
  finish,

  /// 错误
  error,
}

/// 进度状态信息
/// - 当前状态
/// - 当前进度
/// - 错误数据
/// - 携带数据
class ProgressStateInfo {
  /// 无限进度
  static const double infinityProgress = -1;

  /// 无进度
  static const double noProgress = -100;

  /// 状态
  ProgressStateType state = ProgressStateType.normal;

  /// 进度状态时的进度值[0~1], -1:不确定的进度
  /// - [infinityProgress]
  double progress = 0;

  /// 错误状态时的错误信息
  dynamic error;

  /// 额外携带的数据信息
  dynamic data;

  /// 标签
  String tag;

  ProgressStateInfo({
    this.state = ProgressStateType.normal,
    this.progress = -1,
    this.error,
    this.data,
    String? tag,
  }) : tag = tag ?? $uuid;

  bool get isNone =>
      state == ProgressStateType.normal ||
      state == ProgressStateType.finish ||
      state == ProgressStateType.error;

  /// 是否需要开始
  bool get needStart =>
      state == ProgressStateType.normal || state == ProgressStateType.error;

  /// 是否开始进行中
  bool get isStart =>
      state == ProgressStateType.start || state == ProgressStateType.loading;

  /// 是否开始过了
  bool get isStarted =>
      state.index >= ProgressStateType.start.index &&
      state != ProgressStateType.error;

  /// 是否有进度了
  bool get isLoading => state == ProgressStateType.loading;

  /// 是否完成了
  bool get isFinish => state == ProgressStateType.finish;

  /// 是否有错误
  bool get isError => state == ProgressStateType.error;

  /// 是否结束, 包含完成/错误
  bool get isEnd => isFinish || isError;

  @override
  String toString() {
    return 'ProgressStateInfo{state: $state, progress: $progress, error: $error, data: $data, tag: $tag}';
  }
}

extension ProgressStateWidgetEx on Widget {
  /// 监听进度状态, 并自动刷新进度状态的小部件
  Widget progressStateWidget({
    ProgressStateNotification? notification,
    Color? color,
    Color? errorColor,
    double? height,
  }) {
    return ProgressStateWidget(
      notification: notification,
      color: color,
      errorColor: errorColor,
      height: height,
      child: this,
    );
  }
}

extension ProgressStateContextEx on BuildContext {
  /// [ProgressStateNotification]
  void dispatchProgressState({
    dynamic tag,
    double? progress = -1,
    Color? color,
    Color? backgroundColor,
    double? height,
    dynamic error,
    //--
  }) {
    ProgressStateNotification(
      tag: tag,
      progress: progress,
      color: color,
      backgroundColor: backgroundColor,
      height: height,
      error: error,
    ).dispatch(this);
  }
}
