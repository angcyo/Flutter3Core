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

  /// 画布快速滑动组件
  late CanvasFlingComponent canvasFlingComponent =
      CanvasFlingComponent(canvasDelegate);

  /// 画布区域点击事件组件
  CanvasBoundsEventComponent canvasBoundsEventComponent =
      CanvasBoundsEventComponent();

  CanvasEventManager(this.canvasDelegate) {
    //
    addHandleEventClient(canvasTranslateComponent);
    addHandleEventClient(canvasScaleComponent);
    addHandleEventClient(canvasFlingComponent);
    //
    addHandleEventClient(canvasBoundsEventComponent);
  }

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    handleDispatchEvent(event);

    //
    canvasDelegate.canvasElementManager.handleElementEvent(event, entry);

    if (isDebug && event.isPointerUp) {
      final pivot = event.localPosition;
      l.d('pivot:$pivot->${canvasDelegate.canvasViewBox.offsetToSceneOriginPoint(pivot)}'
          '->${canvasDelegate.canvasViewBox.toScenePoint(pivot)}');
    }
  }
}

/// [CanvasViewBox] 操作基础组件
abstract class BaseCanvasViewBoxEventComponent
    with
        IHandleEventMixin,
        CanvasComponentMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin {
  final CanvasDelegate canvasDelegate;

  BaseCanvasViewBoxEventComponent(this.canvasDelegate);

  @override
  void dispatchPointerEvent(PointerEvent event) {
    if (!isCanvasComponentEnable) {
      return;
    }
    super.dispatchPointerEvent(event);
  }
}

/// 画布平移组件
class CanvasTranslateComponent extends BaseCanvasViewBoxEventComponent {
  /// 移动阈值, 移动值, 达到此值时, 才会触发移动
  /// [kTouchSlop] 18
  @dp
  double translateThreshold = 3;

  CanvasTranslateComponent(super.canvasDelegate);

  @override
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
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
          _translateBy(max(offset1.dx, offset2.dx), 0);
          return true;
        } else if (offset1.dx < 0 && offset2.dx < 0) {
          //向左移动
          _translateBy(min(offset1.dx, offset2.dx), 0);
          return true;
        }
      } else if (offset1.dy.abs() >= translateThreshold &&
          offset2.dy.abs() >= translateThreshold) {
        //纵向移动
        if (offset1.dy > 0 && offset2.dy > 0) {
          //向下移动
          _translateBy(0, max(offset1.dy, offset2.dy));
          return true;
        } else if (offset1.dy < 0 && offset2.dy < 0) {
          //向上移动
          _translateBy(0, min(offset1.dy, offset2.dy));
          return true;
        }
      }
    }
    return super.handleMultiPointerDetectorPointerEvent(event);
  }

  void _translateBy(double dx, double dy, {bool anim = false}) {
    dx *= 1 / canvasDelegate.canvasViewBox.scaleX;
    dy *= 1 / canvasDelegate.canvasViewBox.scaleY;
    isFirstEventHandled = true;
    translateBy(dx, dy, anim: anim);
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
class CanvasScaleComponent extends BaseCanvasViewBoxEventComponent
    with DoubleTapDetectorMixin {
  /// 缩放阈值, 缩放值, 达到此值时, 才会触发缩放
  /// [kScaleSlop]
  /// [kTouchSlop] 18
  @dp
  double scaleThreshold = kScaleSlop;

  /// 双击时, 需要放大的比例
  double doubleScaleValue = 1.5;

  CanvasScaleComponent(super.canvasDelegate);

  @override
  void dispatchPointerEvent(PointerEvent event) {
    addDoubleTapDetectorPointerEvent(event);
    super.dispatchPointerEvent(event);
  }

  @override
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) {
    final scale = doubleScaleValue;
    final pivot = event.localPosition;
    //debugger();
    scaleBy(
      scaleX: scale,
      scaleY: scale,
      pivot: canvasDelegate.canvasViewBox.toScenePoint(pivot),
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
        isFirstEventHandled = true;
        final scale = c2 / c1;
        final pivot = center(moveList.first, moveList.last);
        scaleBy(
            scaleX: scale,
            scaleY: scale,
            pivot: canvasDelegate.canvasViewBox.toScenePoint(pivot));
        return true;
      }
    } else {
      resetPointerMap(pointerDownMap, pointerMoveMap);
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

/// 画布快速滑动组件
class CanvasFlingComponent extends BaseCanvasViewBoxEventComponent
    with FlingDetectorMixin {
  /// 速度阈值, 速度达到这个值时, 才会触发fling
  double flingVelocityThreshold = 1000;

  /// 滑动阈值, 滑动超过这个值时, 才会触发fling
  @dp
  double flingTranslateThreshold = 3;

  CanvasFlingComponent(super.canvasDelegate);

  AnimationController? _flingController;

  @override
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
    //debugger();
    if (event.isPointerDown) {
      _flingController?.dispose();
      _flingController = null;
    }
    addFlingDetectorPointerEvent(event);
    return super.handleMultiPointerDetectorPointerEvent(event);
  }

  @override
  bool handleFlingDetectorPointerEvent(PointerEvent event, Velocity velocity) {
    //debugger();
    if (pointerCount == 2 && event.isPointerUp) {
      if (velocity.pixelsPerSecond.dx.abs() > flingVelocityThreshold) {
        //双指横向滑动
        l.d('fling:$velocity');
        isFirstEventHandled = true;
        _flingController = startFling((value) {
          canvasDelegate.canvasViewBox.translateTo(
            value,
            canvasDelegate.canvasViewBox.translateY,
            anim: false,
          );
        },
            vsync: canvasDelegate,
            fromValue: canvasDelegate.canvasViewBox.translateX,
            velocity: velocity.pixelsPerSecond.dx);
      } else if (velocity.pixelsPerSecond.dy.abs() > flingVelocityThreshold) {
        //双指纵向滑动
        l.d('fling:$velocity');
        isFirstEventHandled = true;
        _flingController = startFling((value) {
          canvasDelegate.canvasViewBox.translateTo(
            canvasDelegate.canvasViewBox.translateX,
            value,
            anim: false,
          );
        },
            vsync: canvasDelegate,
            fromValue: canvasDelegate.canvasViewBox.translateY,
            velocity: velocity.pixelsPerSecond.dy);
      }
    }
    return super.handleFlingDetectorPointerEvent(event, velocity);
  }
}
