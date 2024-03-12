part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
/// 坐标轴管理, 负责坐标轴/坐标网格的绘制以及计算
class AxisManager extends IPainter {
  /// 绘制坐标轴
  static const int DRAW_AXIS = 0X01;

  /// 绘制坐标网格
  static const int DRAW_GRID = DRAW_AXIS << 1;

  final CanvasPaintManager paintManager;

  /// x横坐标轴的数据
  List<AxisData> xData = [];

  /// y纵坐标轴的数据
  List<AxisData> yData = [];

  /// x横坐标轴的绘制边界
  /// [CanvasPaintManager.onUpdatePaintBounds] 会更新此值
  @dp
  Rect xAxisBounds = Rect.zero;

  /// y纵坐标轴的绘制边界
  /// [CanvasPaintManager.onUpdatePaintBounds] 会更新此值
  @dp
  Rect yAxisBounds = Rect.zero;

  /// x横坐标轴的高度
  @dp
  double xAxisHeight = 20;

  /// y纵坐标轴的宽度
  @dp
  double yAxisWidth = 20;

  /// 绘制label时, 额外需要的偏移量
  @dp
  double axisLabelOffset = 1;

  /// 坐标系的单位
  IUnit axisUnit = IUnit.dp;

  /// 需要绘制的类型, 用来控制坐标轴和网格的绘制
  int drawType = DRAW_AXIS | DRAW_GRID;

  /// 主刻度的画笔
  Paint primaryPaint = Paint()..style = PaintingStyle.stroke;

  /// 次要刻度的画笔
  Paint secondaryPaint = Paint()..style = PaintingStyle.stroke;

  /// 正常刻度的画笔
  Paint normalPaint = Paint()..style = PaintingStyle.stroke;

  /// 选中元素大小提示块绘制的画笔
  Paint elementBoundsPaint = Paint()..style = PaintingStyle.fill;

  AxisManager(this.paintManager);

  /// 调用此方法,更新坐标轴数据
  @entryPoint
  void updateAxisData(CanvasViewBox canvasViewBox) {
    xData.clear();
    yData.clear();

    //debugger();
    if (drawType.have(DRAW_AXIS) || drawType.have(DRAW_GRID)) {
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
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    final canvasBounds = paintManager.canvasDelegate.canvasViewBox.canvasBounds;

    primaryPaint.color =
        paintManager.canvasDelegate.canvasStyle.axisPrimaryColor;
    secondaryPaint.color =
        paintManager.canvasDelegate.canvasStyle.axisSecondaryColor;
    normalPaint.color = paintManager.canvasDelegate.canvasStyle.axisNormalColor;

    primaryPaint.strokeWidth =
        paintManager.canvasDelegate.canvasStyle.axisPrimaryWidth;
    secondaryPaint.strokeWidth =
        paintManager.canvasDelegate.canvasStyle.axisSecondaryWidth;
    normalPaint.strokeWidth =
        paintManager.canvasDelegate.canvasStyle.axisNormalWidth;

    //绘制坐标刻度
    if (drawType.have(DRAW_AXIS)) {
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
        Offset(paintBounds.left, xAxisBounds.bottom),
        Offset(paintBounds.right, xAxisBounds.bottom),
        primaryPaint,
      );
      canvas.drawLine(
        Offset(yAxisBounds.right, paintBounds.top),
        Offset(yAxisBounds.right, paintBounds.bottom),
        primaryPaint,
      );
    }

    // 绘制坐标网格
    if (drawType.have(DRAW_GRID)) {
      canvas.withClipRect(canvasBounds, () {
        for (var axisData in xData) {
          final paint = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
              ? primaryPaint
              : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
                  ? secondaryPaint
                  : normalPaint;

          canvas.drawLine(Offset(axisData.viewValue, paintBounds.top),
              Offset(axisData.viewValue, paintBounds.bottom), paint);
        }

        for (var axisData in yData) {
          final paint = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
              ? primaryPaint
              : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
                  ? secondaryPaint
                  : normalPaint;

          canvas.drawLine(Offset(paintBounds.left, axisData.viewValue),
              Offset(paintBounds.right, axisData.viewValue), paint);
        }
      });
    }
  }

