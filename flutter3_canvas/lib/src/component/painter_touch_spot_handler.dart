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
  Matrix4? containerMatrix;

  /// 触点列表
  @configProperty
  final List<TouchSpot> touchSpotList = [];

  //region core

  /// 绘制入口
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    PaintMeta meta = paintMeta;
    //debugger();
    if (containerMatrix != null) {
      meta = paintMeta.copyWith(
        originMatrix: Matrix4.identity(),
        canvasMatrix: paintMeta.paintMatrix * containerMatrix!,
      );
    }
    meta.withPaintMatrix(canvas, () {
      for (final element in touchSpotList) {
        element.painting(canvas, meta);
      }
    });
  }

  /// 手势入口
  @overridePoint
  bool handleEvent(
    @viewCoordinate PointerEvent event,
    @sceneCoordinate Offset position,
  ) {
    //debugger();
    l.d("test->$position");
    return event.isPointerDown;
  }

  //endregion core

  //region api

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
class TouchSpot extends IPainter {
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
}
