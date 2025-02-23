part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
/// 坐标轴管理, 负责坐标轴/坐标网格的绘制以及计算
///
/// [CanvasPaintManager]的成员
///
class CanvasAxisManager extends IPainter {
  final CanvasPaintManager paintManager;

  CanvasDelegate get canvasDelegate => paintManager.canvasDelegate;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// x横坐标轴的数据
  List<AxisData> xData = [];

  /// y纵坐标轴的数据
  List<AxisData> yData = [];

  /// x横坐标轴的绘制边界
  /// [CanvasPaintManager.onUpdatePaintBounds] 会更新此值
  @dp
  @viewCoordinate
  @output
  Rect? xAxisBounds;

  /// y纵坐标轴的绘制边界
  /// [CanvasPaintManager.onUpdatePaintBounds] 会更新此值
  @dp
  @viewCoordinate
  @output
  Rect? yAxisBounds;

  /// 获取x/y坐标轴相交的边界
  @dp
  @viewCoordinate
  @output
  Rect? get axisIntersectBounds {
    final xBounds = xAxisBounds;
    final yBounds = yAxisBounds;
    if (xBounds == null || yBounds == null) {
      return null;
    }
    if (xBounds.overlaps(yBounds)) {
      //重叠
      return Rect.fromLTRB(
        xBounds.left,
        yBounds.top,
        xBounds.right,
        yBounds.bottom,
      );
    }
    return Rect.fromLTRB(
      min(xBounds.left, yBounds.left),
      min(xBounds.top, yBounds.top),
      min(xBounds.left, yBounds.right),
      min(xBounds.bottom, yBounds.top),
    );
  }

  //--

  /// 主刻度的画笔
  Paint primaryPaint = Paint()..style = PaintingStyle.stroke;

  /// 次要刻度的画笔
  Paint secondaryPaint = Paint()..style = PaintingStyle.stroke;

  /// 正常刻度的画笔
  Paint normalPaint = Paint()..style = PaintingStyle.stroke;

  /// 选中元素大小提示块绘制的画笔
  Paint elementBoundsPaint = Paint()..style = PaintingStyle.fill;

  //--

  /// x横坐标轴的高度
  @dp
  double get xAxisHeight => canvasStyle.showAxis ? canvasStyle.xAxisHeight : 0;

  /// y纵坐标轴的宽度
  @dp
  double get yAxisWidth => canvasStyle.showAxis ? canvasStyle.yAxisWidth : 0;

  IUnit get axisUnit => canvasStyle.axisUnit;

  int get drawType => canvasStyle.drawType;

  @dp
  double get axisLabelOffset => canvasStyle.axisLabelOffset;

  CanvasAxisManager(this.paintManager);