  /// 在坐标轴中绘制选中元素的宽度色块
  void paintSelectElementWidthSize(Canvas canvas, PaintMeta paintMeta) {
    var elementManager = paintManager.canvasDelegate.canvasElementManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager.elementSelectComponent.paintProperty
          ?.let((it) {
        final bounds = it.paintRect;
        final scale = paintManager.canvasDelegate.canvasViewBox.scaleX;
        @viewCoordinate
        final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

        final left = origin.dx + bounds.left * scale;
        final top = xAxisBounds.top;
        final right = origin.dx + bounds.right * scale;
        final bottom = xAxisBounds.bottom;

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
    var elementManager = paintManager.canvasDelegate.canvasElementManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager.elementSelectComponent.paintProperty
          ?.let((it) {
        final bounds = it.paintRect;
        final scale = paintManager.canvasDelegate.canvasViewBox.scaleY;
        @viewCoordinate
        final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

        final left = yAxisBounds.left;
        final top = origin.dy + bounds.top * scale;
        final right = yAxisBounds.right;
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
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in xData) {
      // 绘制坐标轴, 竖线
      final height = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
          ? xAxisHeight
          : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
              ? xAxisHeight * 0.8
              : xAxisHeight * 0.5;
      final bottom = paintBounds.top + xAxisHeight;

      final paint = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
          ? primaryPaint
          : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
              ? secondaryPaint
              : normalPaint;

      canvas.drawLine(
        Offset(axisData.viewValue, bottom - height),
        Offset(axisData.viewValue, bottom),
        paint,
      );

      if (axisData.axisType.have(IUnit.AXIS_TYPE_LABEL)) {
        // 绘制Label
        TextPainter(
            text: TextSpan(
                text: axisUnit.format(axisData.sceneValue),
                style: TextStyle(
                  color: paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                  fontSize:
                      paintManager.canvasDelegate.canvasStyle.axisLabelFontSize,
                )),
            textDirection: TextDirection.ltr)
          ..layout()
          ..paint(canvas,
              Offset(axisData.viewValue + axisLabelOffset, xAxisBounds.top));
      }
    }
  }

  void paintYAxis(Canvas canvas) {
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in yData) {
      // 绘制坐标轴, 横线
      final width = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
          ? yAxisWidth
          : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
              ? yAxisWidth * 0.8
              : yAxisWidth * 0.5;

      final right = paintBounds.left + yAxisWidth;

      final paint = axisData.axisType.have(IUnit.AXIS_TYPE_PRIMARY)
          ? primaryPaint
          : axisData.axisType.have(IUnit.AXIS_TYPE_SECONDARY)
              ? secondaryPaint
              : normalPaint;

      canvas.drawLine(
        Offset(right, axisData.viewValue),
        Offset(right - width, axisData.viewValue),
        paint,
      );

      if (axisData.axisType.have(IUnit.AXIS_TYPE_LABEL)) {
        // 绘制Label, 需要旋转90度
        canvas.withRotate(-90, () {
          TextPainter(
              text: TextSpan(
                  text: axisUnit.format(axisData.sceneValue),
                  style: TextStyle(
                    color:
                        paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                    fontSize: paintManager
                        .canvasDelegate.canvasStyle.axisLabelFontSize,
                  )),
              textDirection: TextDirection.ltr)
            ..layout()
            ..paint(canvas,
                Offset(yAxisBounds.left, axisData.viewValue - axisLabelOffset));
        },
            pivotX: yAxisBounds.left,
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
  /// [AXIS_TYPE_NORMAL]
  /// [AXIS_TYPE_SECONDARY]
  /// [AXIS_TYPE_PRIMARY]
  /// [AXIS_TYPE_LABEL]
  final int axisType;

  /// 当前刻度距离0开始的索引
  final int index;

  AxisData(this.viewValue, this.sceneValue, this.axisType, this.index);
}
