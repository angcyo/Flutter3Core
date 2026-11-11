import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 计时器组件
/// - 倒计时组件

class CountdownComponent extends PositionComponent {
  /// 倒计时总秒数
  final double duration;

  /// 倒计时结束回调
  final VoidCallback? onComplete;

  /// 是否自动开始
  final bool autoStart;

  /// 完成时是否移除
  final bool removeOnComplete;

  /// 是否显示小数
  final bool showMilliseconds;

  /// 文字大小
  final double fontSize;

  /// 文字颜色
  final Color color;

  /// 强制显示的文本
  String? text;

  late final TextPaint _textPaint;

  double _elapsed = 0;

  bool _started = false;

  bool _completed = false;

  bool _paused = false;

  CountdownComponent({
    required this.duration,
    this.text,
    this.onComplete,
    this.autoStart = true,
    this.removeOnComplete = true,
    this.showMilliseconds = false,
    this.fontSize = 48,
    this.color = Colors.white,
    super.position,
    super.anchor,
  }) {
    _textPaint = TextPaint(
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: .bold),
    );
  }

  /// 剩余时间
  double get remaining => (duration - _elapsed).clamp(0, duration);

  /// 是否完成
  bool get isCompleted => _completed;

  /// 是否正在运行
  bool get isRunning => _started && !_paused && !_completed;

  /// 开始倒计时
  void start() {
    if (_completed) return;

    _started = true;
    _paused = false;
  }

  /// 暂停
  void pause() {
    if (!_started || _completed) return;

    _paused = true;
  }

  /// 恢复
  void resume() {
    if (!_started || _completed) return;

    _paused = false;
  }

  /// 重置倒计时
  void reset({double? newDuration}) {
    _elapsed = 0;
    _started = false;
    _completed = false;
    _paused = false;

    if (newDuration != null) {
      // 如果需要动态修改 duration，
      // 建议将 duration 改为可变字段。
    }
  }

  @override
  FutureOr<void> onLoad() {
    if (autoStart) {
      start();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_started || _paused || _completed) {
      return;
    }

    _elapsed += dt;
    if (_elapsed >= duration) {
      _elapsed = duration;
      onSelfComplete();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final text = this.text ?? formatTime(remaining);
    final textComponent = TextComponent(text: text, textRenderer: _textPaint);
    size = textComponent.size;
    textComponent
      ..paint.color = color
      ..anchor = .center
      ..position = size / 2
      ..render(canvas);
  }

  /// 格式化时间
  String formatTime(double seconds) {
    if (showMilliseconds) {
      return seconds.toStringAsFixed(1);
    }
    return seconds.ceil().toString();
  }

  /// 倒计时完成
  void onSelfComplete() {
    _completed = true;
    onComplete?.call();
    if (removeOnComplete) {
      removeFromParent();
    }
  }
}