  /// 调用此方法,更新坐标轴数据
  ///
  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]驱动
  /// [CanvasDelegate.dispatchCanvasUnitChanged]驱动
  ///
  @entryPoint
  void updateAxisData(CanvasViewBox canvasViewBox) {
    xData.clear();
    yData.clear();

    //debugger();
    if (drawType.have(CanvasStyle.sDrawAxis) ||
        drawType.have(CanvasStyle.sDrawGrid)) {
    } else {
      return;
    }

    @viewCoordinate
    final origin = canvasViewBox.sceneOrigin;
    //l.d('origin: $origin');
    final paintBounds = canvasViewBox.paintBounds;
    final scaleX = canvasViewBox.scaleX;
    final scaleY = canvasViewBox.scaleY;

    //剩余的宽度/高度
    double distance = 0;
    //当前的坐标值
    double viewValue = 0;
    //场景中的值
    int index = 0;

    // 计算x轴的数据
    // 1. x轴正方向
    distance = paintBounds.right - origin.dx;
    viewValue = origin.dx;
    while (distance > 0) {
      double gap = axisUnit.getAxisGap(index, scaleX);
      double gapValue = gap * scaleX;
      int axisType = axisUnit.getAxisType(index, scaleX);
      if (viewValue >= yAxisWidth && viewValue <= paintBounds.right) {
        xData.add(AxisData(viewValue, index * gap, axisType, index));
      }
      distance -= gapValue;
      viewValue += gapValue;
      index++;
    }
    // 2. x轴负方向
    distance = origin.dx - paintBounds.left;
    viewValue = origin.dx;
    index = 0;
    while (distance > 0) {
      double gap = axisUnit.getAxisGap(index, scaleX);
      double gapValue = gap * scaleX;
      int axisType = axisUnit.getAxisType(index, scaleX);
      if (viewValue >= yAxisWidth && viewValue <= paintBounds.right) {
        xData.add(AxisData(viewValue, index * gap, axisType, index));
      }
      distance -= gapValue;
      viewValue -= gapValue;
      index--;
    }

    // 计算y轴的数据
    // 1. y轴正方向
    distance = paintBounds.bottom - origin.dy;
    viewValue = origin.dy;
    index = 0;
    while (distance > 0) {
      double gap = axisUnit.getAxisGap(index, scaleY);
      double gapValue = gap * scaleY;
      int axisType = axisUnit.getAxisType(index, scaleY);
      if (viewValue >= xAxisHeight && viewValue <= paintBounds.bottom) {
        yData.add(AxisData(viewValue, index * gap, axisType, index));
      }
      distance -= gapValue;
      viewValue += gapValue;
      index++;
    }
    // 2. y轴负方向
    distance = origin.dy - paintBounds.top;
    viewValue = origin.dy;
    index = 0;
    while (distance > 0) {
      double gap = axisUnit.getAxisGap(index, scaleY);
      double gapValue = gap * scaleY;
      int axisType = axisUnit.getAxisType(index, scaleY);
      if (viewValue >= xAxisHeight && viewValue <= paintBounds.bottom) {
        yData.add(AxisData(viewValue, index * gap, axisType, index));
      }
      distance -= gapValue;
      viewValue -= gapValue;
      index--;
    }
  }

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    final canvasViewBox = paintManager.canvasDelegate.canvasViewBox;
    final canvasStyle = paintManager.canvasDelegate.canvasStyle;

    final paintBounds = canvasViewBox.paintBounds;
    final canvasBounds = canvasViewBox.canvasBounds;

    primaryPaint.color = canvasStyle.axisPrimaryColor;
    secondaryPaint.color = canvasStyle.axisSecondaryColor;
    normalPaint.color = canvasStyle.axisNormalColor;

    primaryPaint.strokeWidth = canvasStyle.axisPrimaryWidth;
    secondaryPaint.strokeWidth = canvasStyle.axisSecondaryWidth;
    normalPaint.strokeWidth = canvasStyle.axisNormalWidth;

    //绘制坐标刻度
    if (drawType.have(CanvasStyle.sDrawAxis)) {
      // x
      canvas.withClipRect(isDebug ? null : xAxisBounds, () {
        paintSelectElementWidthSize(canvas, paintMeta);
        paintXAxis(canvas);
      });

      // y
      canvas.withClipRect(isDebug ? null : yAxisBounds, () {
        paintSelectElementHeightSize(canvas, paintMeta);
        paintYAxis(canvas);
      });

      //边界线
      canvas.drawLine(
        Offset(paintBounds.left, xAxisBounds?.bottom ?? 0),
        Offset(paintBounds.right, xAxisBounds?.bottom ?? 0),
        primaryPaint,
      );
      canvas.drawLine(
        Offset(yAxisBounds?.right ?? 0, paintBounds.top),
        Offset(yAxisBounds?.right ?? 0, paintBounds.bottom),
        primaryPaint,
      );
    }

    // 绘制坐标网格
    if (drawType.have(CanvasStyle.sDrawGrid)) {
      canvas.withClipRect(canvasBounds, () /*画布区域裁剪*/ {
        canvasDelegate.canvasPaintManager.contentManager
            .withCanvasContent(canvas, () /*内容区域裁剪*/ {
          for (final axisData in xData) {
            final paint = axisData.axisType.have(IUnit.axisTypePrimary)
                ? primaryPaint
                : axisData.axisType.have(IUnit.axisTypeSecondary)
                    ? secondaryPaint
                    : normalPaint;

            canvas.drawLine(Offset(axisData.viewValue, paintBounds.top),
                Offset(axisData.viewValue, paintBounds.bottom), paint);
          }

          for (final axisData in yData) {
            final paint = axisData.axisType.have(IUnit.axisTypePrimary)
                ? primaryPaint
                : axisData.axisType.have(IUnit.axisTypeSecondary)
                    ? secondaryPaint
                    : normalPaint;

            canvas.drawLine(Offset(paintBounds.left, axisData.viewValue),
                Offset(paintBounds.right, axisData.viewValue), paint);
          }
        });
      });
    }
  }

  /// 在坐标轴中绘制选中元素的宽度色块
  void paintSelectElementWidthSize(Canvas canvas, PaintMeta paintMeta) {
    final elementManager = paintManager.canvasDelegate.canvasElementManager;
    final canvasElementControlManager =
        elementManager.canvasElementControlManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager.elementSelectComponent.paintProperty
          ?.let((it) {
        final bounds =
            it.getBounds(canvasElementControlManager.enableResetElementAngle);
        final scale = paintManager.canvasDelegate.canvasViewBox.scaleX;
        @viewCoordinate
        final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

        final left = origin.dx + bounds.left * scale;
        final top = xAxisBounds?.top ?? 0;
        final right = origin.dx + bounds.right * scale;
        final bottom = xAxisBounds?.bottom ?? 0;

        elementBoundsPaint.color = paintManager
            .canvasDelegate.canvasStyle.canvasAccentColor
            .withOpacity(0.3);
        canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom), elementBoundsPaint);
      });
    }
  }

  /// 在坐标轴中绘制选中元素的高度色块
  void paintSelectElementHeightSize(Canvas canvas, PaintMeta paintMeta) {
    final elementManager = paintManager.canvasDelegate.canvasElementManager;
    final canvasElementControlManager =
        elementManager.canvasElementControlManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager.elementSelectComponent.paintProperty
          ?.let((it) {
        final bounds =
            it.getBounds(canvasElementControlManager.enableResetElementAngle);
        final scale = paintManager.canvasDelegate.canvasViewBox.scaleY;
        @viewCoordinate
        final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

        final left = yAxisBounds?.left ?? 0;
        final top = origin.dy + bounds.top * scale;
        final right = yAxisBounds?.right ?? 0;
        final bottom = origin.dy + bounds.bottom * scale;

        elementBoundsPaint.color = paintManager
            .canvasDelegate.canvasStyle.canvasAccentColor
            .withOpacity(0.3);
        canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom), elementBoundsPaint);
      });
    }
  }

  /// 绘制x轴刻度
  void paintXAxis(Canvas canvas) {
    final canvasStyle = paintManager.canvasDelegate.canvasStyle;
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in xData) {
      // 绘制坐标轴, 竖线
      final height = axisData.axisType.have(IUnit.axisTypePrimary)
          ? xAxisHeight
          : axisData.axisType.have(IUnit.axisTypeSecondary)
              ? xAxisHeight * 0.8
              : xAxisHeight * 0.5;
      final bottom = paintBounds.top + xAxisHeight;

      final paint = axisData.axisType.have(IUnit.axisTypePrimary)
          ? primaryPaint
          : axisData.axisType.have(IUnit.axisTypeSecondary)
              ? secondaryPaint
              : normalPaint;

      canvas.drawLine(
        Offset(axisData.viewValue, bottom - height),
        Offset(axisData.viewValue, bottom),
        paint,
      );

      if (axisData.axisType.have(IUnit.axisTypeLabel)) {
        // 绘制Label
        TextPainter(
            text: TextSpan(
                text: axisUnit.formatFromDp(
                  axisData.sceneValue,
                  showSuffix: canvasStyle.showAxisUnitSuffix ||
                      (canvasStyle.showOriginAxisUnitSuffix &&
                          axisData.sceneValue == 0),
                ),
                style: TextStyle(
                  color: paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                  fontSize:
                      paintManager.canvasDelegate.canvasStyle.axisLabelFontSize,
                )),
            textDirection: TextDirection.ltr)
          ..layout()
          ..paint(
              canvas,
              Offset(
                  axisData.viewValue + axisLabelOffset, xAxisBounds?.top ?? 0));
      }
    }
  }

  void paintYAxis(Canvas canvas) {
    final canvasStyle = paintManager.canvasDelegate.canvasStyle;
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in yData) {
      // 绘制坐标轴, 横线
      final width = axisData.axisType.have(IUnit.axisTypePrimary)
          ? yAxisWidth
          : axisData.axisType.have(IUnit.axisTypeSecondary)
              ? yAxisWidth * 0.8
              : yAxisWidth * 0.5;

      final right = paintBounds.left + yAxisWidth;

      final paint = axisData.axisType.have(IUnit.axisTypePrimary)
          ? primaryPaint
          : axisData.axisType.have(IUnit.axisTypeSecondary)
              ? secondaryPaint
              : normalPaint;

      canvas.drawLine(
        Offset(right, axisData.viewValue),
        Offset(right - width, axisData.viewValue),
        paint,
      );

      if (axisData.axisType.have(IUnit.axisTypeLabel)) {
        // 绘制Label, 需要旋转90度
        canvas.withRotate(-90, () {
          TextPainter(
              text: TextSpan(
                  text: axisUnit.formatFromDp(
                    axisData.sceneValue,
                    showSuffix: canvasStyle.showAxisUnitSuffix ||
                        (canvasStyle.showOriginAxisUnitSuffix &&
                            axisData.sceneValue == 0),
                  ),
                  style: TextStyle(
                    color:
                        paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                    fontSize: paintManager
                        .canvasDelegate.canvasStyle.axisLabelFontSize,
                  )),
              textDirection: TextDirection.ltr)
            ..layout()
            ..paint(
                canvas,
                Offset(yAxisBounds?.left ?? 0,
                    axisData.viewValue - axisLabelOffset));
        },
            pivotX: yAxisBounds?.left ?? 0,
            pivotY: axisData.viewValue - axisLabelOffset);
      }
    }
  }
}

/// 坐标轴数据
class AxisData {
  /// 视图中, 距离视图左上角的距离值, 用来绘制坐标
  @dp
  @viewCoordinate
  final double viewValue;

  /// 场景中, 距离场景原点的距离值, 用来绘制label
  @dp
  @sceneCoordinate
  final double sceneValue;

  /// 坐标轴类型
  /// [axisTypeNormal]
  /// [axisTypeSecondary]
  /// [axisTypePrimary]
  /// [axisTypeLabel]
  final int axisType;

  /// 当前刻度距离0开始的索引
  final int index;

  AxisData(this.viewValue, this.sceneValue, this.axisType, this.index);
}
