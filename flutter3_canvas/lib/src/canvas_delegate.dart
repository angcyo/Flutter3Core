part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 画布代理类, 核心类, 整个框架的入口
class CanvasDelegate with Diagnosticable implements TickerProvider {
  //region ---入口点---

  /// 上下文, 用来发送通知
  BuildContext? delegateContext;

  /// 绘制的入口点
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
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

  /// 画布监听
  Set<CanvasListener> canvasListeners = {};

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
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    refresh();
    CanvasViewBoxChangedNotification(canvasViewBox, isCompleted)
        .dispatch(delegateContext);
    canvasListeners.clone().forEach((element) {
      element.onCanvasViewBoxChangedAction?.call(canvasViewBox, isCompleted);
    });
  }

  /// 选择边界改变时触发
  /// [ElementSelectComponent.updateSelectBounds]
  void dispatchCanvasSelectBoundsChangedAction(Rect? bounds) {
    canvasListeners.clone().forEach((element) {
      element.onCanvasSelectBoundsChangedAction?.call(bounds);
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

/*abstract class ICanvasComponent {
  void onCanvasViewBoxChanged(CanvasViewBox canvasViewBox);
}*/
