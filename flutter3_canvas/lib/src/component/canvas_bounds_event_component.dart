part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 画布指定位置点击/长按事件处理组件

/// 事件类型回调
typedef OnCanvasBoundsEventAction = bool Function(
    PointerEvent event, TouchDetectorType touchType);

/// 画布指定区域事件处理组件
class CanvasBoundsEventComponent
    with
        CanvasComponentMixin,
        IHandlePointerEventMixin,
        TouchDetectorMixin,
        CanvasDelegateManagerMixin {
  @override
  final CanvasDelegate canvasDelegate;

  /// 事件监听
  Set<OnCanvasBoundsEventAction> boundsEventActionList = {};

  /// 指定区域的事件监听
  @viewCoordinate
  Map<Rect, OnCanvasBoundsEventAction> boundsEventActionMap = {};

  CanvasBoundsEventComponent(this.canvasDelegate);

  @override
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isCanvasComponentEnable) {
      addTouchDetectorPointerEvent(event);
    }
    return super.onPointerEvent(dispatch, event);
  }

  @override
  bool onTouchDetectorPointerEvent(
    PointerEvent event,
    TouchDetectorType touchType,
  ) {
    //l.d('${event.localPosition} $touchType');
    bool handled = false;
    if (boundsEventActionList.isNotEmpty) {
      for (final action in boundsEventActionList.clone()) {
        handled = action(event, touchType) || handled;
      }
    }
    if (boundsEventActionMap.isNotEmpty) {
      final action = hitBoundsEventAction(event.localPosition);
      if (action != null) {
        handled = action(event, touchType) || handled;
      }
    }
    //--
    if (!handled &&
        boundsEventActionList.isEmpty &&
        boundsEventActionMap.isEmpty) {
      //默认处理, 当点击画布左上角时触发
      if (touchType == TouchDetectorType.click) {
        if (axisManager.axisIntersectBounds?.contains(event.localPosition) ==
            true) {
          canvasDelegate.canvasFollowManager
              .followCanvasContent(restoreDef: true);
          handled = true;
        }
      }
    }
    return handled || super.onTouchDetectorPointerEvent(event, touchType);
  }

  //--

  void addBoundsEventAction(OnCanvasBoundsEventAction action) {
    boundsEventActionList.add(action);
  }

  void removeBoundsEventAction(OnCanvasBoundsEventAction action) {
    boundsEventActionList.remove(action);
  }

  void addBoundsEventActionMap(
    @viewCoordinate Rect rect,
    OnCanvasBoundsEventAction action,
  ) {
    boundsEventActionMap[rect] = action;
  }

  void removeBoundsEventActionMap(Rect rect) {
    boundsEventActionMap.remove(rect);
  }

  /// 获取[position]命中的区域事件回调
  OnCanvasBoundsEventAction? hitBoundsEventAction(
      @viewCoordinate Offset position) {
    if (boundsEventActionMap.isNotEmpty) {
      for (final entry in boundsEventActionMap.entries) {
        if (entry.key.contains(position)) {
          return entry.value;
        }
      }
    }
    return null;
  }
}
