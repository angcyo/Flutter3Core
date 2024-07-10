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
  final Widget child;
  final ProgressStateNotification? notification;

  const ProgressStateWidget({
    super.key,
    required this.child,
    this.notification,
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
          ? globalTheme.errorColor
          : (_notification?.color ?? globalTheme.accentColor),
    );
    return NotificationListener<ProgressStateNotification>(
      onNotification: (notification) {
        _notification = notification;
        updateState();
        return true;
      },
      child: widget.child.stackOf(
        progress
            .size(width: double.infinity, height: _notification?.height ?? 2)
            .offstage(_notification == null || _notification?.progress == null),
        alignment: Alignment.topCenter,
      ),
    );
  }
}

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
class ProgressStateInfo {
  /// 状态
  ProgressStateType state = ProgressStateType.normal;

  /// 进度状态时的进度值[0~1]
  double progress = 0;

  /// 错误状态时的错误信息
  dynamic error;

  ProgressStateInfo({
    this.state = ProgressStateType.normal,
    this.progress = 0,
    this.error,
  });

  /// 是否开始了
  bool get isStarted => state.index >= ProgressStateType.start.index;
}
