import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// 发光边框按钮
class GlowingBorderButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;

  const GlowingBorderButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = 200,
    this.height = 60,
    this.borderRadius = 30,
  });

  @override
  State<GlowingBorderButton> createState() => _GlowingBorderButtonState();
}

class _GlowingBorderButtonState extends State<GlowingBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 创建循环动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowingBorderPainter(
            progress: _controller.value,
            borderRadius: widget.borderRadius,
            borderWidth: 2.5,
            glowBlurRadius: 8.0,
            gradientColors: [
              Colors.transparent,
              globalTheme.accentColor,
              globalTheme.primaryColor,
              globalTheme.primaryColorDark,
              /*Colors.greenAccent,
              Colors.blueAccent,*/
              /*Color(0xFF00F2FE),
              Color(0xFF4FACFE),*/
              Colors.white, // 头部高亮
            ],
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black38 /*const Color(0xFF1E1E2C)*/,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    ).inkWell(widget.onPressed, borderRadiusNum: widget.borderRadius);
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;
  final double glowBlurRadius;
  final List<Color> gradientColors;

  _GlowingBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
    required this.glowBlurRadius,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final Path fullPath = Path()..addRRect(rrect);

    // 1. 获取路径测量对象
    final PathMetrics pathMetrics = fullPath.computeMetrics();
    final Path animatedPath = Path();

    // 假设流光线的长度占总边框长度的 30%
    const double lineLengthFraction = 0.30;

    for (final PathMetric metric in pathMetrics) {
      final double totalLength = metric.length;
      final double currentLength = totalLength * progress;
      final double lineLength = totalLength * lineLengthFraction;

      final double start = currentLength;
      final double end = currentLength + lineLength;

      if (end <= totalLength) {
        // 未跨越终点，直接截取
        animatedPath.addPath(metric.extractPath(start, end), Offset.zero);
      } else {
        // 跨越终点，分两段截取以实现无缝衔接
        animatedPath.addPath(
          metric.extractPath(start, totalLength),
          Offset.zero,
        );
        animatedPath.addPath(
          metric.extractPath(0, end - totalLength),
          Offset.zero,
        );
      }
    }

    // 2. 配置渐变着色器 (使亮端在前，虚化尾部在后)
    final Rect bounds = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: gradientColors,
        transform: GradientRotation(progress * 2 * 3.141592653589793),
      ).createShader(bounds);

    // 3. 绘制发光底影 (Glow Effect)
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurRadius)
      ..shader = paint.shader;

    // 先画发光背景，再画核心流光线
    canvas.drawPath(animatedPath, glowPaint);
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
