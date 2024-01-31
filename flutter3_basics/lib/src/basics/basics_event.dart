part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/30
///

extension EventEx on PointerEvent {
  /// 是否是手指操作相关事件
  bool get isTouchEvent =>
      synthesized == false /*非合成的事件*/ &&
      (isPointerDown || isPointerMove || isPointerFinish);

  /// 是否是按下事件
  bool get isPointerDown => this is PointerDownEvent;

  /// 是否是移动事件
  bool get isPointerMove => this is PointerMoveEvent;

  /// 是否是抬起事件
  bool get isPointerUp => this is PointerUpEvent;

  /// 是否是取消事件
  bool get isPointerCancel => this is PointerCancelEvent;

  /// 是否完成
  bool get isPointerFinish => isPointerUp || isPointerCancel;
}
