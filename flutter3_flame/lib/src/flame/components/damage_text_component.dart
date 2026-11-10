import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///

enum DamageTextType {
  /// 普通伤害
  normal,

  /// 暴击伤害
  critical,

  /// 护盾抵挡伤害
  shield,

  /// 回血
  heal,

  /// 未命中
  miss,

  /// 闪避
  dodge;

  /// 对应的颜色
  Color get color {
    switch (this) {
      case .normal:
        return const Color(0xFFFFFFFF);
      case .critical:
        return const Color(0xFFFF4545);
      case .shield:
        return const Color(0xFF40C4FF);
      case .heal:
        return const Color(0xFF40FF80);
      case .miss:
        return const Color(0xFFAAAAAA);
      case .dodge:
        return const Color(0xFF00FFFF);
    }
  }

  /// 对应的字体大小
  double get fontSize {
    switch (this) {
      case .normal:
        return 18;
      case .critical:
        return 28;
      case .shield:
        return 18;
      case .heal:
        return 20;
      case .miss:
        return 16;
      case .dodge:
        return 16;
    }
  }
}

/// 受伤文字视觉效果组件
class DamageTextComponent extends TextComponent {
  /// 启动延迟 s
  final double delay;

  ///
  DamageTextComponent({
    required String super.text,
    super.position,
    DamageTextType type = .normal,
    // 启动延迟
    this.delay = 0,
    // 动画时长
    double duration = 0.7,
    double fontSizeScale = 1,
    Color? color,
    //--
    double moveXBy = 0,
    double moveYBy = -50,
    //--
    double scaleStartEffect = 0.8,
    double scaleEndEffect = 1,
    double scaleDuration = .3,
  }) : _elapsed = delay,
       super(
         anchor: .center,
         priority: 100,
         textRenderer: TextPaint(
           style: TextStyle(
             fontSize: type.fontSize * fontSizeScale,
             fontWeight: .bold,
             color: color ?? type.color,
           ),
         ),
       ) {
    // 颜色在此处设置
    paint.color = color ?? type.color;

    // 初始缩放
    scale = Vector2.all(scaleStartEffect);

    // 向上移动
    add(
      MoveEffect.by(
        Vector2(moveXBy, moveYBy),
        EffectController(duration: duration, curve: Curves.easeOut),
      ),
    );

    // 淡出
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: duration, curve: Curves.easeIn),
      ),
    );

    // 放大
    add(
      ScaleEffect.to(
        Vector2.all(scaleEndEffect),
        EffectController(duration: scaleDuration, curve: Curves.easeOutBack),
      ),
    );

    // 动画结束自动移除
    add(RemoveEffect(delay: duration));
  }

  ///
  @override
  Paint get paint => super.paint;

  ///
  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  /// 已经经过的时间
  double _elapsed = 0;

  ///
  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void updateTree(double dt) {
    if (delay > 0) {
      _elapsed -= dt;
      if (_elapsed > 0) return;
    }
    super.updateTree(dt);
  }
}
