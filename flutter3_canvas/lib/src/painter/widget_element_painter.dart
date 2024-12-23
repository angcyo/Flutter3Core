part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/23
///
class WidgetElementPainter extends ElementPainter {
  /// 小部件
  Widget? widget;

  Element? _widgetElement;
  RenderObject? _widgetRender;

  WidgetElementPainter({this.widget});

  /// 调用此方法安装[widget]小部件, 并将其和[CanvasRenderObjectElement]建立联系
  /// [RenderObject]需要在`layer tree`上, 才能调用[RenderObject.paint]方法
  ///
  /// [isUpdate]是否是更新[Widget]
  ///
  @api
  void mountWidget(CanvasDelegate canvasDelegate, {bool? isUpdate}) {
    //debugger();
    if (widget == null) {
      unmountWidget(canvasDelegate);
    } else if (widget != null) {
      if (_widgetElement != null && isUpdate != true) {
      } else {
        //debugger();
        unmountWidget(canvasDelegate);
        final element = canvasDelegate.mountWidget(widget!, slot: this);
        _widgetElement = element;
        if (element != null) {
          final render = element.findRenderObject();
          if (render != null) {
            _widgetRender = render;

            final paintProperty = this.paintProperty;
            if (paintProperty == null) {
              render.layout(BoxConstraints(), parentUsesSize: true);

              final size = render.renderSize ?? Size.zero;
              //debugger();
              initPaintProperty(
                  rect: Rect.fromLTWH(0, 0, size.width, size.height));
            } else {
              render.layout(
                  BoxConstraints.expand(
                    width: paintProperty.width,
                    height: paintProperty.height,
                  ),
                  parentUsesSize: false);
            }
          }
        }
      }
    }
  }

  /// 卸载[Widget]小部件
  @api
  void unmountWidget(CanvasDelegate canvasDelegate) {
    final element = _widgetElement;
    if (element != null) {
      canvasDelegate.unmountWidget(element);
    }
    _widgetElement = null;
    _widgetRender = null;
    _renderImageCache = null;
  }

  @override
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    //debugger();
    mountWidget(canvasDelegate, isUpdate: false);
    super.attachToCanvasDelegate(canvasDelegate);
  }

  @override
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    //debugger();
    unmountWidget(canvasDelegate);
    super.detachFromCanvasDelegate(canvasDelegate);
  }

  //--

  @override
  UiImage? get elementOutputImage => _renderImageCache;

  /// 因为绘制[_widgetRender]需要[PaintingContext], 但是栅格化或者截图时, 没有此对象;
  /// 所以这里需要缓存一份[UiImage]
  UiImage? _renderImageCache;

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    super.onPaintingSelf(canvas, paintMeta);
    //debugger();
    _widgetRender?.let((render) {
      final paintContext = paintMeta.paintContext;
      if (paintContext != null) {
        _renderImageCache = render.captureImageSync();
        canvas.withMatrix(
          paintProperty?.operateMatrix,
          () {
            render.paint(paintMeta.paintContext!, Offset.zero);
          },
        );
      } else if (_renderImageCache != null) {
        canvas.withMatrix(
          paintProperty?.operateMatrix,
          () {
            canvas.drawImage(_renderImageCache!, Offset.zero, paint);
          },
        );
      }
    });
  }

  @override
  ElementPainter copyElement(
      {ElementPainter? template,
      ElementGroupPainter? parent,
      bool resetUuid = true,
      Object? fromObj,
      UndoType? fromUndoType}) {
    return super.copyElement(
        template: template ??
            (WidgetElementPainter(widget: widget)
              ..mountWidget(canvasDelegate!)),
        parent: parent,
        resetUuid: resetUuid,
        fromObj: fromObj,
        fromUndoType: fromUndoType);
  }
}
