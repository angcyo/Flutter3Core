part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/24
///
/// - [ScaleAnimation] 缩放动画
/// - [RotateAnimation] 旋转动画
///
/// - [ScaleTransition] 实现原理
class ScaleAnimation extends StatefulWidget {
  final Widget child;

  /// 缩放开始值
  final double begin;

  /// 缩放结束值
  final double end;

  /// 动画持续时间
  @defInjectMark
  final Duration? duration;

  const ScaleAnimation(
    this.child, {
    super.key,
    this.begin = 1.0,
    this.end = 0.8,
    this.duration,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  /// 默认动画持续时间
  static final Duration _duration = const Duration(milliseconds: 800);

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void didUpdateWidget(covariant ScaleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool changed = false;
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration ?? _duration;
      changed = true;
    }
    if (oldWidget.begin != widget.begin || oldWidget.end != widget.end) {
      _scaleAnimation = Tween<double>(
        begin: widget.begin,
        end: widget.end,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      changed = true;
    }
    if (changed) {
      //_controller.reset();
      _controller.repeat(reverse: true);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? _duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 无限循环：放大 -> 缩小 -> 放大
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
