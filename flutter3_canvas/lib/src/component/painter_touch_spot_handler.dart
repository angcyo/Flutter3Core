part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// 元素可交互的触点处理类
/// - 所有触点事件分发
/// - 所有触点绘制入口
class PainterTouchSpotHandler extends IPainter {
  /// 所在容器的矩阵
  @configProperty
  Matrix4? parentMatrix;

  /// 触点列表
  @configProperty
  final List<TouchSpot> touchSpotList = [];

  //region core

  /// 绘制入口
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    PaintMeta meta = paintMeta;
    //debugger();
    if (parentMatrix != null) {
      meta = paintMeta.copyWith(
        originMatrix: Matrix4.identity(),
        canvasMatrix: paintMeta.paintMatrix * parentMatrix!,
      );
    }
    meta.withPaintMatrix(canvas, () {
      for (final element in touchSpotList) {
        element.painting(canvas, meta);
      }
    });
  }

  /// 正在触摸的触点
  TouchSpot? _touchSpot;

  /// 手势入口
  @overridePoint
  bool handlePointerEvent(
    @viewCoordinate PointerEvent event,
    @sceneCoordinate Offset position, {
    void Function(MouseCursor? cursor)? onUpdateCursor,
  }) {
    //debugger();
    bool handle = false;
    //l.d("test->$position");
    if (event.isPointerHover) {
      final touchSpot = findTouchSpot(position, filterHandlerEvent: false);
      if (touchSpot != null) {
        final (h, cursor) = touchSpot.handlePointerHover(event, true);
        onUpdateCursor?.call(cursor);
      } else {
        onUpdateCursor?.call(null);
      }
    } else if (event.isPointerDown) {
      final touchSpot = findTouchSpot(position, filterHandlerEvent: true);
      handle = touchSpot != null;
      _touchSpot = touchSpot;
    }
    //--
    if (_touchSpot != null) {
      _touchSpot!.handlePointerEvent(event);
      handle = true;
    }
    //--
    if (event.isPointerFinish) {
      _touchSpot = null;
    }
    return handle;
  }

  //endregion core

  //region api

  /// 使用画布坐标系[position]点, 查找能命中的触点
  @api
  TouchSpot? findTouchSpot(
    @sceneCoordinate Offset position, {
    bool filterHandlerEvent = false,
  }) {
    for (final element in touchSpotList.reversed) {
      if (filterHandlerEvent && !element.isEnablePointerEvent()) {
        continue;
      }
      final location = element.location;
      if (location != null) {
        final bounds = (parentMatrix?.mapRect(location) ?? location);
        if (bounds.contains(position)) {
          return element;
        }
      }
    }
    return null;
  }

  /// 添加一个触点到列表中
  @api
  void addTouchSpot(TouchSpot touchSpot) {
    touchSpotList.add(touchSpot);
  }

  /// 重置所有触点
  @api
  void resetTouchSpot([Iterable<TouchSpot>? elements]) {
    touchSpotList.resetAll(elements);
  }

  /// 取消所有触点的悬停状态
  @api
  void cancelTouchSpotHover(
    @viewCoordinate PointerEvent event, [
    TouchSpot? ignoreTouchSpot,
  ]) {
    for (final element in touchSpotList) {
      if (element == ignoreTouchSpot) {
        continue;
      }
      element.handlePointerHover(event, false);
    }
  }

  //endregion api
}

/// 触点
/// - [PainterTouchSpotHandler]
class TouchSpot extends IPainter
    implements IPainterEventHandler, IPainterHoverHandler {
  /// 触点的位置, 相对坐标系
  /// - 相对于父坐标位置的位置
  @dp
  @configProperty
  @relativeCoordinate
  Rect? location;

  /// 绘制回调
  @configProperty
  void Function(Canvas canvas, PaintMeta paintMeta)? onPainting;

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPainting?.call(canvas, paintMeta);
    });
  }

  @override
  bool isEnablePointerEvent() => true;

  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    return false;
  }

  //--

  /// 出否处于悬停状态
  @property
  bool isHover = false;

  @override
  (bool, MouseCursor?) handlePointerHover(
    @viewCoordinate PointerEvent event,
    bool hover,
  ) {
    isHover = hover;
    return (
      false,
      isHover
          ? isMacOS
                ? SystemMouseCursors.click
                : SystemMouseCursors.move
          : null,
    );
  }
}
