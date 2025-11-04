part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/18
///
/// 画布覆盖组件, 用来拦截所有事件.
/// 通常用于在画布上临时绘制额外的信息
/// 比如钢笔工具/绘制形状等
///
class CanvasOverlayComponent extends IElementPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin {
  /// 回调方法
  /// - [attachToCanvasDelegate]
  @configProperty
  void Function(CanvasDelegate delegate, CanvasOverlayComponent overlay)?
  onOverlayAttachToCanvasDelegate;

  /// 回调方法
  /// - [detachFromCanvasDelegate]
  @configProperty
  void Function(CanvasDelegate delegate, CanvasOverlayComponent overlay)?
  onOverlayDetachFromCanvasDelegate;

  /// 自定义鼠标样式
  @configProperty
  MouseCursor? cursorStyle;

  CanvasOverlayComponent() {
    paintStrokeWidthSuppressCanvasScale = true;
  }

  //region api

  //endregion api

  //region painting

  @override
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    super.attachToCanvasDelegate(canvasDelegate);
    canvasDelegate.addCursorStyle("cursor_overlay", cursorStyle);
    onOverlayAttachToCanvasDelegate?.call(canvasDelegate, this);
  }

  @override
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    super.detachFromCanvasDelegate(canvasDelegate);
    canvasDelegate.removeCursorStyle("cursor_overlay", cursorStyle);
    onOverlayDetachFromCanvasDelegate?.call(canvasDelegate, this);
  }

  /// 绘制
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    super.painting(canvas, paintMeta);
  }

  /// 处理元素事件
  /// [CanvasEventManager.handlePointerEvent]驱动
  @override
  bool handlePainterPointerEvent(@viewCoordinate PointerEvent event) {
    return false;
  }

  /// 处理元素键盘事件
  /// [CanvasEventManager.handleKeyEvent]驱动
  @override
  bool handleKeyEvent(KeyEvent event) {
    return false;
  }

  //endregion painting
}

/// 钢笔工具覆盖层
///
/// 使用 [CanvasDelegate.attachOverlay] 添加覆盖层.
///
/// 通过 [outputSvgPath] 或 [onSvgPathAction] 拿到输出的数据
class CanvasPenOverlayComponent extends CanvasOverlayComponent {
  /// 圈圈的大小/半径
  @configProperty
  double circleRadius = 4;

  /// 完成后的输出回调
  @configProperty
  ValueCallback<String?>? onSvgPathAction;

  /// 输出svg path路径数据
  @output
  String? get outputSvgPath =>
      Point.buildSvgPath(_points, digits: 3, unit: outputUnit);

  @output
  IUnit outputUnit = IUnit.dp;

  CanvasPenOverlayComponent() {
    paintStrokeWidth = 1;
    cursorStyle = SystemMouseCursors.precise;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    if (_path != null) {
      //核心路径
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.red;
      canvas.drawPath(_path!, paint);
    }
    if (!_isEditMode && _hoverPath != null && !_isPointerDown) {
      //悬停路径
      paint
        ..style = PaintingStyle.stroke
        ..color = canvasStyle?.canvasAccentColor ?? paintColor;
      canvas.drawPath(_hoverPath!, paint);
    }
    if (!isNil(_points)) {
      for (final (index, point) in _points!.indexed) {
        if (_isEditMode) {
          final isFill = isEditPoint(point);
          _paintCircle(
            canvas,
            paintMeta,
            point,
            isFill
                ? canvasStyle?.canvasAccentColor ?? paintColor
                : Colors.white,
            isFill ? PaintingStyle.fill : PaintingStyle.stroke,
          );
          _paintControlPoint(canvas, paintMeta, point, true);
        } else {
          final isLast = index == _points!.lastIndex;
          _paintCircle(
            canvas,
            paintMeta,
            point,
            isLast
                ? canvasStyle?.canvasAccentColor ?? paintColor
                : Colors.white,
            isLast ? PaintingStyle.fill : PaintingStyle.stroke,
          );
          //绘制控制线和点
          if (index >= _points!.size() - 2) {
            _paintControlPoint(canvas, paintMeta, point, isLast);
          }
        }
      }
    }
    if (_hoverPoint != null && !_isPointerDown) {
      //绘制悬停鼠标圈圈
      _paintCircle(
        canvas,
        paintMeta,
        _hoverPoint,
        Colors.white,
        PaintingStyle.stroke,
      );
    }
  }

