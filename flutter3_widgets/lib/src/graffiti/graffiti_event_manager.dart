part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 事件管理
class GraffitiEventManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final GraffitiDelegate graffitiDelegate;

  GraffitiEventManager(this.graffitiDelegate);

  /// 手势按下时的坐标点, 抬起释放
  @viewCoordinate
  Offset? currentTouchPointer;

  /// 手势点位处理, 通常是笔/笔刷
  PointEventHandler? pointEventHandler;

  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event.isTouchEvent) {
      if (event.isPointerFinish) {
        currentTouchPointer = null;
      } else {
        currentTouchPointer = event.localPosition;
      }
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
  @autoInjectMark
  GraffitiEventManager? eventManager;

  /// 判断是否移动了的阈值
  @dp
  double moveThreshold = 3;

  /// 移动节流, 多少毫秒内的手势移动事件忽略
  /// ms
  int moveThrottle = 5;

  /// 最后一次的手势坐标点
  Offset? _lastPosition;

  /// 最后一次手势时间戳
  int _lastTimestamp = 0;

  /// 手势入口点
  @entryPoint
  @overridePoint
  void handleEvent(PointerEvent event) {
    final localPosition = event.localPosition;
    final eventMeta = PointEventMeta(localPosition, nowTimestamp());
    if (event.isPointerDown) {
      onStartPointerEvent(eventMeta);
      _lastPosition = localPosition;
    } else if (event.isPointerMove) {
      if (_lastPosition == null ||
          (localPosition - _lastPosition!).distance > moveThreshold) {
        final timestamp = nowTimestamp();
        if (timestamp - _lastTimestamp > moveThrottle) {
          onPointerEventMove(eventMeta);
          _lastTimestamp = timestamp;
          _lastPosition = localPosition;
        }
      }
    } else if (event.isPointerFinish) {
      onPointerEventMove(eventMeta);
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

  @autoInjectMark
  void attachFromManager(GraffitiEventManager manager) {
    eventManager = manager;
  }

  @autoInjectMark
  void detachFromManager(GraffitiEventManager manager) {
    eventManager = null;
  }
}

/// [PointEventHandler]
/// [GraffitiPainter]
abstract class GraffitiPainterHandler<T extends GraffitiPainter>
    extends PointEventHandler {
  /// 画笔的宽度
  @property
  double painterWidth = 1;

  /// 限制最小宽度
  @configProperty
  double minPainterWidth = 1;

  /// 限制最大宽度
  @configProperty
  double maxPainterWidth = 30;

  /// 是否可以设置笔的大小
  bool canUpdatePainterWidth = true;

  T? painter;

  @overridePoint
  T? createPainter();

  @override
  @overridePoint
  void onStartPointerEvent(PointEventMeta eventMeta) {
    painter = createPainter();
    painter?.paint.strokeWidth = painterWidth;
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
  GraffitiEraserHandler() {
    painterWidth = 10;
  }

  @override
  GraffitiPainter? createPainter() => GraffitiEraserPainter();
}

/// 铅笔对象
/// [Path]
class GraffitiPencilHandler extends GraffitiPainterHandler {
  GraffitiPencilHandler() {
    painterWidth = 10;
  }

  @override
  GraffitiPainter? createPainter() =>
      GraffitiPencilPainter()..paint.strokeWidth = painterWidth;
}

/// 钢笔对象, 输出的数据是矢量, 粗细一致
/// [Path]
class GraffitiFountainPenHandler extends GraffitiPainterHandler {
  GraffitiFountainPenHandler() {
    canUpdatePainterWidth = false;
  }

  @override
  GraffitiPainter? createPainter() => GraffitiFountainPenPainter();
}

/// 毛笔对象, 输出的数据是图片, 速度越快, 宽度越细
/// [Path]
class GraffitiBrushPenHandler extends GraffitiPainterHandler {
  GraffitiBrushPenHandler() {
    painterWidth = 10;
    moveThrottle = 35;
  }

  @override
  GraffitiPainter? createPainter() =>
      GraffitiBrushPenPainter()..updateMaxWidth(painterWidth);
}
