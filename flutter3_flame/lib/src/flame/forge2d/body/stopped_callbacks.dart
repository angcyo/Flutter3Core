import 'package:flame_forge2d/body_component.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

import 'body_mix.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/27
///
/// 刚体停止回调
mixin StoppedCallbacks<T extends BodyComponent> on BodyComponent {
  /// 停止检测的帧数
  @fb.configProperty
  int stoppedFramesMixin = 15;

  /// 是否检测多次停止, 否则只检测第一次停止
  @fb.configProperty
  bool multipleStopDetectionMixin = false;

  /// 球停止后的回调
  void Function(T component)? onStoppedAction;

  @override
  void update(double dt) {
    super.update(dt);
    updatePhysics(dt);
  }

  /// 球停止的帧数
  @fb.tempFlag
  int _stoppedFrames = 0;

  /// 球是否停止处理
  @fb.tempFlag
  bool _stopHandled = false;

  /// 更新物理模拟, 每一帧调用, 用于检测球是否停止
  void updatePhysics(double dt) {
    final isSlow = body.isStopped();

    if (isSlow) {
      // 停止帧数累加
      _stoppedFrames++;
    } else if (_stopHandled) {
      // 已经检测到停止，但仍在继续检测
      if (multipleStopDetectionMixin) {
        _stopHandled = false;
        _stoppedFrames = 0;
      }
    } else {
      _stoppedFrames = 0;
      _stopHandled = false;
    }

    // 连续 15 帧低速，才认定停止
    if (_stoppedFrames >= stoppedFramesMixin && !_stopHandled) {
      _stopHandled = true;
      onSelfStopped();
    }
  }

  /// 自身停止的回调
  @fb.overridePoint
  void onSelfStopped() {
    assert(() {
      fb.l.w("[${classHash()}]已停止运动->$this");
      return true;
    }());
    onStoppedAction?.call(this as T);
  }
}
