part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///

/// [PaintMeta]
const rasterizeElementHost = AnnotationMeta('栅格化元素, 栅格化时, 不应该绘制额外的干扰信息');
const elementOutputHost = AnnotationMeta('元素数据输出, 此时数据应该足够真实');

/// 画布代理类, 核心类, 整个框架的入口
/// [CanvasWidget]
/// [CanvasRenderBox]
class CanvasDelegate with Diagnosticable implements TickerProvider {
  /// 栅格化元素
  /// [element] 要栅格化的元素
  /// [elementBounds] 偷换一下元素的边界, 用来栅格化(线条栅格化的情况)
  /// [extend] 扩展的边距. 默认会在元素的边界上, 扩展1个dp的边距
  /// [rasterizeElementList]
  static Future<UiImage?> rasterizeElement(
    ElementPainter? element, {
    Rect? elementBounds,
    EdgeInsets? extend,
  }) async {
    /*assert(() {
      extend = EdgeInsets.zero;
      return true;
    }());
    debugger();*/
    if (element == null) {
      return null;
    }
    final bounds = elementBounds ?? element.paintProperty?.getBounds(true);
    if (bounds == null) {
      return null;
    }
    //保证1个像素的大小
    final width = max(1, bounds.width);
    final height = max(1, bounds.height);
    final size = Size(
      width + (extend?.horizontal ?? 0),
      height + (extend?.vertical ?? 0),
    );
    final rect =
        Rect.fromLTWH(bounds.left, bounds.top, size.width, size.height);
    final result = await drawImage(size, (canvas) {
      canvas.drawInRect(size.toRect(), rect, () {
        element.painting(
          canvas,
          PaintMeta(host: rasterizeElementHost),
        );
      }, dstPadding: extend);
    });
    /*final base64 = await result.toBase64();
    debugger();*/
    return result;
  }

  ///[rasterizeElement]
  static Future<UiImage?> rasterizeElementList(
    List<ElementPainter>? elements, {
    EdgeInsets? extend,
  }) async {
    if (isNil(elements)) {
      return null;
    }
    final group = ElementGroupPainter();
    group.resetChildren(elements, true);
    return rasterizeElement(group, extend: extend);
  }

  //region ---入口点---

  /// 上下文, 用来发送通知
  /// [CanvasWidget.createRenderObject]
  /// [CanvasWidget.updateRenderObject]
  BuildContext? delegateContext;

  /// 绘制的入口点
  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    paintCount++;
    canvasPaintManager.paint(context, offset);
    dispatchCanvasPaint(this, paintCount);
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

  /// [RenderObject.attach]
  @entryPoint
  void attach() {}

  /// [RenderObject.detach]
  @entryPoint
  void detach() {
    _cancelIdleTimer();
    _ticker?.dispose();
    _ticker = null;
  }

  /// 释放所有资源, 主动调用
  @entryPoint
  void release() {
    canvasElementManager.release();
    canvasListeners.clear();
  }

  //endregion ---入口点---

  //region ---get/set---

  /// 获取画布的单位
  IUnit get axisUnit => canvasPaintManager.axisManager.axisUnit;

  /// 更新画布的单位
  set axisUnit(IUnit unit) {
    final old = axisUnit;
    canvasPaintManager.axisManager.axisUnit = unit;
    dispatchCanvasUnitChanged(old, unit);
  }

  //endregion ---get/set---

  //region ---core---

  /// 画布样式
  CanvasStyle canvasStyle = CanvasStyle();

  /// 重绘通知, 监听此通知, 主动触发重绘
  /// [CanvasRenderBox]
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

  /// 画布回调监听
  Set<CanvasListener> canvasListeners = {};

  /// 重绘次数
  int paintCount = 0;

  /// 获取调用刷新的次数
  int get refreshCount => repaint.value;

  /// 当前是否请求过刷新
  bool isRequestRefresh = false;

  /// 上一次请求刷新的时间, 毫秒
  Duration lastRequestRefreshTime = Duration.zero;

  /// 空闲超时时长, 画布无操作多久之后, 触发空闲回调
  Duration idleTimeout = 10.seconds;

  /// 是否有元素属性发生过改变
  /// [dispatchCanvasElementPropertyChanged]
  @flagProperty
  bool isElementPropertyChanged = false;

  /// 是否有元素数量发生过改变
  /// [dispatchCanvasElementListChanged]
  @flagProperty
  bool isElementChanged = false;

  /// 是否有元素改变标识, 通常同来实现自动保存工程的判断依据
  /// [clearElementChangedFlag]
  bool get hasElementChangedFlag =>
      isElementChanged || isElementPropertyChanged;