  /// 绘制一个圆圈
  void _paintCircle(
    Canvas canvas,
    PaintMeta paintMeta,
    Point? point,
    Color color,
    PaintingStyle style,
  ) {
    if (point == null) {
      return;
    }
    //先绘制一个填充
    canvas.drawCircle(
      point.offset,
      circleRadius / paintMeta.canvasScale,
      paint
        ..style = PaintingStyle.fill
        ..color = color,
    );
    if (style == PaintingStyle.stroke) {
      //再绘制一个描边
      canvas.drawCircle(
        point.offset,
        circleRadius / paintMeta.canvasScale,
        paint
          ..style = PaintingStyle.stroke
          ..color = canvasStyle?.canvasAccentColor ?? paintColor,
      );
    }
  }

  /// 绘制一个矩形
  void _paintRect(
    Canvas canvas,
    PaintMeta paintMeta,
    Offset? point,
    Color color,
    PaintingStyle style,
  ) {
    if (point == null) {
      return;
    }
    final size = circleRadius / paintMeta.canvasScale * 2;
    final rect = Rect.fromCenter(center: point, width: size, height: size);
    //先绘制一个填充
    canvas.drawRect(
      rect,
      paint
        ..style = PaintingStyle.fill
        ..color = color,
    );
    if (style == PaintingStyle.stroke) {
      //再绘制一个描边
      canvas.drawRect(
        rect,
        paint
          ..style = PaintingStyle.stroke
          ..color = canvasStyle?.canvasAccentColor ?? paintColor,
      );
    }
  }

  /// 绘制贝塞尔曲线的控制点
  /// [isLast] 最后一个点控制2个控制点, 否则只有一个控制点
  void _paintControlPoint(
    Canvas canvas,
    PaintMeta paintMeta,
    Point? point,
    bool isLast,
  ) {
    if (point == null) {
      return;
    }
    if (isLast) {
      final from = point.sc?.offset;
      final to = point.c?.offset;
      if (from == null || to == null) {
        return;
      }
      paint
        ..style = PaintingStyle.stroke
        ..color = canvasStyle?.axisPrimaryColor ?? Colors.grey;
      canvas.drawLine(from, to, paint);
      //--
      if (isEditControlPoint(point.sc)) {
        _paintRect(
          canvas,
          paintMeta,
          from,
          canvasStyle?.canvasAccentColor ?? paintColor,
          PaintingStyle.fill,
        );
      } else {
        _paintRect(canvas, paintMeta, from, Colors.white, PaintingStyle.stroke);
      }
      //--
      if (isEditControlPoint(point.c)) {
        _paintRect(
          canvas,
          paintMeta,
          to,
          canvasStyle?.canvasAccentColor ?? paintColor,
          PaintingStyle.fill,
        );
      } else {
        _paintRect(canvas, paintMeta, to, Colors.white, PaintingStyle.stroke);
      }
    } else {
      final to = point.c?.offset;
      if (to == null) {
        return;
      }
      paint
        ..style = PaintingStyle.stroke
        ..color = canvasStyle?.axisPrimaryColor ?? Colors.grey;
      canvas.drawLine(point.offset, to, paint);
      _paintRect(canvas, paintMeta, to, Colors.white, PaintingStyle.stroke);
    }
  }

  //--

  /// 悬停的点, 也就是鼠标位置
  @sceneCoordinate
  @output
  Point? _hoverPoint;

  /// 所有的关键点信息
  @sceneCoordinate
  @output
  List<Point>? _points;

  /// 所有关键点, 组成的路径
  @output
  Path? _path;

  /// 悬停点和最后一个点组成的悬停路径
  @output
  Path? _hoverPath;

  /// 鼠标是否按下
  @output
  bool _isPointerDown = false;

  @override
  bool handlePainterPointerEvent(PointerEvent event) {
    //l.d("handleEvent->$event");
    final viewBox = canvasViewBox;
    if (viewBox == null) {
      return super.handlePainterPointerEvent(event);
    }
    final point = viewBox.toScenePoint(event.localPosition);

    if (_isEditMode) {
      //二次编辑模式
      if (event.isPointerDown) {
        final find = findPoint(point);
        canvasDelegate?.removeCursorStyle(
          "cursor_pen",
          SystemMouseCursors.click,
        );
        if (find != null) {
          canvasDelegate?.addCursorStyle(
            "cursor_pen",
            SystemMouseCursors.click,
          );
        }
      } else if (event.isPointerMove) {
        updateEditPoint(point);
      } else if (event.isPointerFinish) {
        _parentPoint = null;
        _controlPoint = null;
        canvasDelegate?.removeCursorStyle(
          "cursor_pen",
          SystemMouseCursors.click,
        );
      }
    } else {
      //创作模式
      if (event.isPointerHover) {
        _hoverPoint = Point(point.x, point.y, null);
        _updatePoint(point);
      } else if (event.isPointerDown) {
        _hoverPoint = null;
        _isPointerDown = true;
        _addPoint(point);
        _updatePoint(point);
      } else if (event.isPointerMove) {
        _updatePoint(point);
      } else if (event.isPointerFinish) {
        _isPointerDown = false;
      }
    }
    refresh();
    return true;
  }

