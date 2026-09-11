///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/11
///
/// AI 功能提示组件
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

/// AI 功能提示组件类型
enum AiBadgeType {
  iconOnly, // 仅图标（适合放在 AppBar、Input Box 或按钮边缘）
  chip, // 带文字的标签（如 "AI 优化"、"AI 生成"）
}

class AiFeatureBadge extends StatelessWidget {
  @implementation
  static Widget buildShaderMask() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AiFeatureBadge.aiGradient.createShader(bounds),
      child: const AiFeatureBadge(type: AiBadgeType.iconOnly, iconSize: 24),
    );
  }

  final AiBadgeType type;
  final String label;
  final double iconSize;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const AiFeatureBadge({
    super.key,
    this.type = .iconOnly,
    this.label = 'AI',
    this.iconSize = 16.0,
    this.textStyle,
    this.onTap,
  });

  // 主流 AI 紫蓝渐变色值
  static const List<Color> aiGradientColors = [
    Color(0xFF4F46E5), // 科技蓝
    Color(0xFF9333EA), // 幻彩紫
    Color(0xFFEC4899), // 霓虹粉
  ];

  static const LinearGradient aiGradient = LinearGradient(
    colors: aiGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (type == AiBadgeType.iconOnly) {
      content = CustomPaint(
        size: Size(iconSize, iconSize),
        painter: _AiSparklePainter(),
      );
    } else {
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: aiGradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9333EA).withOpacity(0.35),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(iconSize, iconSize),
              painter: _AiSparklePainter(color: Colors.white),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style:
                  textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(cursor: SystemMouseCursors.click, child: content),
      );
    }

    return content;
  }
}

/// 使用 CustomPainter 绘制标准的 AI 四角星光（Sparkle）图标
class _AiSparklePainter extends CustomPainter {
  final Color? color;

  _AiSparklePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 如果未指定颜色，默认使用渐变着色
    if (color == null) {
      paint.shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        AiFeatureBadge.aiGradientColors,
        [0.0, 0.5, 1.0],
      );
    } else {
      paint.color = color!;
    }

    // 绘制主四角星 (占据整个尺寸的 75%)
    final Path mainStar = _createSparklePath(
      center: Offset(size.width * 0.45, size.height * 0.55),
      radius: size.width * 0.42,
    );

    // 绘制右上角辅助小四角星 (营造灵感迸发感)
    final Path subStar = _createSparklePath(
      center: Offset(size.width * 0.82, size.height * 0.22),
      radius: size.width * 0.2,
    );

    canvas.drawPath(mainStar, paint);
    canvas.drawPath(subStar, paint);
  }

  /// 构建四角星 Path (凹多边形曲线插值)
  Path _createSparklePath({required Offset center, required double radius}) {
    final Path path = Path();
    final double innerRadius = radius * 0.25; // 控点的内凹程度

    for (int i = 0; i < 4; i++) {
      double angle = i * math.pi / 2; // 0, 90, 180, 270 度
      double nextAngle = (i + 1) * math.pi / 2;

      // 顶点
      double x1 = center.dx + radius * math.cos(angle);
      double y1 = center.dy + radius * math.sin(angle);

      // 内凹控制点
      double controlAngle = angle + math.pi / 4;
      double cx = center.dx + innerRadius * math.cos(controlAngle);
      double cy = center.dy + innerRadius * math.sin(controlAngle);

      // 下一个顶点
      double x2 = center.dx + radius * math.cos(nextAngle);
      double y2 = center.dy + radius * math.sin(nextAngle);

      if (i == 0) {
        path.moveTo(x1, y1);
      }

      // 二次贝塞尔曲线实现向内凹陷的弧度
      path.quadraticBezierTo(cx, cy, x2, y2);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _AiSparklePainter oldDelegate) =>
      color != oldDelegate.color;
}
