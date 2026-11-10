import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 完整实现 GameButtonComponent
/// 这个版本支持：
/// - 自定义按钮尺寸、文字、颜色。
/// - 点击回调。
/// - 按压缩放动画。
/// - 呼吸光效。
/// - 点击粒子。
/// - 扩散光圈。
/// - 禁用状态。
/// - 动态修改文字。
/// - 动态修改按钮颜色。
class GameButtonComponent extends PositionComponent with TapCallbacks {
  /// 按钮文字
  String text;

  /// 按钮主颜色
  Color color;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 是否启用
  bool enabled;

  /// 圆角
  final double radius;

  /// 字体大小
  final double fontSize;

  /// 是否显示呼吸光效
  final bool glow;

  /// 按钮内边距
  final EdgeInsets padding;

  /// 按钮缩放动画
  double _scale = 1;

  /// 呼吸动画时间
  double _time = 0;

  /// 是否按下
  bool _pressed = false;

  /// 粒子
  final List<_ButtonParticle> _particles = [];

  /// 扩散光圈
  double _ringProgress = 1;

  final math.Random _random = math.Random();

  late final TextPaint _textPaint;

  GameButtonComponent({
    required this.text,
    this.color = const Color(0xFF00C8FF),
    this.onPressed,
    this.enabled = true,
    this.radius = 18,
    this.fontSize = 24,
    this.glow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    super.position,
    super.anchor = .center,
    super.size,
    super.scale,
    super.angle,
    super.children,
    super.priority,
  }) {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: .bold,
        letterSpacing: 2,
        shadows: [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 12)],
      ),
    );
    updateBounds();
  }

  /// 设置文字
  void setText(String value) {
    text = value;
    updateBounds();
  }

  /// 设置颜色
  void setColor(Color value) {
    color = value;
  }

  /// 设置启用状态
  void setEnabled(bool value) {
    enabled = value;

    if (!enabled) {
      _pressed = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // 按压缩放动画
    final targetScale = _pressed ? 0.92 : 1.0;

    _scale += (targetScale - _scale) * math.min(1.0, dt * 18);

    // 粒子更新
    for (final particle in _particles) {
      particle.update(dt);
    }

    _particles.removeWhere((particle) => particle.life <= 0);

    // 光圈扩散
    if (_ringProgress < 1) {
      _ringProgress += dt * 2.5;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // 以按钮中心进行缩放
    canvas.translate(size.x / 2, size.y / 2);

    canvas.scale(_scale);

    canvas.translate(-size.x / 2, -size.y / 2);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final currentColor = enabled ? color : Colors.grey;

    final alpha = enabled ? 1.0 : 0.35;

    // 呼吸光效
    final pulse = glow ? (math.sin(_time * 3) + 1) / 2 : 0.0;

    // 1. 外部光晕
    if (glow && enabled) {
      final glowPaint = Paint()
        ..color = currentColor.withValues(alpha: 0.15 + pulse * 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      canvas.drawRRect(rrect, glowPaint);
    }

    // 2. 按钮背景渐变
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: .topLeft,
        end: .bottomRight,
        colors: [
          currentColor.withValues(alpha: alpha),
          currentColor.withValues(alpha: alpha * 0.65),
          const Color(0xFF101A30).withValues(alpha: alpha),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, backgroundPaint);

    // 3. 内部高光
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: enabled ? 0.20 : 0.05),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, highlightPaint);

    // 4. 发光描边
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _pressed ? 3 : 1.5
      ..color = currentColor.withValues(
        alpha: enabled ? 0.75 + pulse * 0.25 : 0.3,
      );

    canvas.drawRRect(rrect, borderPaint);

    // 5. 按压增强边框光效
    if (_pressed && enabled) {
      final pressGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = currentColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawRRect(rrect, pressGlowPaint);
    }

    // 6. 粒子效果
    for (final particle in _particles) {
      particle.render(canvas);
    }

    // 7. 点击扩散光圈
    if (_ringProgress < 1 && enabled) {
      final ringRadius = size.x * 0.5 * _ringProgress;

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = currentColor.withValues(
          alpha: (1 - _ringProgress).clamp(0.0, 1.0),
        );

      canvas.drawCircle(Offset(size.x / 2, size.y / 2), ringRadius, ringPaint);
    }

    // 8. 按钮文字
    final contentWidth = size.x - padding.horizontal;

    final contentHeight = size.y - padding.vertical;

    final textPosition = Vector2(
      padding.left + contentWidth / 2,
      padding.top + contentHeight / 2,
    );

    _textPaint.render(canvas, text, textPosition, anchor: Anchor.center);

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!enabled) return;

    _pressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!enabled) return;

    _pressed = false;

    // 点击光圈重新开始
    _ringProgress = 0;

    // 创建粒子
    _createParticles();

    // 执行点击回调
    onPressed?.call();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  /// 创建点击粒子
  void _createParticles() {
    for (int i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * math.pi * 2;

      final speed = 80 + _random.nextDouble() * 180;

      _particles.add(
        _ButtonParticle(
          position: Vector2(size.x / 2, size.y / 2),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          life: 0.5 + _random.nextDouble() * 0.4,
        ),
      );
    }
  }

  /// 更新按钮尺寸
  void updateBounds() {
    InlineTextElement textElement = _textPaint.format(text);
    final measurements = textElement.metrics;
    textElement.translate(0, measurements.ascent);
    size.setValues(
      measurements.width + padding.horizontal,
      measurements.height + padding.vertical,
    );
  }
}

/// 按钮粒子
class _ButtonParticle {
  final Vector2 position;

  final Vector2 velocity;

  final Color color;

  double life;

  final double maxLife;

  _ButtonParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
  }) : maxLife = life;

  void update(double dt) {
    position.add(velocity * dt);

    life -= dt;
  }

  void render(Canvas canvas) {
    if (life <= 0) return;

    final progress = (life / maxLife).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(position.toOffset(), 3 + progress * 3, paint);
  }
}
