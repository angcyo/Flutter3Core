part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/23
///
/// 将[Widget]绘制在画布中...
@implementation
class WidgetElementPainter extends ElementPainter {
  /// 小部件
  Widget? widget;

  //--

  Element? _widgetElement;
  RenderObject? _widgetRender;

  //--

  WidgetElementPainter({this.widget});

  /// 调用此方法安装[widget]小部件, 并将其和[CanvasRenderObjectElement]建立联系
  /// [RenderObject]需要在`layer tree`上, 才能调用[RenderObject.paint]方法
  ///
  /// [isUpdate]是否是更新[Widget]
  ///
  /// ```
  /// To set the gesture recognizers at other times, trigger a new build using setState() and provide the new gesture recognizers as constructor arguments to the corresponding RawGestureDetector or GestureDetector object.
  /// ```
  /// [RendererBinding.drawFrame]↓
  /// [PipelineOwner.flushLayout]
  /// [PipelineOwner.flushCompositingBits]
  /// [PipelineOwner.flushPaint]
  ///
  @callPoint
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
          _widgetRender = render;
          if (render != null) {
            final paintProperty = this.paintProperty;
            if (paintProperty == null) {
              render.layout(BoxConstraints(), parentUsesSize: true);
              final renderSize = render.renderSize;
              if (renderSize == null) {
                assert(() {
                  l.w("[WidgetElementPainter][${render.runtimeType}] renderSize == null");
                  return true;
                }());
              }
              final size = renderSize ?? Size.zero;
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
  @callPoint
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

  /// [RenderBox]命中测试[_widgetRender]
  /// [RenderTransform]
  @callPoint
  bool hitRenderBoxTest(
    BoxHitTestResult result,
    @sceneCoordinate Offset point,
  ) {
    //debugger();
    final render = _widgetRender;
    if (render is RenderBox) {
      if (hitTest(point: point, inflate: true)) {
        final hitResult = BoxHitTestResult();
        if (render.hitTest(hitResult,
            position: render.size.center(Offset.zero))) {
          for (final entry in hitResult.path) {
            if (entry.target is RenderBox) {
              result.add(PainterHitTestEntry(
                entry.target as RenderBox,
                point - (paintProperty?.paintBounds.lt ?? Offset.zero),
                paintProperty?.operateMatrix,
              ));
            }
          }
          return true;
        }
      }
    }
    return false;
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
        //_renderImageCache = render.captureImageSync();
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

/// [BoxHitTestEntry]
class PainterHitTestEntry extends BoxHitTestEntry {
  /// [PaintProperty.operateMatrix]
  final Matrix4? operateMatrix;

  PainterHitTestEntry(
    super.target,
    @sceneCoordinate super.localPosition /*命中时, 相对于元素左上角的距离位置*/,
    this.operateMatrix,
  );
}
