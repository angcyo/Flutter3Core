part of flutter3_canvas;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/04
/// 手势入口
class CanvasEventManager with Diagnosticable, PointerDispatchMixin {
  final CanvasDelegate canvasDelegate;

  /// 画布平移组件
  late CanvasTranslateComponent canvasTranslateComponent =
      CanvasTranslateComponent(canvasDelegate);

  /// 画布缩放组件
  late CanvasScaleComponent canvasScaleComponent =
      CanvasScaleComponent(canvasDelegate);

  CanvasEventManager(this.canvasDelegate) {
    addHandleEventClient(canvasTranslateComponent);
    addHandleEventClient(canvasScaleComponent);
  }

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    handleDispatchEvent(event);
  }
}

/// 画布平移组件
class CanvasTranslateComponent extends IHandleEvent
    with CanvasComponentMixin, MultiPointerDetectorMixin, HandleEventMixin {
  final CanvasDelegate canvasDelegate;

  /// 移动阈值, 移动值, 达到此值时, 才会触发移动
  /// [kTouchSlop] 18
  @dp
  double translateThreshold = 3;

  CanvasTranslateComponent(this.canvasDelegate);

  @override
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
    if (!isCanvasComponentEnable) {
      return false;
    }
    if (event.isPointerMove && pointerCount == 2) {
      //debugger();
      //双指移动
      final offsetList = MultiPointerDetectorMixin.getPointerDeltaList(
          pointerMoveMap, pointerDownMap);
      final offset1 = offsetList.first;
      final offset2 = offsetList.last;

      //l.d('$offsetList');

      if (offset1.dx.abs() >= translateThreshold &&
          offset2.dx.abs() >= translateThreshold) {
        //横向移动
        if (offset1.dx > 0 && offset2.dx > 0) {
          //向右移动
          translateBy(max(offset1.dx, offset2.dx), 0);
          return true;
        } else if (offset1.dx < 0 && offset2.dx < 0) {
          //向左移动
          translateBy(min(offset1.dx, offset2.dx), 0);
          return true;
        }
      } else if (offset1.dy.abs() >= translateThreshold &&
          offset2.dy.abs() >= translateThreshold) {
        //纵向移动
        if (offset1.dy > 0 && offset2.dy > 0) {
          //向下移动
          translateBy(0, max(offset1.dy, offset2.dy));
          return true;
        } else if (offset1.dy < 0 && offset2.dy < 0) {
          //向上移动
          translateBy(0, min(offset1.dy, offset2.dy));
          return true;
        }
      }
    }
    return super.handleMultiPointerDetectorPointerEvent(event);
  }

  @api
  void translateBy(double dx, double dy, {bool anim = false}) {
    canvasDelegate.canvasViewBox.translateBy(dx, dy, anim: anim);
  }

  @api
  void translateTo(double x, double y, {bool anim = false}) {
    canvasDelegate.canvasViewBox.translateTo(x, y, anim: anim);
  }
}

/// 画布缩放组件
class CanvasScaleComponent extends IHandleEvent
    with
        CanvasComponentMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin,
        DoubleTapDetectorMixin {
  final CanvasDelegate canvasDelegate;

  /// 缩放阈值, 缩放值, 达到此值时, 才会触发缩放
  @dp
  double scaleThreshold = 10;

  /// 双击时, 需要放大的比例
  double doubleScaleValue = 1.5;

  CanvasScaleComponent(this.canvasDelegate);

  @override
  void dispatchPointerEvent(PointerEvent event) {
    addDoubleTapDetectorPointerEvent(event);
    super.dispatchPointerEvent(event);
  }

  @override
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) {
    if (!isCanvasComponentEnable) {
      return false;
    }
    final scale = doubleScaleValue;
    final pivot = event.localPosition;
    scaleBy(
      scaleX: scale,
      scaleY: scale,
      pivot: canvasDelegate.canvasViewBox.offsetToSceneOriginPoint(pivot),
      anim: true,
    );
    return super.onDoubleTapDetectorPointerEvent(event);
  }

  @override
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
    if (!isCanvasComponentEnable) {
      return false;
    }
    if (event.isPointerMove && pointerCount == 2) {
      //debugger();
      //双指缩放
      final downList =
          MultiPointerDetectorMixin.getPointerPositionList(pointerDownMap);
      final moveList =
          MultiPointerDetectorMixin.getPointerPositionList(pointerMoveMap);

      //2点之间的距离
      final c1 = distance(downList.first, downList.last);
      final c2 = distance(moveList.first, moveList.last);

      //l.d('$offsetList');

      if ((c2 - c1).abs() >= scaleThreshold) {
        //缩放
        final scale = c2 / c1;
        final pivot = center(moveList.first, moveList.last);
        scaleBy(
            scaleX: scale,
            scaleY: scale,
            pivot:
                canvasDelegate.canvasViewBox.offsetToSceneOriginPoint(pivot));
        return true;
      }
    }
    return super.handleMultiPointerDetectorPointerEvent(event);
  }

  @api
  void scaleBy({
    double? scaleX,
    double? scaleY,
    Offset? pivot,
    bool anim = false,
  }) {
    canvasDelegate.canvasViewBox.scaleBy(
      sx: scaleX,
      sy: scaleY,
      pivot: pivot,
      anim: anim,
    );
  }

  @api
  void scaleTo({
    double? scaleX,
    double? scaleY,
    Offset? pivot,
    bool anim = false,
  }) {
    canvasDelegate.canvasViewBox.scaleTo(
      sx: scaleX,
      sy: scaleY,
      pivot: pivot,
      anim: anim,
    );
  }
}
