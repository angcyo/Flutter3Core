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
  bool handleEvent(
    @viewCoordinate PointerEvent event,
    @sceneCoordinate Offset position,
  ) {
    //debugger();
    bool handle = false;
    //l.d("test->$position");
    if (event.isPointerDown) {
      final touchSpot = findTouchSpot(position);
      handle = touchSpot != null;
      _touchSpot = touchSpot;
    } else {
      if (_touchSpot != null) {
        _touchSpot!.handlePointerEvent(event);
        handle = true;
      }
    }
    if (event.isPointerFinish) {
      _touchSpot = null;
    }
    return handle;
  }

  //endregion core

  //region api

  /// 使用画布坐标系[position]点, 查找能命中的触点
  @api
  TouchSpot? findTouchSpot(@sceneCoordinate Offset position) {
    for (final element in touchSpotList.reversed) {
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

  //endregion api
}

/// 触点
/// - [PainterTouchSpotHandler]
class TouchSpot extends IPainter implements IPainterEventHandler {
  /// 触点的位置
  /// - 相对于父坐标位置的位置
  @dp
  @configProperty
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
  bool handlePointerEvent(PointerEvent event) {
    return false;
  }
}
