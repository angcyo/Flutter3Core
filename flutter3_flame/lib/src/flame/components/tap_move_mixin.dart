import 'package:flame/components.dart';
import 'package:flame/events.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/06
///
/// 按住移动精灵的 mixin
mixin TapMoveMixin on PositionComponent, TapCallbacks, DragCallbacks {
  /// 是否继续传播点击事件
  bool continuePropagationTapEvent = false;

  /// 是否继续传播拖动事件
  bool continuePropagationDragEvent = false;

  //MARK: Tap

  bool _isTapDown = false;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onStartTapDown(event);
  }

  /// 开始按下的回调
  void onStartTapDown(TapDownEvent event) {
    event.continuePropagation = continuePropagationTapEvent;
    _isTapDown = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    _isTapDown = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _isTapDown = false;
  }

  //MARK: Drag

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    event.continuePropagation = continuePropagationDragEvent;
  }

  ///
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    onStartDragUpdate(event);
  }

  /// 开始更新位置
  void onStartDragUpdate(DragUpdateEvent event) {
    //position += event.localDelta;
    position += event.canvasDelta;
  }

  ///
  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
  }

  ///
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
  }
}
