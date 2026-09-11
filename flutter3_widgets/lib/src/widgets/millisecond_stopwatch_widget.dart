part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/11
///
/// 毫秒级秒表（Stopwatch）的完整封装小部件，具备开始、暂停、重置功能，且保持极高的性能表现。
/// 毫秒读秒/秒表小部件
class MillisecondStopwatch extends StatefulWidget {
  /// 是否自动开始
  final bool autoStart;

  /// 毫秒的位数
  final int millisecondDigits;

  /// 文本的样式
  @defInjectMark
  final TextStyle? textStyle;

  /// 文本的颜色
  final Color? textColor;

  const MillisecondStopwatch({
    super.key,
    this.autoStart = true,
    this.millisecondDigits = 2,
    this.textStyle,
    this.textColor,
  });

  @override
  State<MillisecondStopwatch> createState() => _MillisecondStopwatchState();
}

class _MillisecondStopwatchState extends State<MillisecondStopwatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    // 使用 unbounded 的 AnimationController 作为刷新驱动源
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_onTick);
    if (widget.autoStart) {
      _start();
    }
  }

  void _onTick() {
    // 仅在秒表运行时触发，通知 AnimatedBuilder 刷新局部 UI
    if (_stopwatch.isRunning) {
      // 触发 controller 关联的 AnimatedBuilder 重绘
      setState(() {});
    }
  }

  void _start() {
    _stopwatch.start();
    _controller.repeat(
      min: 0,
      max: 1,
      period: const Duration(seconds: 1),
    ); // 开启每帧刷新的 Ticker 循环
  }

  void _pause() {
    _stopwatch.stop();
    _controller.stop();
  }

  void _reset() {
    _stopwatch.reset();
    _controller.stop();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  /// 将 Duration 格式化为 MM:SS.mmm (分:秒.毫秒)
  String _formatElapsedTime(Duration duration) {
    String digits(int n, [int count = 2]) =>
        n.toString() /*.padLeft(count, '0')*/ .firstSubstring(count);

    final m = duration.inMinutes.remainder(60);
    final minutes = digits(m);
    final seconds = digits(duration.inSeconds.remainder(60));
    final milliseconds = digits(
      duration.inMilliseconds.remainder(1000),
      widget.millisecondDigits,
    );
    if (m > 0) {
      return "$minutes:$seconds.$milliseconds s";
    }
    return "$seconds.$milliseconds s";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final elapsed = _stopwatch.elapsed;
        return Text(
          _formatElapsedTime(elapsed),
          style:
              widget.textStyle ??
              GlobalTheme.of(context).textDesStyle.copyWith(
                color: widget.textColor,
                fontFeatures: [
                  // 关键技巧：开启等宽数字（Monospaced digits），防止数字跳动时文字摆动
                  FontFeature.tabularFigures(),
                ],
              ),
        );
      },
    );
  }
}
