part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/04
/// 手势入口
///
/// 用于控制画布相关的操作
/// [CanvasElementManager] 元素相关的手势在此类中实现
/// [CanvasElementControlManager]
///
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
  late CanvasBoundsEventComponent canvasBoundsEventComponent =
      CanvasBoundsEventComponent(canvasDelegate);

  /// 鼠标或者手势是否按下
  @output
  bool isPointerDown = false;

  CanvasEventManager(this.canvasDelegate) {
    //
    addHandleEventClient(canvasTranslateComponent);
    addHandleEventClient(canvasScaleComponent);
    addHandleEventClient(canvasFlingComponent);
    //
    addHandleEventClient(canvasBoundsEventComponent);
  }

  /// [event] 最原始的事件参数, 未经过加工处理
  /// [CanvasDelegate.handleEvent]驱动
  @entryPoint
  void handleEvent(@viewCoordinate PointerEvent event) {
    if (!event.isPointerHover) {
      /*assert((){
        l.d("handleEvent[${event.synthesized}]->$event");
        return true;
      }());*/
      //debugger();
    }
    //debugger();

    //--
    if (event.isPointerDown) {
      isPointerDown = true;
    }

    if (!_cancelDispatchEvent) {
      if (canvasDelegate.canvasStyle.enableWidgetRender) {
        _handleWidgetPainterEvent(event);
      }
      handleDispatchEvent(event);
      //元素操作事件
      final overlayComponent = canvasDelegate._overlayComponent;
      if (overlayComponent == null) {
        if (canvasDelegate.isDragMode) {
          //拖拽模式下, 不处理元素事件
        } else {
          canvasDelegate.canvasElementManager.handleElementEvent(event);
        }
      } else {
        overlayComponent.handleEvent(event);
      }
    }
    //--
    canvasDelegate.dispatchPointerEvent(event);
    //--
    if (event.isPointerFinish) {
      _cancelDispatchEvent = false;
      isPointerDown = false;
    }

    assert(() {
      /*if (event.isPointerUp) {
        final pivot = event.localPosition;
        l.v('抬手点:$pivot->${canvasDelegate.canvasViewBox.offsetToSceneOriginPoint(pivot)}'
            '->${canvasDelegate.canvasViewBox.toScenePoint(pivot)}');
      }*/
      return true;
    }());
  }

  /// 键盘事件处理
  /// [CanvasDelegate.handleKeyEvent]驱动
  @entryPoint
  bool handleKeyEvent(KeyEvent event) {
    final overlayComponent = canvasDelegate._overlayComponent;
    if (overlayComponent != null) {
      return overlayComponent.handleKeyEvent(event);
    }
    bool handle = false;
    //--
    if (canvasDelegate.canvasStyle.enableElementControl ||
        canvasDelegate.canvasStyle.enableElementKeyEvent == true) {
      //将事件发送元素
      for (final element
          in canvasDelegate.canvasElementManager.elements.reversed) {
        if (element.handleKeyEvent(event)) {
          handle = true;
          break;
        }
      }
    }
    return handle;
  }

  //--

  /// 临时取消事件调度派发, 抬手后恢复
  ///
  /// - [cancelDispatchEvent]
  @flagProperty
  bool _cancelDispatchEvent = false;

  /// 临时取消所有事件的派发
  @callPoint
  void cancelDispatchEvent(PointerEvent seedEvent) {
    final cancelEvent = createPointerCancelEvent(seedEvent);
    handleEvent(cancelEvent);
    _cancelDispatchEvent = true;
  }

  //region WidgetElementPainter

  /// 用来支持[WidgetElementPainter]..
  @implementation
  BoxHitTestResult? _painterHitResult;

  /// [WidgetElementPainter]内的[RenderObject]事件处理
  @implementation
  void _handleWidgetPainterEvent(PointerEvent event) {
    //--
    if (event.isPointerDown) {
      _painterHitResult = BoxHitTestResult();

      @viewCoordinate
      final localPosition = event.localPosition;
      @sceneCoordinate
      final scenePosition =
          canvasDelegate.canvasViewBox.toScenePoint(localPosition);

      canvasDelegate.visitElementPainter((painter) {
        //debugger();
        if (painter is WidgetElementPainter) {
          if (painter.hitRenderBoxTest(_painterHitResult!, scenePosition)) {
            //no op
            assert(() {
              l.d('命中->$scenePosition');
              return true;
            }());
          }
        }
      }, reverse: true);
    }
    if (_painterHitResult != null) {
      for (final HitTestEntry entry in _painterHitResult!.path) {
        try {
          Matrix4? transform = entry.transform;
          if (entry is PainterHitTestEntry) {
            if (entry.operateMatrix != null) {
              if (transform == null) {
                transform = entry.operateMatrix!;
              } else {
                transform = transform * entry.operateMatrix!;
              }
            }
          }
          entry.target.handleEvent(event.transformed(transform), entry);
        } catch (exception, stack) {
          assert(() {
            printError(exception, stack);
            return true;
          }());
        }
      }
    }
    if (event.isPointerFinish) {
      _painterHitResult = null;
    }
  }

//endregion WidgetElementPainter
}

