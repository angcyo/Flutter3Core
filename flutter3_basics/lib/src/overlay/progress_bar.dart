part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/29
///
/// 进度条
/// [LinearProgressIndicator]
class ProgressBar extends StatefulWidget {
  /// 圆角半径
  final double? radius;

  /// 进度[0~1]
  final double? progress;

  /// 进度改变时, 是否要进行动画
  final bool enableProgressAnimate;

  /// 是否激活流动动画
  final bool enableFlowProgress;

  /// 进度颜色
  final Color? progressColor;

  /// 进度渐变颜色
  final List<Color>? progressColorList;

  /// 进度背景颜色
  final Color? bgColor;

  /// 进度背景渐变颜色
  final List<Color>? bgColorList;

  const ProgressBar({
    super.key,
    this.radius,
    this.progress,
    this.enableProgressAnimate = true,
    this.enableFlowProgress = true,
    this.progressColor,
    this.progressColorList,
    this.bgColor = Colors.black12,
    this.bgColorList,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  AnimationController? _flowController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kDefaultAnimationDuration,
      vsync: this,
    );
    _startFlowAnimation();
  }

  void _startFlowAnimation() {
    _flowController?.dispose();
    _flowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
      lowerBound: 0,
      upperBound: widget.progress ?? 0,
    );
    if (widget.enableFlowProgress) {
      _flowController?.repeat();
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableFlowProgress) {
      _startFlowAnimation();
    } else {
      _flowController?.stop();
    }
    if (widget.enableProgressAnimate) {
      final oldProgress = oldWidget.progress ?? 0;
      final newProgress = widget.progress ?? 0;
      if (oldProgress != newProgress) {
        _controller.animateTo(newProgress);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    Widget buildProgressBar() {
      return CustomPaint(
        painter: ProgressBarPainter(
          radius: widget.radius,
          progress:
              _controller.isAnimating ? _controller.value : widget.progress,
          flowProgress: widget.enableFlowProgress
              ? math.min(_flowController?.value ?? 0, widget.progress ?? 0)
              : null,
          progressColor: widget.progressColor ?? globalTheme.accentColor,
          progressColorList: widget.progressColorList ??
              [
                globalTheme.primaryColor,
                globalTheme.primaryColorDark,
              ],
          bgColor: widget.bgColor,
          bgColorList: widget.bgColorList,
        ),
        size: const Size(double.infinity, kMinInteractiveHeight),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _flowController == null
            ? buildProgressBar()
            : AnimatedBuilder(
                animation: _flowController!,
                builder: (context, child) {
                  return buildProgressBar();
                },
              );
      },
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  /// 圆角半径
  double? radius;

  /// 进度[0~1]
  double? progress;

  /// 流动动画进度[0~1]
  double? flowProgress;

  /// 进度颜色
  Color? progressColor;

  /// 进度渐变颜色
  List<Color>? progressColorList;

  /// 进度背景颜色
  Color? bgColor;

  /// 进度背景渐变颜色
  List<Color>? bgColorList;

  ProgressBarPainter({
    this.radius,
    this.progress,
    this.flowProgress,
    this.progressColor,
    this.progressColorList,
    this.bgColor,
    this.bgColorList,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //debugger();
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    final radius = this.radius ?? math.min(size.width, size.height);
    final rRect = rect.toRRect(radius);

    canvas.withClipRRect(rRect, () {
      //--bg
      if (bgColor != null) {
        paint.color = bgColor!;
      }
      if (bgColorList != null) {
        paint.shader = linearGradientShader(bgColorList!, rect: rect);
      }
      canvas.drawRRect(rect.toRRect(radius), paint);

      //--progress
      final progressRect =
          Offset.zero & Size(size.width * (progress ?? 0), size.height);
      if (progressColor != null) {
        paint.color = progressColor!;
      }
      if (progressColorList != null) {
        paint.shader =
            linearGradientShader(progressColorList!, rect: progressRect);
      }
      if (progress != null) {
        canvas.drawRRect(progressRect.toRRect(radius), paint);
      }

      //--flowProgress
      if (flowProgress != null) {
        final flowProgressRect =
            Offset.zero & Size(size.width * (flowProgress ?? 0), size.height);
        if (progressColorList != null) {
          paint.shader =
              linearGradientShader(progressColorList!, rect: flowProgressRect);
        }
        canvas.drawRRect(flowProgressRect.toRRect(radius), paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
