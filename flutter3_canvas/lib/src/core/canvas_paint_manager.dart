part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 绘制管理, 所有绘制相关的操作, 都在这里, 绘制的入口
class CanvasPaintManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  /// 栅格化元素
  /// [element] 要栅格化的元素
  /// [elementBounds] 偷换一下元素的边界, 用来栅格化(线条栅格化的情况)
  /// [extend] 扩展的边距. 默认会在元素的边界上, 扩展1个dp的边距
  /// [rasterizeElementList]
  static Future<UiImage?> rasterizeElement(
    ElementPainter? element, {
    Rect? elementBounds,
    EdgeInsets? extend,
  }) async {
    /*assert(() {
      extend = EdgeInsets.zero;
      return true;
    }());
    debugger();*/
    if (element == null) {
      return null;
    }
    final bounds = elementBounds ?? element.paintProperty?.getBounds(true);
    if (bounds == null) {
      return null;
    }
    //保证1个像素的大小
    final width = max(1, bounds.width);
    final height = max(1, bounds.height);
    final size = Size(
      width + (extend?.horizontal ?? 0),
      height + (extend?.vertical ?? 0),
    );
    final rect =
        Rect.fromLTWH(bounds.left, bounds.top, size.width, size.height);
    final result = await drawImage(size, (canvas) {
      canvas.drawInRect(size.toRect(), rect, () {
        element.painting(
          canvas,
          const PaintMeta(host: rasterizeElementHost),
        );
      }, dstPadding: extend);
    });
    /*final base64 = await result.toBase64();
    debugger();*/
    return result;
  }

  ///[rasterizeElement]
  static Future<UiImage?> rasterizeElementList(
    List<ElementPainter>? elements, {
    Rect? elementBounds,
    EdgeInsets? extend,
  }) async {
    if (isNil(elements)) {
      return null;
    }
    final group = ElementGroupPainter();
    group.resetChildren(elements, true);
    return rasterizeElement(
      group,
      elementBounds: elementBounds,
      extend: extend,
    );
  }

  final CanvasDelegate canvasDelegate;

  /// 坐标系管理
  late CanvasAxisManager axisManager = CanvasAxisManager(this);

  /// 画布内容管理, 可见背景, 背景颜色等
  late CanvasContentManager contentManager = CanvasContentManager(this);

  /// 监视信息, 比如缩放比例, fps帧率等
  late CanvasMonitorPainter monitorPainter =
      CanvasMonitorPainter(canvasDelegate);

  CanvasPaintManager(this.canvasDelegate);

  /// 绘制边界大小更新后触发, 用来定位坐标系的绘制位置
  /// [CanvasDelegate.layout]
  @entryPoint
  void onUpdatePaintBounds() {
    final paintBounds = canvasDelegate.canvasViewBox.paintBounds;
    final xAxisLeft = paintBounds.left + axisManager.yAxisWidth;
    final yAxisTop = paintBounds.top + axisManager.xAxisHeight;
    axisManager.xAxisBounds = Rect.fromLTRB(xAxisLeft, paintBounds.top,
        paintBounds.right, paintBounds.top + axisManager.xAxisHeight);
    axisManager.yAxisBounds = Rect.fromLTRB(paintBounds.left, yAxisTop,
        paintBounds.left + axisManager.yAxisWidth, paintBounds.bottom);
  }

  /// [canvas] 最原始的canvas, 未经过加工处理
  /// 由[CanvasDelegate.paint]驱动
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.withOffset(offset, () {
      //开始绘制流程
      if (isDebug) {
        /*canvas.drawRect(canvasDelegate.canvasViewBox.canvasBounds,
            Paint()..color = Colors.blue);*/
      }
      final viewBox = canvasDelegate.canvasViewBox;
      final paintMeta = PaintMeta(
        host: canvasDelegate,
        originMatrix: viewBox.originMatrix,
        canvasMatrix: viewBox.canvasMatrix,
      );

      //1: 绘制背景画布内容
      contentManager.painting(canvas, paintMeta);
      //2: 绘制坐标系
      axisManager.painting(canvas, paintMeta);
      //3: 绘制元素/以及控制点
      canvasDelegate.canvasElementManager.paintElements(canvas, paintMeta);
      //4: 绘制监视信息
      monitorPainter.painting(canvas, paintMeta);
    });
    /*canvas.drawRect(canvasDelegate.canvasViewBox.canvasBounds + offset,
        Paint()..color = Colors.blue);
    TextPainter(
        text: TextSpan(
            text: '${canvasDelegate.repaint.value}',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            )),
        textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, offset);*/
  }

  @override
  String toStringShort() => '画布大小:${canvasDelegate.canvasViewBox.paintBounds} '
      '可视区域:${canvasDelegate.canvasViewBox.canvasVisibleBounds} ';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('坐标系单位', axisManager.axisUnit));
    properties.add(
        DiagnosticsProperty('画布大小', canvasDelegate.canvasViewBox.paintBounds));
    properties.add(DiagnosticsProperty(
        '可视区域', canvasDelegate.canvasViewBox.canvasVisibleBounds));
  }
}
