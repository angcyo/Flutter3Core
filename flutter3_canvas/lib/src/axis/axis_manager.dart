part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
/// 坐标轴管理, 负责坐标轴/坐标网格的绘制以及计算
class AxisManager extends IPaint {
  /// 绘制坐标轴
  static const int DRAW_AXIS = 0X01;

  /// 绘制坐标网格
  static const int DRAW_GRID = DRAW_AXIS << 1;

  final CanvasPaintManager paintManager;

  /// x横坐标轴的数据
  List<AxisData> xData = [];

  /// y纵坐标轴的数据
  List<AxisData> yData = [];

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

  /// 需要绘制的类型, 用来控制网格的绘制
  int drawType = DRAW_AXIS | DRAW_GRID;

  /// 主轴的画笔
  Paint primaryPaint = Paint()
    ..color = const Color(0xFF888888)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  /// 次要轴的画笔
  Paint secondaryPaint = Paint()
    ..color = const Color(0xFF666666)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  /// 正常轴的画笔
  Paint normalPaint = Paint()
    ..color = const Color(0xFF666666)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  /// 标签的画笔
  Color labelColor = const Color(0xFF666666);

  /// 标签的字体大小
  @dp
  double labelFontSize = 8;

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

    final origin = canvasViewBox.getSceneOrigin();
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
      double gap = axisUnit.getAxisGap(index, scaleX) * scaleX;
      int axisType = axisUnit.getAxisType(index, scaleX);
      xData.add(AxisData(viewValue, index * gap, axisType));
      distance -= gap;
      viewValue += gap;
      index++;
    }
    // 2. x轴负方向
    distance = origin.dx - paintBounds.left;
    viewValue = origin.dx;
    index = 0;
    while (distance > yAxisWidth) {
      double gap = axisUnit.getAxisGap(index, scaleX) * scaleX;
      int axisType = axisUnit.getAxisType(index, scaleX);
      xData.add(AxisData(viewValue, -index * gap, axisType));
      distance -= gap;
      viewValue -= gap;
      index++;
    }

    // 计算y轴的数据
    // 1. y轴正方向
    distance = paintBounds.bottom - origin.dy;
    viewValue = origin.dy;
    index = 0;
    while (distance > 0) {
      double gap = axisUnit.getAxisGap(index, scaleY) * scaleY;
      int axisType = axisUnit.getAxisType(index, scaleY);
      yData.add(AxisData(viewValue, index * gap, axisType));
      distance -= gap;
      viewValue += gap;
      index++;
    }
    // 2. y轴负方向
    distance = origin.dy - paintBounds.top;
    viewValue = origin.dy;
    index = 0;
    while (distance > xAxisHeight) {
      double gap = axisUnit.getAxisGap(index, scaleY) * scaleY;
      int axisType = axisUnit.getAxisType(index, scaleY);
      yData.add(AxisData(viewValue, -index * gap, axisType));
      distance -= gap;
      viewValue -= gap;
      index++;
    }
  }

  @override
  void paint(Canvas canvas, PaintMeta paintMeta) {
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    final canvasBounds = paintManager.canvasDelegate.canvasViewBox.canvasBounds;

    if (drawType.have(DRAW_AXIS)) {
      // x
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
                    color: labelColor,
                    fontSize: labelFontSize,
                  )),
              textDirection: TextDirection.ltr)
            ..layout()
            ..paint(canvas,
                Offset(axisData.viewValue + axisLabelOffset, bottom - height));
        }
      }
      //边界线
      canvas.drawLine(
        Offset(paintBounds.left, paintBounds.top + xAxisHeight),
        Offset(paintBounds.right, paintBounds.top + xAxisHeight),
        primaryPaint,
      );

      // y
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
                      color: labelColor,
                      fontSize: labelFontSize,
                    )),
                textDirection: TextDirection.ltr)
              ..layout()
              ..paint(canvas,
                  Offset(right - width, axisData.viewValue - axisLabelOffset));
          },
              pivotX: right - width,
              pivotY: axisData.viewValue - axisLabelOffset);
        }
      }
      //边界线
      canvas.drawLine(
        Offset(paintBounds.left + yAxisWidth, paintBounds.top),
        Offset(paintBounds.left + yAxisWidth, paintBounds.bottom),
        primaryPaint,
      );
    }

    if (drawType.have(DRAW_GRID)) {
      // 绘制坐标网格

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
}

/// 坐标轴数据
class AxisData {
  /// 视图中, 距离视图左上角的距离值
  @dp
  @viewCoordinate
  final double viewValue;

  /// 场景中, 距离场景原点的距离值
  @dp
  @sceneCoordinate
  final double sceneValue;

  /// 坐标轴类型
  /// [AXIS_TYPE_NORMAL]
  /// [AXIS_TYPE_SECONDARY]
  /// [AXIS_TYPE_PRIMARY]
  /// [AXIS_TYPE_LABEL]
  final int axisType;

  AxisData(this.viewValue, this.sceneValue, this.axisType);
}
