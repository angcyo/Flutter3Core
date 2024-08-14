part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 涂鸦代理类, 核心操作类
class GraffitiDelegate with Diagnosticable implements TickerProvider {
  //region ---core---

  /// 重绘通知, 监听此通知, 主动触发重绘
  /// [GraffitiRenderBox]
  ValueNotifier<int> repaint = ValueNotifier(0);

  /// 绘制管理
  late GraffitiPaintManager graffitiPaintManager = GraffitiPaintManager(this);

  /// 事件管理
  late GraffitiEventManager graffitiEventManager = GraffitiEventManager(this);

  /// 元素管理
  late GraffitiElementManager graffitiElementManager =
      GraffitiElementManager(this);

  /// 回退栈管理
  late GraffitiUndoManager graffitiUndoManager = GraffitiUndoManager(this);

  /// 回调监听
  Set<GraffitiListener> graffitiListeners = {};

  //endregion ---core---

  //region ---入口点---

  /// 上下文, 用来发送通知
  /// [CanvasWidget.createRenderObject]
  /// [CanvasWidget.updateRenderObject]
  BuildContext? delegateContext;

  /// 重绘次数
  int paintCount = 0;

  /// 获取调用刷新的次数
  int get refreshCount => repaint.value;

  /// 绘制的入口点
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    paintCount++;
    graffitiPaintManager.paint(context, offset);
    dispatchGraffitiPaint(this, paintCount);
  }

  /// 手势输入的入口点
  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    graffitiEventManager.handleEvent(event, entry);
  }

  /// 布局完成后的入口点
  @entryPoint
  void layout(Size size) {
    graffitiPaintManager.updatePaintBounds(size, true);
  }

  /// [RenderObject.attach]
  @entryPoint
  void attach() {}

  /// [RenderObject.detach]
  @entryPoint
  void detach() {
    _ticker?.dispose();
    _ticker = null;
  }

  /// 释放所有资源, 主动调用
  @entryPoint
  void release() {
    graffitiElementManager.release();
    graffitiListeners.clear();
  }

  //endregion ---入口点---

  //region ---api---

  /// 请求刷新画布
  @api
  void refresh() {
    repaint.value++;
  }

  /// 添加监听
  @api
  void addGraffitiListener(GraffitiListener listener) {
    graffitiListeners.add(listener);
  }

  /// 移除监听
  @api
  void removeGraffitiListener(GraffitiListener listener) {
    graffitiListeners.remove(listener);
  }

  /// 输出图片
  @output
  UiImage? get outputImage {
    final bounds = graffitiPaintManager.paintBounds;
    final image = drawImageSync(bounds.size, (canvas) {
      canvas.drawInRect(Offset.zero & bounds.size, bounds, () {
        graffitiElementManager.paintElements(
            canvas, const PaintMeta(host: elementOutputHost));
      });
    });
    /*assert(() {
      image.toBase64().get((value, error) {
        final base64 = value;
        debugger();
      });
      return true;
    }());*/
    return image;
  }

  /// 如果全是钢笔数据, 则支持输出适量数据
  /// [GraffitiFountainPenPainter]
  /// 输出svg path数据
  @output
  String? get outputSvgPath {
    StringBuffer pathBuffer = StringBuffer();
    for (final element in graffitiElementManager.elements) {
      //debugger();
      if (element.supportVectorOutput == true) {
        element.outputPathString?.let((it) {
          pathBuffer.write(it.toString());
        });
        /*element.outputPath?.let((it) {
          pathBuffer.write(it.toString());
        });*/
      } else {
        return null;
      }
    }
    return pathBuffer.toString();
  }

  //endregion ---api---

  //region ---事件派发---

  /// each
  void _eachGraffitiListener(void Function(GraffitiListener listener) action) {
    try {
      for (var client in graffitiListeners) {
        try {
          action(client);
        } catch (e) {
          reportError(e);
        }
      }
    } catch (e) {
      reportError(e);
    }
  }

  /// 派发重绘的次数
  void dispatchGraffitiPaint(GraffitiDelegate delegate, int paintCount) {
    _eachGraffitiListener((element) {
      element.onGraffitiPaint?.call(delegate, paintCount);
    });
  }

  /// 回退栈发生改变时回调
  void dispatchGraffitiUndoChanged(
      GraffitiUndoManager undoManager, UndoType fromType) {
    _eachGraffitiListener((element) {
      element.onGraffitiUndoChangedAction?.call(undoManager);
    });
  }

  /// 更新手势处理后的回调
  void dispatchPointEventHandlerChanged(
      PointEventHandler? from, PointEventHandler? to) {
    _eachGraffitiListener((element) {
      element.onPointEventHandlerChanged?.call(from, to);
    });
  }

  /// 元素列表发生改变
  void dispatchGraffitiElementListChanged(
    List<GraffitiPainter> from,
    List<GraffitiPainter> to,
    List<GraffitiPainter> op,
    UndoType undoType,
  ) {
    _eachGraffitiListener((element) {
      element.onGraffitiElementListChangedAction?.call(from, to, op, undoType);
    });
    refresh();
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

//region ---diagnostic---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Ticker?>('ticker', _ticker));
  }

//endregion ---diagnostic---
}

/// 涂鸦配置类
class GraffitiConfig {
  /// 橡皮擦工具
  PointEventHandler eraserHandler = GraffitiEraserHandler();

  /// 钢笔工具
  PointEventHandler fountainPenHandler = GraffitiFountainPenHandler();

  /// 铅笔工具
  PointEventHandler pencilHandler = GraffitiPencilHandler();

  /// 毛笔工具
  PointEventHandler brushPenHandler = GraffitiBrushPenHandler();
}
