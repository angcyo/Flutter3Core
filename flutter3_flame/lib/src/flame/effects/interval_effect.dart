import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/06
///
/// 间隔效果 / Interval Effect
/// 每间隔多久时间, 触发一次
/// - [Effect]
class IntervalEffect extends Component {
  /// 间隔时长，单位秒
  double interval;

  /// 总时长, 不设置, 则无限循环
  double? duration;

  /// 是否在效果结束后移除
  bool removeOnFinish;

  /// 触发回调
  VoidCallback? onTrigger;

  /// 完成的回调
  void Function()? onComplete;

  /// 首次是否立即触发
  bool immediate;

  IntervalEffect({
    required this.interval,
    this.duration,
    this.onTrigger,
    bool paused = false,
    this.immediate = true,
    this.removeOnFinish = true,
  }) : _paused = paused,
       _started = false,
       _finished = false;

  bool get isPaused => _paused;
  bool _paused;

  @fb.api
  void pause() => _paused = true;

  void resume() => _paused = false;

  /// 累计总时长
  double _totalElapsed = 0;

  /// 累计计时
  double _elapsed = 0;

  bool _started;
  bool _finished;

  @override
  void update(double dt) {
    if (_paused) {
      return;
    }
    if (!_started) {
      _started = true;
      onStart();
      if (immediate) {
        onSelfTrigger();
      }
    }
    if (_started) {
      _elapsed += dt;
      _totalElapsed += dt;
      if (_elapsed >= interval) {
        _elapsed -= interval;
        onSelfTrigger();
      }
    }
    if (duration != null && _totalElapsed >= duration!) {
      _finished = true;
      onFinish();
      if (removeOnFinish) {
        removeFromParent();
      }
    }
  }

  /// 间隔触发回调
  void onSelfTrigger() {
    onTrigger?.call();
  }

  /// 首次开始时调用
  void onStart() {}

  /// 首次结束时调用
  @fb.mustCallSuper
  void onFinish() {
    onComplete?.call();
  }
}