  //endregion ---core---

  //region ---api---

  /// 请求刷新画布
  @api
  void refresh() {
    final time = lastRequestRefreshTime;
    isRequestRefresh = true;
    lastRequestRefreshTime = nowDuration();
    repaint.value++;

    _checkIdle(time);
  }

  Timer? _idleTimer;

  /// 空闲检测
  void _checkIdle(Duration lastRefreshTime) {
    _cancelIdleTimer();
    _idleTimer = postDelayCallback(() {
      _idleTimer = null;
      dispatchCanvasIdle(this, lastRefreshTime);
    }, idleTimeout);
  }

  /// 取消空闲检测
  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  /// 清除元素改变标识
  void clearElementChangedFlag() {
    isElementChanged = false;
    isElementPropertyChanged = false;
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

  /// 将一个指定的矩形完整显示在视口中
  /// [rect] 矩形区域, 如果为null, 则显示所有元素边界
  /// [elementPainter] 要显示的元素, 用来获取[rect]
  /// [margin] 矩形区域的外边距, 额外的外边距
  ///
  /// [enableZoomIn] 是否允许视口放大处理, 否则只有平移[rect]到视口中心的效果
  /// [enableZoomOut] 是否允许视口缩小处理, 否则只有平移[rect]到视口中心的效果
  ///
  /// [animate] 是否动画改变
  /// [awaitAnimate] 是否等待动画结束
  @api
  void showRect({
    Rect? rect,
    ElementPainter? elementPainter,
    EdgeInsets? margin = const EdgeInsets.all(kXxh),
    bool enableZoomOut = true,
    bool enableZoomIn = false,
    bool animate = true,
    bool awaitAnimate = false,
  }) {
    rect ??= elementPainter?.paintProperty?.getBounds(canvasElementManager
            .canvasElementControlManager.enableResetElementAngle) ??
        canvasElementManager.allElementsBounds;
    if (rect == null) {
      return;
    }
    if (!canvasViewBox.isCanvasBoxInitialize) {
      //画布还没有初始化完成
      postCallback(() {
        showRect(
          rect: rect,
          elementPainter: elementPainter,
          margin: margin,
          enableZoomOut: enableZoomOut,
          enableZoomIn: enableZoomIn,
          animate: animate,
          awaitAnimate: awaitAnimate,
        );
      });
      return;
    }
    //debugger();
    final translateMatrix = Matrix4.identity();
    //移动到元素中心
    final center = rect.center;
    final canvasBounds = canvasViewBox.canvasBounds;
    final canvasVisibleBounds = canvasViewBox.canvasVisibleBounds;
    var canvasVisibleWidth = canvasVisibleBounds.width;
    var canvasVisibleHeight = canvasVisibleBounds.height;
    final canvasCenter =
        Offset(canvasBounds.width / 2, canvasBounds.height / 2);
    final offset = canvasCenter - center;
    translateMatrix.translate(offset.dx, offset.dy);

    //在中心点开始缩放
    double sx = canvasVisibleWidth / rect.width;
    double sy = canvasVisibleHeight / rect.height;

    if (margin != null) {
      rect = rect.inflateValue(EdgeInsets.only(
        left: margin.left / sx,
        top: margin.top / sy,
        right: margin.right / sx,
        bottom: margin.bottom / sy,
      ));
      sx = canvasBounds.width / rect.width;
      sy = canvasBounds.height / rect.height;
    }

    double? scale;
    //debugger();
    if (enableZoomOut &&
        (rect.width > canvasVisibleWidth ||
            rect.height > canvasVisibleHeight)) {
      //元素比画布大, 此时画布需要缩小
      scale = min(sx, sy);
    } else if (enableZoomIn &&
        (rect.width < canvasVisibleWidth ||
            rect.height < canvasVisibleHeight)) {
      //元素比画布小, 此时画布需要放大
      scale = max(sx, sy);
    }

    final scaleMatrix = createScaleMatrix(
        sx: scale ?? canvasViewBox.scaleX,
        sy: scale ?? canvasViewBox.scaleY,
        anchor: center);
    canvasViewBox.changeMatrix(
      translateMatrix * scaleMatrix,
      animate: animate,
      awaitAnimate: awaitAnimate,
    );
  }

  //endregion ---api---

  //region ---事件派发---

  /// each
  void _eachCanvasListener(void Function(CanvasListener listener) action) {
    try {
      for (var client in canvasListeners) {
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

  /// 派发画布重绘的次数
  void dispatchCanvasPaint(CanvasDelegate delegate, int paintCount) {
    _eachCanvasListener((element) {
      element.onCanvasPaint?.call(delegate, paintCount);
    });
  }

  /// 派发画布空闲时的回调, 当没有请求[refresh]方法时触发
  void dispatchCanvasIdle(CanvasDelegate delegate, Duration lastRefreshTime) {
    _eachCanvasListener((element) {
      element.onCanvasIdle?.call(delegate, lastRefreshTime);
    });
  }

  /// 当[CanvasViewBox]视口发生变化时触发
  /// [CanvasViewBox.changeMatrix]
  void dispatchCanvasViewBoxChanged(
    CanvasViewBox canvasViewBox,
    bool isInitialize,
    bool isCompleted,
  ) {
    canvasElementManager.canvasElementControlManager.updateControlBounds();
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    CanvasViewBoxChangedNotification(canvasViewBox, isCompleted)
        .dispatch(delegateContext);
    _eachCanvasListener((element) {
      element.onCanvasViewBoxChangedAction?.call(
        canvasViewBox,
        isInitialize,
        isCompleted,
      );
    });
    refresh();
  }

  /// 当[AxisManager.axisUnit]坐标系的单位发生变化时触发
  void dispatchCanvasUnitChanged(IUnit from, IUnit to) {
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    _eachCanvasListener((element) {
      element.onCanvasUnitChangedAction?.call(from, to);
    });
    refresh();
  }

  /// 选择边界改变时触发
  /// [ElementSelectComponent.updateSelectBounds]
  void dispatchCanvasSelectBoundsChanged(Rect? bounds) {
    _eachCanvasListener((element) {
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
    dynamic from,
    dynamic to,
    PropertyType propertyType,
  ) {
    isElementPropertyChanged = true;
    /*assert(() {
      l.d('元素属性发生改变:$elementPainter $from->$to :$propertyType');
      return true;
    }());*/
    canvasElementManager.canvasElementControlManager
        .onSelfElementPropertyChanged(elementPainter, propertyType);
    _eachCanvasListener((element) {
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
    _eachCanvasListener((element) {
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
    isElementChanged = true;
    canvasElementManager.canvasElementControlManager
        .onSelfElementListChanged(from, to, op, undoType);
    _eachCanvasListener((element) {
      element.onCanvasElementListChangedAction?.call(from, to, op, undoType);
    });
    refresh();
  }

  /// 双击元素时回调
  void dispatchDoubleTapElement(ElementPainter elementPainter) {
    _eachCanvasListener((element) {
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
    _eachCanvasListener((element) {
      element.onCanvasUndoChangedAction?.call(undoManager);
    });
  }

  /// 元素组合变化回调
  /// [group] 产生的组合元素
  /// [elements] 组合的子元素列表
  void dispatchCanvasGroupChanged(
      ElementGroupPainter group, List<ElementPainter> elements) {
    _eachCanvasListener((element) {
      element.onCanvasGroupChangedAction?.call(group, elements);
    });
  }

  /// 拆组变化回调
  void dispatchCanvasUngroupChanged(ElementGroupPainter group) {
    _eachCanvasListener((element) {
      element.onCanvasUngroupChangedAction?.call(group);
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

  //region ---diagnostic---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(IntProperty("请求刷新次数", refreshCount));
    properties.add(IntProperty("重绘次数", paintCount));
    properties.add(DiagnosticsProperty('代理上下文', delegateContext));
    properties.add(DiagnosticsProperty('画布样式', canvasStyle));
    properties.add(canvasViewBox.toDiagnosticsNode(
      name: '视口控制',
      style: DiagnosticsTreeStyle.sparse,
    ));
    properties.add(DiagnosticsProperty<Ticker?>('ticker', _ticker));

    properties.add(DiagnosticsProperty<bool>(
        "重置旋转角度",
        canvasElementManager
            .canvasElementControlManager.enableResetElementAngle));
    properties.add(DiagnosticsProperty<bool>("激活控制交互",
        canvasElementManager.canvasElementControlManager.enableElementControl));
    properties.add(DiagnosticsProperty<bool>(
        "激活点击元素外取消选择",
        canvasElementManager
            .canvasElementControlManager.enableOutsideCancelSelectElement));

    properties.add(canvasPaintManager.toDiagnosticsNode(
      name: '画布管理',
      style: DiagnosticsTreeStyle.sparse,
    ));
    properties.add(
        DiagnosticsProperty<CanvasEventManager>('手势管理', canvasEventManager));
    properties.add(canvasElementManager.toDiagnosticsNode(
      name: '元素管理',
      style: DiagnosticsTreeStyle.sparse,
    ));
  }

//endregion ---diagnostic---
}
