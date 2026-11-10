import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/10
///
/// 游戏动画数字组件
/// 这个版本使用 Flame 的 TextComponent，直接在 update() 中插值，避免每次数字变化都创建新的动画组件。
///
/// 支持：
/// - 数字平滑变化
/// - 增加和减少颜色
/// - 缩放弹跳
/// - 动画曲线
/// - 小数位数
/// - 前缀、后缀
/// - 动画中途再次更新数值
/// - 暂停动画
/// - 立即设置数值
/// - 自动恢复默认颜色
enum NumberChangeType {
  /// 无变化
  none,

  /// 增加
  increase,

  /// 减少
  decrease,
}

class AnimatedNumberComponent extends TextComponent {
  // =========================
  // 配置
  // =========================

  final double duration;

  final Curve curve;

  final double fontSize;

  final Color defaultColor;

  final Color increaseColor;

  final Color decreaseColor;

  final bool animateScale;

  final bool animateColor;

  /// 小数位数
  final int decimalPlaces;

  /// 前缀
  final String prefix;

  /// 后缀
  final String suffix;

  // =========================
  // 数值状态
  // =========================

  double _currentValue;

  double _startValue;

  double _targetValue;

  double _elapsed = 0;

  bool _animating = false;

  // =========================
  // 动画状态
  // =========================

  double _scaleProgress = 0;

  Color _currentColor;

  NumberChangeType _changeType = NumberChangeType.none;

  // =========================
  // 构造
  // =========================

  AnimatedNumberComponent({
    required double value,
    super.position,
    super.anchor,
    this.duration = 0.4,
    this.curve = Curves.easeOutCubic,
    this.fontSize = 24,
    this.defaultColor = const Color(0xFFFFFFFF),
    this.increaseColor = const Color(0xFF40FF80),
    this.decreaseColor = const Color(0xFFFF4545),
    this.animateScale = true,
    this.animateColor = true,
    this.decimalPlaces = 0,
    this.prefix = '',
    this.suffix = '',
  }) : _currentValue = value,
       _startValue = value,
       _targetValue = value,
       _currentColor = defaultColor,
       super(
         text: '',
         priority: 100,
         textRenderer: TextPaint(
           style: TextStyle(
             fontSize: fontSize,
             fontWeight: .bold,
             color: defaultColor,
           ),
         ),
       ) {
    _refreshText();
  }

  // =========================
  // 当前数值
  // =========================

  double get value => _currentValue;

  // =========================
  // 目标数值
  // =========================

  double get targetValue => _targetValue;

  // =========================
  // 是否动画中
  // =========================

  bool get isAnimating => _animating;

  // =========================
  // 变化类型
  // =========================

  NumberChangeType get changeType => _changeType;

  // =========================
  // 更新目标数值
  // =========================

  void setValue(double value, {bool animated = true}) {
    if (value == _targetValue) {
      return;
    }

    final oldTarget = _targetValue;
    _targetValue = value;
    _startValue = _currentValue;
    _elapsed = 0;

    // 判断变化方向
    if (value > oldTarget) {
      _changeType = .increase;
    } else if (value < oldTarget) {
      _changeType = .decrease;
    } else {
      _changeType = .none;
    }

    if (!animated || duration <= 0) {
      _currentValue = value;
      _animating = false;
      _scaleProgress = 0;
      _changeType = .none;
      _refreshText();
      _updateColor();
      return;
    }

    _animating = true;
    _scaleProgress = 1;
    _updateColor();
  }

  // =========================
  // 立即设置
  // =========================

  void setValueImmediately(double value) {
    setValue(value, animated: false);
  }

  // =========================
  // 更新动画
  // =========================

  @override
  void update(double dt) {
    super.update(dt);

    if (!_animating) {
      return;
    }

    _elapsed += dt;

    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final curvedProgress = curve.transform(progress);

    // 数值插值
    _currentValue = _startValue + (_targetValue - _startValue) * curvedProgress;
    // 缩放动画进度
    _scaleProgress = 1 - progress;

    // 动画结束
    if (progress >= 1) {
      _currentValue = _targetValue;
      _animating = false;
      _scaleProgress = 0;
      _changeType = .none;
      _currentColor = defaultColor;
    }

    _refreshText();
    _updateColor();
  }

  // =========================
  // 更新文字
  // =========================

  void _refreshText() {
    final formatted = _currentValue.toStringAsFixed(decimalPlaces);
    text = '$prefix$formatted$suffix';
  }

  // =========================
  // 更新颜色
  // =========================

  void _updateColor() {
    if (!animateColor || _changeType == NumberChangeType.none) {
      _currentColor = defaultColor;
    } else if (_changeType == NumberChangeType.increase) {
      _currentColor = increaseColor;
    } else {
      _currentColor = decreaseColor;
    }
    paint.color = _currentColor;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: .bold,
        color: _currentColor,
      ),
    );
  }

  // =========================
  // 更新缩放
  // =========================

  @override
  void render(Canvas canvas) {
    if (animateScale && _scaleProgress > 0) {
      final pulse = math.sin(_scaleProgress * math.pi);
      final scaleValue = 1 + pulse * 0.25;
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(scaleValue);
      canvas.translate(-size.x / 2, -size.y / 2);
      super.render(canvas);
      canvas.restore();
      return;
    }
    super.render(canvas);
  }
}