  /// 是否是编辑模式
  @output
  bool _isEditMode = false;

  @override
  bool handleKeyEvent(KeyEvent event) {
    //l.d("handleKeyEvent->$event");
    if (event.isKeyDown && event.isEscKey) {
      if (_isEditMode) {
        //如果已经是编辑模式, 则输出数据并上屏
        //l.d(outputSvgPath);
        onSvgPathAction?.call(outputSvgPath);
      } else {
        _hoverPoint = null;
        _isPointerDown = false;
        _isEditMode = true;
        canvasDelegate?.removeCursorStyle(
          "cursor_pen",
          SystemMouseCursors.precise,
        );
        canvasDelegate?.addCursorStyle("cursor_pen", SystemMouseCursors.basic);
      }
    }
    return true;
  }

  //--

  /// 重置
  void reset() {
    _isPointerDown = false;
    _hoverPoint = null;
    _hoverPath = null;
    _points = null;
    _path = null;
    refresh();
  }

  /// 鼠标按下, 添加一个点
  void _addPoint(@sceneCoordinate Offset position) {
    _points ??= [];
    _points!.add(Point(position.x, position.y, null));
    _rebuildPath();
  }

  /// 鼠标移动, 更新最后一个点
  void _updatePoint(@sceneCoordinate Offset position) {
    if (!isNil(_points)) {
      if (_isPointerDown) {
        //鼠标按下的情况下移动, 则是修改控制点
        _points!.last.updateControlPoint(position.x, position.y);
        _rebuildPath();
        _rebuildHoverPath();
      } else {
        //则是移动目标
        _hoverPoint?.x = position.x;
        _hoverPoint?.y = position.y;
        _rebuildHoverPath();
      }
    }
  }

  void _rebuildPath() {
    _path = Point.buildPath([...?_points]);
  }

  void _rebuildHoverPath() {
    _hoverPath = null;
    if (!isNil(_points) && _hoverPoint != null) {
      _hoverPath = Point.buildPath([_points!.last, _hoverPoint!]);
    }
  }

  //--

  /// 找到的点
  Point? _parentPoint;

  /// 找到的控制点, 如果此值有值, 那么[_parentPoint]就是它的父节点
  Point? _controlPoint;

  /// 在编辑模式下, 找到对应的点或控制点
  @api
  Point? findPoint(@sceneCoordinate Offset position) {
    _parentPoint = null;
    _controlPoint = null;
    if (!isNil(_points)) {
      for (final point in _points!) {
        if (isInPoint(point, position)) {
          _parentPoint = point;
          break;
        }
        if (isInPoint(point.c, position)) {
          _parentPoint = point;
          _controlPoint = point.c;
          break;
        }
        if (isInPoint(point.sc, position)) {
          _parentPoint = point;
          _controlPoint = point.sc;
          break;
        }
      }
    }
    return _parentPoint;
  }

  /// 更新[findPoint]找到的点
  @api
  void updateEditPoint(@sceneCoordinate Offset position) {
    if (_parentPoint == null) {
      return;
    }
    if (_controlPoint == null) {
      //更新主点
      _parentPoint?.updatePoint(position.x, position.y);
    } else if (_parentPoint?.c == _controlPoint) {
      _parentPoint?.updateControlPoint(position.x, position.y);
    } else if (_parentPoint?.sc == _controlPoint) {
      _parentPoint?.updateSymmetryControlPoint(position.x, position.y);
    }
    _rebuildPath();
  }

  /// 是否正在编辑指定的点?
  bool isEditPoint(Point? point) {
    return _parentPoint == point && _controlPoint == null;
  }

  /// 是否正在编辑指定的控制点点?
  bool isEditControlPoint(Point? point) {
    return _controlPoint == point;
  }

  @api
  bool isInPoint(Point? point, @sceneCoordinate Offset position) {
    if (point == null) {
      return false;
    }
    final scale = canvasViewBox?.scaleX ?? 1;
    final bounds = Rect.fromCenter(
      center: point.offset,
      width: circleRadius / scale * 2,
      height: circleRadius / scale * 2,
    );
    return bounds.contains(position);
  }
}

/// 用来触发手势事件的覆盖层
class CanvasPointerOverlayComponent extends CanvasOverlayComponent {
  /// 完成后的输出回调
  @configProperty
  ResultValueCallback<bool, PointerEvent>? onPointerAction;

  /// 触发手势事件
  @override
  bool handlePainterPointerEvent(@viewCoordinate PointerEvent event) {
    if (onPointerAction == null) {
      return super.handlePainterPointerEvent(event);
    }
    return onPointerAction!.call(event);
  }
}

/// 用来触发
@implementation
class CanvasTextOverlayComponent extends CanvasOverlayComponent {}
