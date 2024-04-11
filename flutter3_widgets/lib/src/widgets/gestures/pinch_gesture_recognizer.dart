part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/19
///
/// 多指捏合手势识别

class PinchGestureWidget extends SingleChildRenderObjectWidget {
  /// 捏合手势的指针数量
  final int pinchPointer;

  /// 捏合手势触发的阈值
  @dp
  final int pinchThreshold;

  /// 捏合手势触发的回调
  final ui.VoidCallback? onPinchAction;

  /// 开启多指长按检测
  final Duration? multiLongPressDuration;

  /// 多指长按触发的回调
  final ui.VoidCallback? onMultiLongPressDurationAction;

  const PinchGestureWidget({
    super.key,
    super.child,
    this.pinchPointer = 4,
    this.pinchThreshold = 100,
    this.onPinchAction,
    this.multiLongPressDuration,
    this.onMultiLongPressDurationAction,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => PinchGestureBox(
        pinchPointer,
        pinchThreshold,
        onPinchAction,
        onMultiLongPressDurationAction,
      )..multiLongPressDuration = multiLongPressDuration;

  @override
  void updateRenderObject(BuildContext context, PinchGestureBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..pinchPointer = pinchPointer
      ..pinchThreshold = pinchThreshold
      ..onPinchAction = onPinchAction
      ..multiLongPressDuration = multiLongPressDuration
      ..onMultiLongPressDurationAction = onMultiLongPressDurationAction;
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty("pinchPointer", pinchPointer));
    properties.add(DiagnosticsProperty("pinchThreshold", pinchThreshold));
  }
}

class PinchGestureBox extends RenderProxyBox
    with MultiPointerDetectorMixin, GestureHitInterceptBoxTranslucentMixin {
  /// 捏合手势的指针数量
  int pinchPointer;

  /// 捏合手势触发的阈值
  @dp
  int pinchThreshold;

  /// 捏合手势触发的回调
  ui.VoidCallback? onPinchAction;

  /// 多指长按触发的回调
  ui.VoidCallback? onMultiLongPressDurationAction;

  PinchGestureBox(
    this.pinchPointer,
    this.pinchThreshold,
    this.onPinchAction,
    this.onMultiLongPressDurationAction,
  );

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    addMultiPointerDetectorPointerEvent(event);
  }

  @override
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
    if (isHandledMultiPointerDetectorEvent) {
      return true;
    }

    if (pointerCount == pinchPointer) {
      //debugger();
      if (event is PointerMoveEvent) {
        Rect downRect =
            MultiPointerDetectorMixin.getPointerBounds(pointerDownMap);
        Rect moveRect =
            MultiPointerDetectorMixin.getPointerBounds(pointerMoveMap);

        final dWidth = downRect.width - moveRect.width;
        final dHeight = downRect.height - moveRect.height;

        if (dWidth >= pinchThreshold || dHeight >= pinchThreshold) {
          //debugger();
          //捏合
          onPinchAction?.call();
          return true;
        }
      }
    }
    return super.handleMultiPointerDetectorPointerEvent(event);
  }

  @override
  void onSelfMultiLongPress() {
    onMultiLongPressDurationAction?.call();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}
