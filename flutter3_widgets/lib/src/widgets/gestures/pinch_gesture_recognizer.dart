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

  const PinchGestureWidget({
    super.key,
    super.child,
    this.pinchPointer = 4,
    this.pinchThreshold = 100,
    this.onPinchAction,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => PinchGestureBox(
        pinchPointer,
        pinchThreshold,
        onPinchAction,
      );

  @override
  void updateRenderObject(BuildContext context, PinchGestureBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..pinchPointer = pinchPointer
      ..pinchThreshold = pinchThreshold
      ..onPinchAction = onPinchAction;
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

  PinchGestureBox(this.pinchPointer, this.pinchThreshold, this.onPinchAction);

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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}
