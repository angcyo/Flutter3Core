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

  CanvasEventManager(this.canvasDelegate) {
    addHandleEventClient(canvasTranslateComponent);
  }

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    handleDispatchEvent(event);
  }
}

/// 画布平移组件
class CanvasTranslateComponent extends IHandleEvent
    with CanvasComponentMixin, MultiPointerDetector, HandleEventMixin {
  final CanvasDelegate canvasDelegate;

  /// 移动阈值, 移动值, 达到此值时, 才会触发移动
  @dp
  double translateThreshold = 3; //18

  CanvasTranslateComponent(this.canvasDelegate);

  @override
  bool handlePointerEvent(PointerEvent event) {
    if (event.isPointerMove && pointerCount == 2) {
      //debugger();
      //双指移动
      final offsetList = MultiPointerDetector.getPointerDeltaList(
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
    return super.handlePointerEvent(event);
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
