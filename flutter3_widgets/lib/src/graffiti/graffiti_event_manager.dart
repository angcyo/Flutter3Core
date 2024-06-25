part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 事件管理
class GraffitiEventManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final GraffitiDelegate graffitiDelegate;

  GraffitiEventManager(this.graffitiDelegate);

  /// 手势点位处理, 通常是笔/笔刷
  PointEventHandler? pointEventHandler;

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event.isTouchEvent) {
      pointEventHandler?.handleEvent(event);
    }
  }

  //--

  /// 更新手势处理
  @api
  void updatePointEventHandler(PointEventHandler? handler) {
    final old = pointEventHandler;
    pointEventHandler?.detachFromManager(this);
    pointEventHandler = handler;
    pointEventHandler?.attachFromManager(this);

    //dispatch
    graffitiDelegate.dispatchPointEventHandlerChanged(old, handler);
  }
}

/// 手势点位处理
class PointEventHandler {
  GraffitiEventManager? eventManager;

  /// 手势入口点
  @entryPoint
  @overridePoint
  void handleEvent(PointerEvent event) {
    final eventMeta = PointEventMeta(event.localPosition, nowTimestamp());
    if (event.isPointerDown) {
      onStartPointerEvent(eventMeta);
    } else if (event.isPointerMove) {
      onPointerEventMove(eventMeta);
    } else if (event.isPointerFinish) {
      onFinishPointerEvent(eventMeta);
    }
    eventManager?.graffitiDelegate.refresh();
  }

  /// 开始按下
  @overridePoint
  void onStartPointerEvent(PointEventMeta eventMeta) {}

  /// 按下移动
  @overridePoint
  void onPointerEventMove(PointEventMeta eventMeta) {}

  /// 抬起
  @overridePoint
  void onFinishPointerEvent(PointEventMeta eventMeta) {}

  //--

  void attachFromManager(GraffitiEventManager manager) {
    eventManager = manager;
  }

  void detachFromManager(GraffitiEventManager manager) {
    eventManager = null;
  }
}

/// [PointEventHandler]
/// [GraffitiPainter]
abstract class GraffitiPainterHandler<T extends GraffitiPainter>
    extends PointEventHandler {
  T? painter;

  @overridePoint
  T? createPainter();

  @override
  @overridePoint
  void onStartPointerEvent(PointEventMeta eventMeta) {
    painter = createPainter();
    painter?.addPointEventMeta(eventMeta);
    eventManager?.graffitiDelegate.graffitiElementManager
        .addAfterElement(painter);
  }

  @override
  @overridePoint
  void onPointerEventMove(PointEventMeta eventMeta) {
    painter?.addPointEventMeta(eventMeta);
  }

  @override
  @overridePoint
  void onFinishPointerEvent(PointEventMeta eventMeta) {
    eventManager?.graffitiDelegate.graffitiElementManager
        .removeAfterElement(painter);
    eventManager?.graffitiDelegate.graffitiElementManager.addElement(painter);
  }
}

/// 橡皮擦对象
/// [Path]
class GraffitiEraserHandler extends GraffitiPainterHandler {
  @override
  GraffitiPainter? createPainter() => GraffitiEraserPainter();
}

/// 铅笔对象
/// [Path]
class GraffitiPencilHandler extends GraffitiPainterHandler {
  @override
  GraffitiPainter? createPainter() => GraffitiPencilPainter();
}

/// 钢笔对象, 输出的数据是矢量, 粗细一致
/// [Path]
class GraffitiFountainPenHandler extends GraffitiPainterHandler {
  @override
  GraffitiPainter? createPainter() => GraffitiFountainPenPainter();
}

/// 毛笔对象, 输出的数据是图片, 速度越快, 宽度越细
/// [Path]
class GraffitiBrushPenHandler extends GraffitiPainterHandler {
  @override
  GraffitiPainter? createPainter() => GraffitiBrushPenPainter();
}
