part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///

const rasterizeElement = AnnotationMeta('栅格化元素, 栅格化时, 不应该绘制额外的干扰信息');

/// 画布代理类, 核心类, 整个框架的入口
class CanvasDelegate with Diagnosticable implements TickerProvider {
  /// 栅格化元素
  /// [element] 要栅格化的元素
  /// [extend] 扩展的边距. 默认会在元素的边界上, 扩展1个dp的边距
  static Future<UiImage?> rasterizeElement(
    ElementPainter? element, {
    EdgeInsets? extend,
  }) async {
    if (element == null) {
      return null;
    }
    final bounds = element.paintProperty?.getBounds(true);
    if (bounds == null) {
      return null;
    }
    extend ??= const EdgeInsets.all(1);
    final size = Size(
      bounds.width + extend.horizontal,
      bounds.height + extend.vertical,
    );
    final result = await drawImage(size, (canvas) {
      canvas.drawInRect(size.toRect(), bounds, () {
        element.painting(
          canvas,
          PaintMeta(host: rasterizeElement),
        );
      }, dstPadding: extend);
    });
    final base64 = await result.toBase64();
    debugger();
    return result;
  }

  //region ---入口点---

  /// 上下文, 用来发送通知
  BuildContext? delegateContext;

  /// 绘制的入口点
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    paintCount++;
    canvasPaintManager.paint(context, offset);
  }

  /// 手势输入的入口点
  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    canvasEventManager.handleEvent(event, entry);
  }

  /// 布局完成后的入口点
  @entryPoint
  void layout(Size size) {
    canvasViewBox.updatePaintBounds(size, true);
    canvasPaintManager.onUpdatePaintBounds();
  }

  //endregion ---入口点---

  //region ---get/set---

  /// 获取画布的单位
  IUnit get axisUnit => canvasPaintManager.axisManager.axisUnit;

  set axisUnit(IUnit unit) {
    canvasPaintManager.axisManager.axisUnit = unit;
  }

  //endregion ---get/set---

  //region ---core---

  /// 画布样式
  CanvasStyle canvasStyle = CanvasStyle();

  /// 重绘通知, 监听此通知, 主动触发重绘
  ValueNotifier<int> repaint = ValueNotifier(0);

  /// 视口控制
  late CanvasViewBox canvasViewBox = CanvasViewBox(this);

  /// 绘制管理
  late CanvasPaintManager canvasPaintManager = CanvasPaintManager(this);

  /// 事件管理
  late CanvasEventManager canvasEventManager = CanvasEventManager(this);

  /// 元素管理
  late CanvasElementManager canvasElementManager = CanvasElementManager(this);

  /// 回退栈管理
  late CanvasUndoManager canvasUndoManager = CanvasUndoManager(this);

  /// 画布事件监听
  Set<CanvasListener> canvasListeners = {};

  /// 重绘次数
  int paintCount = 0;

  /// 获取调用刷新的次数
  int get refreshCount => repaint.value;

  //endregion ---core---

  //region ---api---

  /// 刷新画布
  @api
  void refresh() {
    repaint.value++;
  }

  /// 添加画布监听
  @api
  void addCanvasListener(CanvasListener listener) {
    canvasListeners.add(listener);
  }

  /// 移除画布监听
  @api
  void removeCanvasListener(CanvasListener listener) {
    canvasListeners.remove(listener);
  }

  //endregion ---api---

  //region ---事件派发---

  /// 当[CanvasViewBox]视口发生变化时触发
  /// [CanvasViewBox.changeMatrix]
  void dispatchCanvasViewBoxChanged(
      CanvasViewBox canvasViewBox, bool isCompleted) {
    canvasElementManager.canvasElementControlManager.updateControlBounds();
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    CanvasViewBoxChangedNotification(canvasViewBox, isCompleted)
        .dispatch(delegateContext);
    canvasListeners.clone().forEach((element) {
      element.onCanvasViewBoxChangedAction?.call(canvasViewBox, isCompleted);
    });
    refresh();
  }

  /// 选择边界改变时触发
  /// [ElementSelectComponent.updateSelectBounds]
  void dispatchCanvasSelectBoundsChanged(Rect? bounds) {
    canvasListeners.clone().forEach((element) {
      element.onCanvasSelectBoundsChangedAction?.call(bounds);
    });
    refresh();
  }

  /// 元素属性发生改变时触发
  /// [PropertyType.paint]
  /// [PropertyType.state]
  /// [PropertyType.data]
  void dispatchCanvasElementPropertyChanged(
    ElementPainter elementPainter,
    PaintProperty? from,
    PaintProperty? to,
    int propertyType,
  ) {
    /*assert(() {
      l.d('元素属性发生改变:$elementPainter $from->$to :$propertyType');
      return true;
    }());*/
    canvasElementManager.canvasElementControlManager
        .onSelfElementPropertyChanged(elementPainter, propertyType);
    canvasListeners.clone().forEach((element) {
      element.onCanvasElementPropertyChangedAction
          ?.call(elementPainter, from, to, propertyType);
    });
    refresh();
  }

  /// 选择的元素改变后回调
  /// [to] 为null or empty时, 表示取消选择
  void dispatchCanvasElementSelectChanged(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
  ) {
    canvasListeners.clone().forEach((element) {
      element.onCanvasElementSelectChangedAction
          ?.call(selectComponent, from, to);
    });
    refresh();
  }

  /// 元素列表发生改变
  void dispatchCanvasElementListChanged(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    UndoType undoType,
  ) {
    //debugger();
    canvasElementManager.canvasElementControlManager
        .onSelfElementListChanged(from, to, op, undoType);
    canvasListeners.clone().forEach((element) {
      element.onCanvasElementListChangedAction?.call(from, to, op, undoType);
    });
    refresh();
  }

  /// 双击元素时回调
  void dispatchDoubleTapElement(ElementPainter elementPainter) {
    canvasListeners.clone().forEach((element) {
      element.onDoubleTapElementAction?.call(elementPainter);
    });
  }

  /// 回退栈发生改变时回调
  void dispatchCanvasUndoChanged(
      CanvasUndoManager undoManager, UndoType fromType) {
    if (fromType == UndoType.undo) {
      //撤销操作时, 取消选中元素
      canvasElementManager.clearSelectedElement();
    }
    canvasListeners.clone().forEach((element) {
      element.onCanvasUndoChangedAction?.call(undoManager);
    });
  }

  //endregion ---事件派发---

  //region ---Ticker---

  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker =
        Ticker(onTick, debugLabel: 'created by ${describeIdentity(this)}');
    return _ticker!;
  }

  //endregion ---Ticker---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty("刷新次数", repaint.value));
    properties.add(DiagnosticsProperty('delegateContext', delegateContext));
    properties.add(DiagnosticsProperty('canvasStyle', canvasStyle));
    properties.add(DiagnosticsProperty('repaint', repaint));
    properties.add(DiagnosticsProperty('canvasViewBox', canvasViewBox));
    properties
        .add(DiagnosticsProperty('canvasPaintManager', canvasPaintManager));
    properties
        .add(DiagnosticsProperty('canvasEventManager', canvasEventManager));
    properties
        .add(DiagnosticsProperty('canvasElementManager', canvasElementManager));
    properties.add(DiagnosticsProperty<Ticker?>('ticker', _ticker));
  }
}
