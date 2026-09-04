import 'dart:math' as math;

import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// 神经网络节点激活（Neural Grid Matrix）
class AiNeuralGridLoading extends StatefulWidget {
  final double size;

  const AiNeuralGridLoading({super.key, this.size = 90.0});

  @override
  State<AiNeuralGridLoading> createState() => _AiNeuralGridLoadingState();
}

class _AiNeuralGridLoadingState extends State<AiNeuralGridLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _NeuralGridPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _NeuralGridPainter extends CustomPainter {
  final double progress;

  _NeuralGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = 6; // 节点的数量
    final radius = size.width * 0.38;

    final nodePaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    List<Offset> nodes = [];

    // 1. 计算分布在圆周上的节点位置
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (progress * 2 * math.pi * 0.2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      nodes.add(Offset(x, y));
    }

    // 2. 绘制节点之间的连线（根据相位计算透明度，模拟信号传输）
    for (int i = 0; i < count; i++) {
      for (int j = i + 1; j < count; j++) {
        final phase = (i + j) * 0.5 + progress * 2 * math.pi;
        final opacity = (0.1 + 0.4 * math.sin(phase)).clamp(0.05, 0.5);
        linePaint.color = const Color(0xFF6366F1).withOpacity(opacity);
        canvas.drawLine(nodes[i], nodes[j], linePaint);
      }
    }

    // 3. 绘制节点本身（闪烁呼吸效果）
    for (int i = 0; i < count; i++) {
      final nodePhase = i * 0.8 + progress * 2 * math.pi;
      final nodeOpacity = (0.3 + 0.7 * math.sin(nodePhase)).clamp(0.2, 1.0);
      final nodeRadius = 3.0 + 2.0 * math.sin(nodePhase);

      nodePaint.color = Color.lerp(
        const Color(0xFF818CF8),
        const Color(0xFFC084FC),
        (math.sin(nodePhase) + 1) / 2,
      )!.withOpacity(nodeOpacity);

      canvas.drawCircle(nodes[i], nodeRadius, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralGridPainter oldDelegate) => true;
}
