part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
/// 坐标轴管理, 负责坐标轴/坐标网格的绘制以及计算
///
/// [CanvasPaintManager]的成员
/// [CanvasPaintManager.axisManager]
///
/// - [updateAxisData] 更新坐标轴数据
/// - [painting] 绘制坐标轴
///
class CanvasAxisManager extends IPainter
    with IPainterEventHandlerMixin, KeyEventClientMixin {
  final CanvasPaintManager paintManager;

  CanvasDelegate get canvasDelegate => paintManager.canvasDelegate;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// x横坐标轴的数据, 绘制的是竖线
  /// - [updateAxisData]
  @output
  List<AxisData> xAxisData = [];

  /// y纵坐标轴的数据, 绘制的是横线
  /// - [updateAxisData]
  @output
  List<AxisData> yAxisData = [];

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

  /// 坐标轴背景画笔
  Paint axisBgPaint = Paint()..style = PaintingStyle.fill;

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

  /// 调用此方法,更新坐标轴数据.
  /// 在[CanvasViewBox]发生变化时, 需要调用此方法更新坐标系数据.
  ///
  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]驱动
  /// [CanvasDelegate.dispatchCanvasUnitChanged]驱动
  ///
  @entryPoint
  void updateAxisData(CanvasViewBox canvasViewBox) {
    xAxisData.clear();
    yAxisData.clear();

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
        xAxisData.add(AxisData(viewValue, index * gap, axisType, index));
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
        xAxisData.add(AxisData(viewValue, index * gap, axisType, index));
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
        yAxisData.add(AxisData(viewValue, index * gap, axisType, index));
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
        yAxisData.add(AxisData(viewValue, index * gap, axisType, index));
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
    if (canvasStyle.showAxis) {
      //坐标轴背景
      final canvasAxisBgColor = canvasStyle.canvasAxisBgColor;
      if (canvasAxisBgColor != null) {
        axisBgPaint.color = canvasAxisBgColor;
        if (xAxisBounds != null) {
          canvas.drawRect(xAxisBounds!, axisBgPaint);
        }
        if (yAxisBounds != null) {
          canvas.drawRect(yAxisBounds!, axisBgPaint);
        }
      }

      // x轴
      canvas.withClipRect(isDebug ? null : xAxisBounds, () {
        paintSelectElementWidthSize(canvas, paintMeta);
        paintXAxis(canvas);
      });

      // y轴
      canvas.withClipRect(isDebug ? null : yAxisBounds, () {
        paintSelectElementHeightSize(canvas, paintMeta);
        paintYAxis(canvas);
      });

      //边界线
      if (canvasStyle.showAxisEdgeLine) {
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
    }

    // 绘制坐标网格
    if (canvasStyle.showGrid) {
      canvas.withClipRect(canvasBounds, () /*画布区域裁剪*/ {
        canvasDelegate.canvasPaintManager.contentManager.withCanvasContent(
          canvas,
          () /*内容区域裁剪*/ {
            for (final axisData in xAxisData) {
              final paint = axisData.axisType.have(IUnit.axisTypePrimary)
                  ? primaryPaint
                  : axisData.axisType.have(IUnit.axisTypeSecondary)
                  ? secondaryPaint
                  : normalPaint;

              canvas.drawLine(
                Offset(axisData.viewValue, paintBounds.top),
                Offset(axisData.viewValue, paintBounds.bottom),
                paint,
              );
            }

            for (final axisData in yAxisData) {
              final paint = axisData.axisType.have(IUnit.axisTypePrimary)
                  ? primaryPaint
                  : axisData.axisType.have(IUnit.axisTypeSecondary)
                  ? secondaryPaint
                  : normalPaint;

              canvas.drawLine(
                Offset(paintBounds.left, axisData.viewValue),
                Offset(paintBounds.right, axisData.viewValue),
                paint,
              );
            }
          },
        );
      });
    }
  }

  /// 在坐标轴中绘制选中元素的宽度色块
  @property
  void paintSelectElementWidthSize(Canvas canvas, PaintMeta paintMeta) {
    final elementManager = paintManager.canvasDelegate.canvasElementManager;
    final canvasElementControlManager =
        elementManager.canvasElementControlManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager
          .elementSelectComponent
          .paintProperty
          ?.let((it) {
            final bounds = it.getBounds(
              canvasElementControlManager.enableResetElementAngle,
            );
            final scale = paintManager.canvasDelegate.canvasViewBox.scaleX;
            @viewCoordinate
            final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

            final left = origin.dx + bounds.left * scale;
            final top = xAxisBounds?.top ?? 0;
            final right = origin.dx + bounds.right * scale;
            final bottom = xAxisBounds?.bottom ?? 0;

            elementBoundsPaint.color = paintManager
                .canvasDelegate
                .canvasStyle
                .canvasAccentColor
                .withOpacity(0.3);
            canvas.drawRect(
              Rect.fromLTRB(left, top, right, bottom),
              elementBoundsPaint,
            );
          });
    }
  }

  /// 在坐标轴中绘制选中元素的高度色块
  @property
  void paintSelectElementHeightSize(Canvas canvas, PaintMeta paintMeta) {
    final elementManager = paintManager.canvasDelegate.canvasElementManager;
    final canvasElementControlManager =
        elementManager.canvasElementControlManager;
    if (elementManager.isSelectedElement) {
      elementManager
          .canvasElementControlManager
          .elementSelectComponent
          .paintProperty
          ?.let((it) {
            final bounds = it.getBounds(
              canvasElementControlManager.enableResetElementAngle,
            );
            final scale = paintManager.canvasDelegate.canvasViewBox.scaleY;
            @viewCoordinate
            final origin = paintManager.canvasDelegate.canvasViewBox.sceneOrigin;

            final left = yAxisBounds?.left ?? 0;
            final top = origin.dy + bounds.top * scale;
            final right = yAxisBounds?.right ?? 0;
            final bottom = origin.dy + bounds.bottom * scale;

            elementBoundsPaint.color = paintManager
                .canvasDelegate
                .canvasStyle
                .canvasAccentColor
                .withOpacity(0.3);
            canvas.drawRect(
              Rect.fromLTRB(left, top, right, bottom),
              elementBoundsPaint,
            );
          });
    }
  }

  /// 绘制x轴刻度文本信息
  @property
  void paintXAxis(Canvas canvas) {
    final canvasStyle = paintManager.canvasDelegate.canvasStyle;
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in xAxisData) {
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
                showSuffix:
                    canvasStyle.showAxisUnitSuffix ||
                    (canvasStyle.showOriginAxisUnitSuffix &&
                        axisData.sceneValue == 0),
              ),
              style: TextStyle(
                color: paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                fontSize:
                    paintManager.canvasDelegate.canvasStyle.axisLabelFontSize,
              ),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(
            canvas,
            Offset(axisData.viewValue + axisLabelOffset, xAxisBounds?.top ?? 0),
          );
      }
    }
  }

  /// 绘制y轴刻度文本信息
  @property
  void paintYAxis(Canvas canvas) {
    final canvasStyle = paintManager.canvasDelegate.canvasStyle;
    final paintBounds = paintManager.canvasDelegate.canvasViewBox.paintBounds;
    for (var axisData in yAxisData) {
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
        canvas.withRotate(
          -90,
          () {
            TextPainter(
                text: TextSpan(
                  text: axisUnit.formatFromDp(
                    axisData.sceneValue,
                    showSuffix:
                        canvasStyle.showAxisUnitSuffix ||
                        (canvasStyle.showOriginAxisUnitSuffix &&
                            axisData.sceneValue == 0),
                  ),
                  style: TextStyle(
                    color:
                        paintManager.canvasDelegate.canvasStyle.axisLabelColor,
                    fontSize: paintManager
                        .canvasDelegate
                        .canvasStyle
                        .axisLabelFontSize,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )
              ..layout()
              ..paint(
                canvas,
                Offset(
                  yAxisBounds?.left ?? 0,
                  axisData.viewValue - axisLabelOffset,
                ),
              );
          },
          pivotX: yAxisBounds?.left ?? 0,
          pivotY: axisData.viewValue - axisLabelOffset,
        );
      }
    }
  }

  //region 参考线

  /// 横向/纵向 参考线集合
  @output
  List<RefLineData> refLineDataList = [];

  @override
  bool isEnablePainterPointerEvent() => canvasStyle.enableRefLine;

  /// 鼠标悬浮的参考线数据
  RefLineData? _hoverRefLineData;

  /// 动态创建/编辑参考线的组件
  RefLineComponent? _refLineComponent;

  @override
  bool interceptPainterPointerEvent(PointerEvent event) {
    if (event.isPointerHover) {
      final localPosition = event.localPosition;
      _hoverRefLineData = findRefLineData(localPosition);
      if (xAxisBounds?.contains(localPosition) == true ||
          _hoverRefLineData?.axis == Axis.horizontal) {
        // 横向参考线
        canvasDelegate.addCursorStyle(
          "cursor_x_axis",
          SystemMouseCursors.resizeRow,
        );
      } else {
        canvasDelegate.removeTagCursorStyle("cursor_x_axis");
      }
      if (yAxisBounds?.contains(localPosition) == true ||
          _hoverRefLineData?.axis == Axis.vertical) {
        // 纵向参考线
        canvasDelegate.addCursorStyle(
          "cursor_y_axis",
          SystemMouseCursors.resizeColumn,
        );
      } else {
        canvasDelegate.removeTagCursorStyle("cursor_y_axis");
      }
    } else if (event.isPointerDown) {
      final localPosition = event.localPosition;
      final downRefLineData = findRefLineData(localPosition);
      if (downRefLineData != null) {
        return true;
      } else {
        if (_refLineComponent != null) {
          _refLineComponent = null;
          canvasDelegate.refresh();
        }
        if (xAxisBounds?.contains(localPosition) == true) {
          return true;
        } else if (yAxisBounds?.contains(localPosition) == true) {
          return true;
        }
      }
    }
    return super.interceptPainterPointerEvent(event);
  }

  @override
  bool handlePainterPointerEvent(@viewCoordinate PointerEvent event) {
    if (event.isPointerDown) {
      //debugger();
      final localPosition = event.localPosition;
      final downRefLineData = findRefLineData(localPosition);
      if (downRefLineData != null) {
        _refLineComponent = RefLineComponent(this, downRefLineData.axis)
          .._refLineData = downRefLineData;
        canvasDelegate.refresh();
      } else {
        if (xAxisBounds?.contains(localPosition) == true) {
          _refLineComponent = RefLineComponent(this, Axis.horizontal);
        } else if (yAxisBounds?.contains(localPosition) == true) {
          _refLineComponent = RefLineComponent(this, Axis.vertical);
        }
      }
      _refLineComponent?.handlePainterPointerEvent(event);
      return _refLineComponent != null;
    } else {
      if (_refLineComponent != null) {
        final handle = _refLineComponent!.handlePainterPointerEvent(event);
        if (event.isPointerFinish) {
          if (isRefLineMoveToAxis(_refLineComponent?._refLineData)) {
            removeRefLine(_refLineComponent?._refLineData);
          }
          //_refLineComponent = null;
        }
        return handle;
      }
    }
    return false;
  }

  @override
  bool interceptKeyEvent(KeyEvent event) {
    return _refLineComponent?.interceptKeyEvent(event) ?? false;
  }

  @override
  bool handleKeyEvent(KeyEvent event) {
    return _refLineComponent?.handleKeyEvent(event) ?? false;
  }

  /// 绘制参考线
  @callPoint
  void paintRefLine(Canvas canvas, PaintMeta paintMeta) {
    if (canvasStyle.showRefLine) {
      final canvasViewBox = paintManager.canvasDelegate.canvasViewBox;
      final paintBounds = canvasViewBox.paintBounds;
      final canvasStyle = this.canvasStyle;
      final linePaint = Paint()..color = canvasStyle.axisRefLineColor;

      for (final lineData in refLineDataList) {
        if (!isRefLineVisibleInCanvasBox(lineData)) {
          continue;
        }
        @sceneCoordinate
        final point = Offset(lineData.sceneValue, lineData.sceneValue);
        @viewCoordinate
        final viewPoint = canvasViewBox.toViewPoint(point);

        final isHighlight = isHighlightRefLine(lineData);
        final isHover = _hoverRefLineData == lineData;

        linePaint.color = isHighlight
            ? canvasStyle.axisRefLineHighlightColor
            : canvasStyle.axisRefLineColor;

        if (lineData.axis == Axis.horizontal) {
          canvas.drawLine(
            Offset(paintBounds.left, viewPoint.dy),
            Offset(paintBounds.right, viewPoint.dy),
            linePaint,
          );

          if (isHighlight || isHover) {
            //绘制参考刻度值
            canvas.withRotate(
              -90,
              () {
                TextPainter(
                    text: TextSpan(
                      text: axisUnit.formatFromDp(
                        lineData.sceneValue,
                        showSuffix: false,
                      ),
                      style: TextStyle(
                        color: linePaint.color,
                        fontSize: paintManager
                            .canvasDelegate
                            .canvasStyle
                            .axisLabelFontSize,
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                  )
                  ..layout()
                  ..paint(
                    canvas,
                    Offset(
                      yAxisBounds?.left ?? 0,
                      viewPoint.y - axisLabelOffset,
                    ),
                  );
              },
              pivotX: yAxisBounds?.left ?? 0,
              pivotY: viewPoint.y - axisLabelOffset,
            );
          }
        } else if (lineData.axis == Axis.vertical) {
          canvas.drawLine(
            Offset(viewPoint.dx, paintBounds.top),
            Offset(viewPoint.dx, paintBounds.bottom),
            linePaint,
          );

          if (isHighlight || isHover) {
            //绘制参考刻度值
            TextPainter(
                text: TextSpan(
                  text: axisUnit.formatFromDp(
                    lineData.sceneValue,
                    showSuffix: false,
                  ),
                  style: TextStyle(
                    color: linePaint.color,
                    fontSize: paintManager
                        .canvasDelegate
                        .canvasStyle
                        .axisLabelFontSize,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )
              ..layout()
              ..paint(
                canvas,
                Offset(viewPoint.x + axisLabelOffset, xAxisBounds?.top ?? 0),
              );
          }
        }
      }
    }
  }

  /// 查找点击命中的参考线
  RefLineData? findRefLineData(@viewCoordinate Offset point) {
    for (final lineData in refLineDataList.reversed) {
      if (isHitRefLineData(lineData, point)) {
        return lineData;
      }
    }
    return null;
  }

  /// 点[point]是否命中[lineData]参考线
  bool isHitRefLineData(RefLineData lineData, @viewCoordinate Offset point) {
    final canvasViewBox = paintManager.canvasDelegate.canvasViewBox;
    @viewCoordinate
    final paintBounds = canvasViewBox.paintBounds;
    final double threshold = 10;
    if (lineData.axis == Axis.horizontal) {
      @viewCoordinate
      final lineDataPoint = toViewPoint(Offset(0, lineData.sceneValue));
      return point.dx >= paintBounds.left &&
          point.dx <= paintBounds.right &&
          (point.y - lineDataPoint.y).abs() <= threshold;
    }
    if (lineData.axis == Axis.vertical) {
      @viewCoordinate
      final lineDataPoint = toViewPoint(Offset(lineData.sceneValue, 0));
      return point.dy >= paintBounds.top &&
          point.dy <= paintBounds.bottom &&
          (point.x - lineDataPoint.x).abs() <= threshold;
    }
    return false;
  }

  /// 判断当前参考线是否移动到坐标轴上了, 此时应该移除参考线
  bool isRefLineMoveToAxis(RefLineData? lineData) {
    if (lineData == null) {
      return false;
    }
    @viewCoordinate
    final lineDataPoint = toViewPoint(
      Offset(lineData.sceneValue, lineData.sceneValue),
    );
    if (lineData.axis == Axis.horizontal) {
      return lineDataPoint.y <= (xAxisBounds?.bottom ?? 0);
    }
    if (lineData.axis == Axis.vertical) {
      return lineDataPoint.x <= (yAxisBounds?.right ?? 0);
    }
    return false;
  }

  /// 当前参考线是否要高亮
  bool isHighlightRefLine(RefLineData lineData) {
    return lineData == _refLineComponent?._refLineData;
  }

  /// 当前参考线是否在画布中可见, 不可见不绘制
  bool isRefLineVisibleInCanvasBox(RefLineData lineData) {
    final canvasViewBox = paintManager.canvasDelegate.canvasViewBox;
    return canvasViewBox.canvasSceneVisibleBounds.isValid &&
        canvasViewBox.isRectVisibleInCanvas(getRefLineSceneRect(lineData));
  }

  /// 场景内的坐标转换成视图坐标
  @viewCoordinate
  Offset toViewPoint(@sceneCoordinate Offset point) {
    return paintManager.canvasDelegate.canvasViewBox.toViewPoint(point);
  }

  /// 视图坐标转换成场景坐标
  @sceneCoordinate
  Offset toScenePoint(@viewCoordinate Offset point) {
    return paintManager.canvasDelegate.canvasViewBox.toScenePoint(point);
  }

  /// 添加一个参考线
  @api
  void addRefLine(RefLineData? data) {
    if (data == null) {
      return;
    }
    if (!refLineDataList.contains(data)) {
      refLineDataList.add(data);
    }
    canvasDelegate.refresh();
  }

  /// 移除一个参考线
  @api
  void removeRefLine(RefLineData? data) {
    if (data == null) {
      return;
    }
    if (data == _refLineComponent?._refLineData) {
      //移除的是正在编辑的参考线
      _refLineComponent = null;
    }
    if (data == _hoverRefLineData) {
      _hoverRefLineData = null;
    }
    if (refLineDataList.contains(data)) {
      refLineDataList.remove(data);
    }
    canvasDelegate.refresh();
  }

  /// 获取参考线在场景内的矩形
  @api
  @sceneCoordinate
  Rect? getRefLineSceneRect(
    RefLineData? lineData, {
    @viewCoordinate double lineWidth = 2,
  }) {
    if (lineData == null) {
      return null;
    }
    final canvasViewBox = paintManager.canvasDelegate.canvasViewBox;
    final paintBounds = canvasViewBox.paintBounds;
    @sceneCoordinate
    final point = Offset(lineData.sceneValue, lineData.sceneValue);
    @viewCoordinate
    final viewPoint = canvasViewBox.toViewPoint(point);
    if (lineData.axis == Axis.horizontal) {
      final viewRect = Rect.fromLTRB(
        paintBounds.left,
        viewPoint.y - lineWidth / 2,
        paintBounds.right,
        viewPoint.y + lineWidth / 2,
      );
      return canvasViewBox.toSceneRect(viewRect);
    } else if (lineData.axis == Axis.vertical) {
      final viewRect = Rect.fromLTRB(
        viewPoint.x - lineWidth / 2,
        paintBounds.top,
        viewPoint.x + lineWidth / 2,
        paintBounds.bottom,
      );
      /*assert(() {
        l.d("$viewRect");
        return true;
      }());*/
      return canvasViewBox.toSceneRect(viewRect);
    }
    return null;
  }

  //endregion 参考线
}

/// 坐标轴数据
final class AxisData {
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