/// [CanvasViewBox] 操作基础组件
abstract class BaseCanvasViewBoxEventComponent
    with
        IHandlePointerEventMixin,
        CanvasComponentMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin {
  final CanvasDelegate canvasDelegate;

  BaseCanvasViewBoxEventComponent(this.canvasDelegate);

  @override
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (!isCanvasComponentEnable) {
      return;
    }
    super.dispatchPointerEvent(dispatch, event);
  }
}

/// 画布平移组件
/// [CanvasTranslateComponent]
/// [CanvasScaleComponent]
class CanvasTranslateComponent extends BaseCanvasViewBoxEventComponent {
  /// 移动阈值, 移动值, 达到此值时, 才会触发移动
  /// [kTouchSlop] 18
  @dp
  double translateThreshold = 3;

  CanvasTranslateComponent(super.canvasDelegate);

  @override
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    super.dispatchPointerEvent(dispatch, event);
    if (isCanvasComponentEnable && !ignoreEventHandle) {
      if (event.isMouseScrollEvent &&
          !isKeyPressed(
              keys: canvasDelegate.canvasStyle.scaleControlKeyboardKeys)) {
        //非控制键按下+鼠标滚轮
        final offset = -event.mouseScrollDelta;
        if (offset != Offset.zero) {
          _translateBy(offset.dx, offset.dy);
        }
      } else if (event.isTouchPointerEvent && canvasDelegate.isDragMode) {
        //空格+单鼠标拖动
        //l.d("dispatchPointerEvent->$event");
        //debugger();
        final offsetList = MultiPointerDetectorMixin.getPointerDeltaList(
            pointerMoveMap, pointerDownMap);
        final offset = offsetList.firstOrNull;
        if (offset != null && offset != Offset.zero) {
          _translateBy(offset.dx, offset.dy);
          resetPointerMap(pointerDownMap, pointerMoveMap);
        }
      } else {
        if (event is PointerPanZoomUpdateEvent) {
          //触控板双指平移
          //l.d("-->$event\n${event.transform}");
          final offset = event.panDelta;
          if (offset != Offset.zero) {
            _translateBy(offset.dx, offset.dy);
          }
          //l.d("-->pan:${event.pan} panDelta:${event.panDelta} scale:${event.scale} rotation:${event.rotation}");
        }
      }
    }
  }

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
/// [CanvasScaleComponent]
/// [CanvasTranslateComponent]
class CanvasScaleComponent extends BaseCanvasViewBoxEventComponent
    with DoubleTapDetectorMixin {
  /// 缩放阈值, 缩放值, 达到此值时, 才会触发缩放
  /// [kScaleSlop]
  /// [kTouchSlop] 18
  @dp
  double scaleThreshold = kScaleSlop;

  /// 双击时, 需要放大的比例
  double doubleScaleValue = 1.5;

  /// 双击时, 需要缩小的比例
  double doubleScaleReverseValue = 0.8;

  CanvasScaleComponent(super.canvasDelegate);

  //--

  double? _startPanScaleX;
  double? _startPanScaleY;

  @override
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    addDoubleTapDetectorPointerEvent(event);
    super.dispatchPointerEvent(dispatch, event);
    if (isCanvasComponentEnable && !ignoreEventHandle) {
      final pivot =
          canvasDelegate.canvasViewBox.toScenePoint(event.localPosition);
      if (event.isMouseScrollEvent &&
          isKeyPressed(
              keys: canvasDelegate.canvasStyle.scaleControlKeyboardKeys)) {
        //控制键按下, 鼠标滚动
        final offset = event.mouseScrollDelta;
        if (offset.dy > 0) {
          //鼠标向下滚动, 缩小
          scaleBy(
            scaleX: doubleScaleReverseValue,
            scaleY: doubleScaleReverseValue,
            pivot: pivot,
          );
        } else {
          //鼠标向上滚动, 放大
          scaleBy(
            scaleX: doubleScaleValue,
            scaleY: doubleScaleValue,
            pivot: pivot,
          );
        }
      } else {
        if (event.isPanZoomStart) {
          _startPanScaleX = canvasDelegate.canvasViewBox.scaleX;
          _startPanScaleY = canvasDelegate.canvasViewBox.scaleY;
        } else if (event.isPanZoomUpdate) {
          if (_startPanScaleX != null && _startPanScaleY != null) {
            scaleTo(
              scaleX: _startPanScaleX! * event.panScale,
              scaleY: _startPanScaleY! * event.panScale,
              pivot: pivot,
            );
          }
        } else if (event.isPanZoomEnd) {
          _startPanScaleX = null;
          _startPanScaleY = null;
        }
      }
    }
  }

  @override
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) {
    //debugger();
    //l.d("onDoubleTapDetectorPointerEvent->$event");
    if (canvasDelegate.canvasElementManager.canvasElementControlManager
        .isTranslateElementStart) {
      return false;
    }
    if (event.isMouseEventKind) {
      /*l.w("event:${event.buttons}");
      debugger();*/
    }
    if (canvasDelegate.isDragMode) {
      //拖拽模式/拖拽按键按下时, 不识别双击缩放操作
      return false;
    }
    if (event.isTouchEventKind ||
        (event.isMouseEventKind && lastDownButtons.isMouseLeft)) {
      final scale = doubleScaleValue;
      final pivot = event.localPosition;
      //debugger();
      scaleBy(
        scaleX: scale,
        scaleY: scale,
        pivot: canvasDelegate.canvasViewBox.toScenePoint(pivot),
        anim: true,
      );
    }
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
