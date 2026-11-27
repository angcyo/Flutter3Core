part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/27
///
/// 支持元素自定义的控制点
///
/// - [CanvasElementControlManager.elementOverlayControl] 的成员
class ElementOverlayControl extends BaseControl {
  ElementOverlayControl(CanvasElementControlManager canvasElementControlManager)
    : super(canvasElementControlManager, .overlay) {
    //loadControlPicture('canvas_scale_point.svg');
  }

  /// 枚举客户端列表
  List<PainterOverlayControlMixin>? get _overlayControlPainterList {
    return canvasElementManager
        .getAllSelectedElement()
        ?.whereType<PainterOverlayControlMixin>()
        .toList();
  }

  /// 重写此方法, 更新控制点的位置
  /// - [selectComponentProperty] :null 表示未选中元素
  @override
  void updatePaintControlBounds(PaintProperty? selectComponentProperty) {
    super.updatePaintControlBounds(selectComponentProperty);
    _overlayControlPainterList?.forEach((element) {
      element.updateOverlayControlBounds(selectComponentProperty);
    });
  }

  //MARK: - paint

  /// 绘制入口
  @override
  void paintControl(Canvas canvas, PaintMeta paintMeta) {
    super.paintControl(canvas, paintMeta);
    _overlayControlPainterList?.forEach((element) {
      element.paintOverlayControl(canvas, paintMeta);
    });
    /*canvas.drawRect(
      Rect.fromLTWH(100, 100, 200, 300),
      Paint()..color = Colors.red,
    );*/
  }

  //MARK: - IHandlePointerEventMixin

  /// 手势入口
  @override
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    super.dispatchPointerEvent(dispatch, event);
    _overlayControlPainterList?.reversed.forEach((element) {
      element.dispatchOverlayControlPointerEvent(dispatch, event);
    });
  }

  /// 拦截手势
  @override
  bool interceptPointerEvent(
    PointerDispatchMixin dispatch,
    PointerEvent event,
  ) {
    bool handle = super.interceptPointerEvent(dispatch, event);
    _overlayControlPainterList?.reversed.forEach((element) {
      handle =
          handle ||
          element.interceptOverlayControlPointerEvent(dispatch, event);
    });
    return handle;
  }

  /// 处理手势
  @override
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    bool handle = super.onPointerEvent(dispatch, event);
    _overlayControlPainterList?.reversed.forEach((element) {
      handle = handle || element.onOverlayControlPointerEvent(dispatch, event);
    });
    return handle;
  }
}
