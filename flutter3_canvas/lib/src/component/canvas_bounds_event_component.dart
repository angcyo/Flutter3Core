part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 画布指定位置点击/长按事件处理组件

typedef OnCanvasBoundsEventAction = bool Function(
    PointerEvent event, TouchDetectorType touchType);

class CanvasBoundsEventComponent
    with CanvasComponentMixin, IHandleEventMixin, TouchDetectorMixin {
  /// 事件监听
  Set<OnCanvasBoundsEventAction> boundsEventAction = {};

  /// 指定区域的事件监听
  Map<Rect, OnCanvasBoundsEventAction> boundsEventActionMap = {};

  CanvasBoundsEventComponent();

  @override
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isCanvasComponentEnable) {
      addTouchDetectorPointerEvent(event);
    }
    return super.onPointerEvent(dispatch, event);
  }

  @override
  bool onTouchDetectorPointerEvent(
      PointerEvent event, TouchDetectorType touchType) {
    //l.d('${event.localPosition} $touchType');
    bool handled = false;
    if (boundsEventAction.isNotEmpty) {
      for (var action in boundsEventAction.clone()) {
        handled = action(event, touchType) || handled;
      }
    }
    if (boundsEventActionMap.isNotEmpty) {
      for (var entry in boundsEventActionMap.entries) {
        if (entry.key.contains(event.localPosition)) {
          handled = entry.value(event, touchType) || handled;
        }
      }
    }
    return handled || super.onTouchDetectorPointerEvent(event, touchType);
  }

  void addBoundsEventAction(OnCanvasBoundsEventAction action) {
    boundsEventAction.add(action);
  }

  void removeBoundsEventAction(OnCanvasBoundsEventAction action) {
    boundsEventAction.remove(action);
  }

  void addBoundsEventActionMap(Rect rect, OnCanvasBoundsEventAction action) {
    boundsEventActionMap[rect] = action;
  }

  void removeBoundsEventActionMap(Rect rect) {
    boundsEventActionMap.remove(rect);
  }
}
