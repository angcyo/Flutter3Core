part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 画布代理类, 核心类, 整个框架的入口
/// [CanvasWidget]
/// [CanvasRenderBox]
class CanvasDelegate with Diagnosticable implements TickerProvider {
  /// 设置新建画布默认的名称前缀
  @api
  static void setCanvasStateDefName(String? defName) {
    CanvasStateData.customCanvasDefNamePrefix =
        defName ?? CanvasStateData.canvasDefNamePrefix;
  }

  @api
  static void setCanvasStateDefNameIfNeed(String? defName) {
    CanvasStateData.customCanvasDefNamePrefix ??=
        defName ?? CanvasStateData.canvasDefNamePrefix;
  }

  /// ```
  /// When an inherited widget changes, for example if the value of Theme.of() changes,
  /// its dependent widgets are rebuilt.
  /// If the dependent widget's reference to the inherited widget is in a constructor or an initState() method,
  /// then the rebuilt dependent widget will not reflect the changes in the inherited widget.
  /// ```
  @api
  static void postSetCanvasStateDefName(String? Function() getName) {
    scheduleMicrotask(() {
      setCanvasStateDefName(getName());
    });
    /*debugger();
    postFrameCallbackIfNeed((_) {
      debugger();
      setCanvasStateDefName(getName());
    });*/

    /*postDelayCallback(() {
      debugger();
      postFrameCallbackIfNeed((_) {
        debugger();
        setCanvasStateDefName(getName());
      });
    }, 5.seconds);*/
  }

  //region ---入口点---

  /// 上下文, 用来发送通知
  /// [CanvasWidget.createRenderObject]
  /// [CanvasWidget.updateRenderObject]
  /// [CanvasWidget]
  @CallFrom("CanvasWidget.createRenderObject/CanvasWidget.updateRenderObject")
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
  void handleEvent(@viewCoordinate PointerEvent event, BoxHitTestEntry entry) {
    canvasEventManager.handleEvent(event);
  }

  /// 布局的大小
  /// [layout]
  Size? _layoutSize;

  /// 布局完成后的入口点
  @entryPoint
  void layout(Size size) {
    _layoutSize = size;
    canvasViewBox.updatePaintBounds(size, true);
    canvasPaintManager.onUpdatePaintBounds();
  }

  /// [RenderObject.attach]
  @entryPoint
  void attach() {
    //no op
  }

  /// [RenderObject.detach]
  @entryPoint
  void detach() {
    _cancelIdleTimer();
    _ticker?.dispose();
    _ticker = null;
  }

  /// 释放所有资源, 主动调用
  /// 在[Element.unmount]中会被调用
  /// 可以使用[ValueKey]添加[Widget]更新判断, 防止[Element.unmount].
  @entryPoint
  void dispose() {
    //debugger();
    canvasElementManager.release();
    canvasUndoManager.dispose();
    canvasListeners.clear();
    dataMap.clear();
  }

  /// 安装一个[Widget]得到对应的[RenderObject]
  @callPoint
  Element? mountWidget(
    Widget widget, {
    Object? slot,
  }) {
    final element = delegateContext;
    if (element is CanvasRenderObjectElement) {
      /*RenderObject? renderObject;
      element.owner?.lockState(() {
        final Element newChild = widget.createElement();
        newChild.mount(element, null);
        renderObject = newChild.findRenderObject();
        debugger();
      });
      debugger();
      return renderObject;*/
      return element.mountWidget(widget, slot: slot);
    } else {
      //debugger();
      assert(() {
        if (element == null) {
          l.w("不支持的操作->delegateContext is not mount!");
        } else {
          l.w("不支持的操作->delegateContext is not CanvasRenderObjectElement!");
        }
        return true;
      }());
    }
    return null;
  }

  /// 卸载一个[Element]
  @callPoint
  void unmountWidget(Element element) {
    final delegateElement = delegateContext;
    if (delegateElement is CanvasRenderObjectElement) {
      delegateElement.unmountWidget(element);
    } else {
      assert(() {
        l.w("不支持的操作->delegateElement is not CanvasRenderObjectElement");
        return true;
      }());
    }
  }

  //endregion ---入口点---

  //region ---mouse/key---

  /// 当前光标的样式, 直接赋值给[MouseTrackerAnnotation.cursor], 就会生效, 不需要额外的处理
  MouseCursor? get currentCursorStyle => _currentCursorStyleList.lastOrNull;

  /// 请求的光标样式
  final List<MouseCursor> _currentCursorStyleList = [];

  /// 添加一个鼠标样式
  @api
  void addCursorStyle(MouseCursor cursor) {
    final last = _currentCursorStyleList.lastOrNull;
    if (last != cursor) {
      _currentCursorStyleList.add(cursor);
    }
  }

  /// 移除一个鼠标样式
  @api
  void removeCursorStyle(MouseCursor cursor) {
    _currentCursorStyleList.removeWhere((e) => e == cursor);
  }

  //endregion ---mouse/key---

  //region ---get/set---

  /// 获取画布的单位
  IUnit get axisUnit => canvasPaintManager.axisManager.axisUnit;

  /// 更新画布的单位
  set axisUnit(IUnit unit) {
    final old = axisUnit;
    canvasStyle.axisUnit = unit;
    dispatchCanvasUnitChanged(old, unit);
  }

  //--

  /// 鼠标或者手势是否按下
  bool get isPointerDown => canvasEventManager.isPointerDown;

  /// 元素的数量
  int get elementCount => allElementList.size();

  /// 所有单元素的数量
  int get singleElementCount => allSingleElementList.size();

  /// 画布的数量
  int get canvasCount => canvasMultiManager.canvasStateList.size();

  /// 画布上所有单级元素的集合
  /// 多画布的情况下通过[CanvasMultiManager]获取其他画布下的元素集合
  List<ElementPainter> get allElementList => canvasElementManager.elements;

  @dp
  @sceneCoordinate
  List<Rect> get allElementBoundsList =>
      allElementList.map((e) => e.elementsBounds).filterNull();

  /// 将[ElementGroupPainter]拆开后的集合
  List<ElementPainter> get allSingleElementList =>
      allElementList.getAllSingleElement();

  @dp
  @sceneCoordinate
  List<Rect> get allSingleElementBoundsList =>
      allSingleElementList.map((e) => e.elementsBounds).filterNull();

  //--

  /// 所有选中的元素集合
  List<ElementPainter>? get allSelectedElementList =>
      canvasElementManager.getAllSelectedElement();

  /// 所有选中的简单元素集合
  List<ElementPainter>? get allSelectedSingleElementList =>
      canvasElementManager.getAllSelectedElement(exportSingleElement: true);

  /// 所有选中的元素是否都是满足条件[test]的类型
  bool isSelectedSameElementType(bool Function(ElementPainter element) test) {
    return allSelectedSingleElementList?.all(test) ?? false;
  }

  //endregion ---get/set---

  //region ---core---

  /// 画布样式/配置参数等信息
  final CanvasStyle canvasStyle = CanvasStyle();

  /// 重绘通知, 监听此通知, 主动触发重绘
  /// [CanvasRenderBox]
  final ValueNotifier<int> repaint = ValueNotifier(0);

  /// 视口控制
  /// 包含视口原点位置
  /// 包含视口缩放/平移的信息
  /// 提供视口/世界坐标转换
  late CanvasViewBox canvasViewBox = CanvasViewBox(this);

  /// 绘制管理, 画布的背景, 坐标系, 监视器绘制
  /// 同时也是[canvasElementManager]的绘制入口
  /// 包含
  ///  - [CanvasAxisManager]
  ///  - [CanvasContentManager]
  ///  - [CanvasMonitorPainter]
  late CanvasPaintManager canvasPaintManager = CanvasPaintManager(this);

  CanvasContentManager get canvasContentManager =>
      canvasPaintManager.contentManager;

  /// 元素管理, 包含画布上所有的元素
  /// 并且元素控制器也在此管理器中
  /// - [CanvasElementControlManager]
  late CanvasElementManager canvasElementManager = CanvasElementManager(this);

  /// 画布跟随, 用来将画布视口[canvasViewBox]移动显示到目标位置
  late CanvasFollowManager canvasFollowManager = CanvasFollowManager(this);

  /// 事件管理, 画布事件操作, 元素控制事件入口
  late CanvasEventManager canvasEventManager = CanvasEventManager(this);

  /// 回退栈管理
  late CanvasUndoManager canvasUndoManager = CanvasUndoManager(this);

  /// 多画布管理, 用来管理/切换[canvasElementManager]中的元素
  /// 同时还控制[canvasUndoManager]的回退栈
  late CanvasMultiManager canvasMultiManager = CanvasMultiManager(this);

  /// 管理按键事件
  late CanvasKeyManager canvasKeyManager = CanvasKeyManager(this);

  /// 关键鼠标右键菜单
  late CanvasMenuManager canvasMenuManager = CanvasMenuManager(this);

  /// 画布回调监听
  final Set<CanvasListener> canvasListeners = {};

  /// 用来存储自定义的工程信息使用
  @flagProperty
  dynamic project;

  /// 画布数据, 用来存储自定义的数据
  @flagProperty
  final Map<String, dynamic> dataMap = {};

  //--属性

  /// 重绘次数
  @flagProperty
  int paintCount = 0;

  /// 获取调用刷新的次数
  int get refreshCount => repaint.value;

  /// 当前是否请求过刷新
  @flagProperty
  bool isRequestRefresh = false;

  /// 上一次请求刷新的时间, 毫秒
  Duration lastRequestRefreshTime = Duration.zero;

  /// 空闲超时时间
  Duration get idleTimeout => canvasStyle.idleTimeout;

  /// 是否有元素属性发生过改变
  /// [dispatchCanvasElementPropertyChanged]
  @flagProperty
  bool isAnyElementPropertyChanged = false;

  /// 是否有元素数量发生过改变
  /// [dispatchCanvasElementListChanged]
  /// [clearElementChangedFlag]
  @flagProperty
  bool isElementChanged = false;

  /// 是否有多画布发生过改变
  @flagProperty
  bool isCanvasStateChanged = false;

  /// 是否有元素改变标识, 通常同来实现自动保存工程的判断依据
  /// [clearElementChangedFlag]
  @flagProperty
  bool get hasElementChangedFlag =>
      isElementChanged || isCanvasStateChanged || isAnyElementPropertyChanged;

  //endregion ---core---

  //region ---api---

  /// [canvasMultiManager.isAllCanvasEmpty]
  @api
  bool get isAllCanvasEmpty => canvasMultiManager.isAllCanvasEmpty;

  /// [canvasMultiManager.isAllCanvasEmpty;]
  @api
  bool get isCurrentCanvasEmpty => canvasMultiManager.isCurrentCanvasEmpty;

  /// 震动反馈
  @api
  void vibrate() {
    delegateContext?.let((it) {
      Feedback.forLongPress(it);
    });
  }

  /// 请求重新布局, 在隐藏标尺之后, 需要重新布局
  @api
  void relayout() {
    final size = _layoutSize;
    if (size != null) {
      layout(size);
      refresh();
    }
  }

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
  @flagProperty
  void clearElementChangedFlag() {
    isElementChanged = false;
    isCanvasStateChanged = false;
    isAnyElementPropertyChanged = false;
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
  /// [restoreDefault] 当没有rect时, 是否恢复默认的100%
  ///
  /// [followPainter]
  @api
  void followRect({
    @sceneCoordinate Rect? rect,
    ElementPainter? elementPainter,
    EdgeInsets? margin,
    BoxFit? fit,
    bool? animate,
    bool? awaitAnimate,
    bool? restoreDefault,
  }) {
    if (elementPainter != null) {
      followPainter(elementPainter: elementPainter);
      return;
    }
    rect ??= canvasPaintManager.contentManager.canvasContentFollowRectInner ??
        canvasElementManager.allElementsBounds;
    if (rect == null || rect.isEmpty) {
      //followPainter(rect: canvasElementManager.allElementsBounds);
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }
    canvasFollowManager.followRect(
      rect,
      margin: margin,
      fit: fit,
      animate: animate,
      awaitAnimate: awaitAnimate,
      restoreDefault: restoreDefault,
    );
  }

  /// 跟随一个元素, 自动居中处理
  /// [followRect]
  /// [CanvasFollowManager.followRect]
  @api
  void followPainter({
    @sceneCoordinate Rect? rect,
    ElementPainter? elementPainter,
    @viewCoordinate EdgeInsets? margin,
    BoxFit? fit = BoxFit.none,
    Alignment? alignment = Alignment.center,
  }) {
    rect ??= elementPainter?.paintProperty?.getBounds(canvasElementManager
        .canvasElementControlManager.enableResetElementAngle);
    if (rect == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }
    canvasFollowManager.followRect(
      rect,
      margin: margin,
      fit: fit,
      alignment: alignment,
      animate: true,
      awaitAnimate: false,
    );
  }

  /// 移动画布到内容的边缘, 使得对应的内容边界在视口中显示
  @api
  void followContentEdge({
    Alignment alignment = Alignment.topCenter,
    @viewCoordinate EdgeInsets? margin = const EdgeInsets.all(kXxh),
    //--
    bool animate = true,
    bool awaitAnimate = false,
  }) {
    @sceneCoordinate
    final contentRect =
        canvasPaintManager.contentManager.canvasContentFollowRectInner;
    if (contentRect == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }
    margin ??= canvasFollowManager.margin;
    @viewCoordinate
    final contentViewRect = canvasViewBox.toViewRect(contentRect);
    //debugger();
    double tx = 0, ty = 0;
    //x
    if (alignment.isLeft) {
      tx = -(contentViewRect.left -
              canvasViewBox.canvasBounds.left -
              (margin?.left ?? 0)) /
          canvasViewBox.scaleX;
    }
    //y
    if (alignment.isTop) {
      ty = -(contentViewRect.top -
              canvasViewBox.canvasBounds.top -
              (margin?.top ?? 0)) /
          canvasViewBox.scaleY;
    }
    canvasViewBox.changeMatrix(
      canvasViewBox.canvasMatrix * createTranslateMatrix(tx: tx, ty: ty),
      animate: animate,
      awaitAnimate: awaitAnimate,
    );
  }

  /// 自动根据当前元素, 决定是否将内容边界移动到视口边缘
  /// [followContentEdge]
  @api
  void followContentEdgeAuto({
    ElementPainter? elementPainter,
    //--
    bool animate = true,
    bool awaitAnimate = false,
  }) {
    elementPainter ??= canvasElementManager.selectComponent;
    @sceneCoordinate
    final targetRect = elementPainter.elementsBounds;
    if (targetRect == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return;
    }
    @viewCoordinate
    final targetViewRect = canvasViewBox.toViewRect(targetRect);

    bool isInRight =
        targetViewRect.center.dx > canvasViewBox.canvasBounds.center.dx;
    bool isInBottom =
        targetViewRect.center.dy > canvasViewBox.canvasBounds.center.dy;

    if (isInRight && isInBottom) {
      followContentEdge(
          alignment: Alignment.topLeft,
          animate: animate,
          awaitAnimate: awaitAnimate);
    } else if (isInBottom) {
      //目标在视口整体中心的下方, 则内容区域往上移动
      followContentEdge(
          alignment: Alignment.topCenter,
          animate: animate,
          awaitAnimate: awaitAnimate);
    } else if (isInRight) {
      //目标在视口整体中心的右边, 则内容区域往左移动
      followContentEdge(
          alignment: Alignment.centerLeft,
          animate: animate,
          awaitAnimate: awaitAnimate);
    }
  }

  /// 选中指定的元素集合
  @api
  void selectElementList(
    List<ElementPainter>? elementPainters, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    canvasElementManager.resetSelectedElementList(
      elementPainters,
      selectType: selectType,
    );
  }

  /// 将画布上的整体状态压入栈, 可以用来恢复整个画布状态
  /// 不包含多画布, 只包含当前画布
  CanvasStateStack createStateStack() => CanvasStateStack(this)
    ..saveFrom(
      null,
      saveGroupChild: true,
    );

  /// 删除元素集合, 支持单独删除组内的元素
  /// 使用画布全栈保存/恢复的方式, 才能支持组内元素的删除, 此方法资源消耗大
  /// [CanvasElementManager.removeElementList]不支持删除组内元素
  @api
  @supportUndo
  void removeElementList(
    List<ElementPainter>? list, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (list == null || isNil(list)) {
      return;
    }

    final undoStateStack =
        undoType == UndoType.normal ? createStateStack() : null;

    //--开始操作
    final removeList = <ElementPainter>[];

    final elements = canvasElementManager.elements;
    final oldElements = elements.clone();
    for (final element in list) {
      if (elements.contains(element)) {
        removeList.add(element);
      } else {
        for (final group in elements) {
          if (group is ElementGroupPainter) {
            if (group.removeElement(element)) {
              removeList.add(element);
              if (group.isEmpty) {
                //删完child之后, 组内无元素, 则删除组
                removeList.add(group);
              }
            }
          }
        }
      }
    }
    //Concurrent modification during iteration: Instance(length:2) of '_GrowableList'.
    elements.removeAll(removeList);

    canvasElementManager.canvasElementControlManager
        .onCanvasElementDeleted(removeList, selectType);
    dispatchCanvasElementListChanged(
      oldElements,
      elements,
      elements,
      ElementChangeType.remove,
      undoType,
    );
    dispatchCanvasElementListRemoveChanged(elements, removeList);

    if (undoType == UndoType.normal) {
      final redoStateStack = createStateStack();
      canvasUndoManager.addUntoState(undoStateStack, redoStateStack);
    }
  }

  /// 画布进入预览模式
  /// [previewElement] 需要预览元素
  @api
  void previewMode({
    ElementPainter? previewElement,
    //--
    bool followElement = true,
  }) {
    canvasViewBox
      ..minScaleX = 0.001
      ..minScaleY = 0.001
      ..maxScaleX = 1000
      ..maxScaleY = 1000;

    canvasStyle
      ..showAxis = false
      ..showGrid = false
      ..showMonitor = isDebug
      ..enableElementControl = false;

    this.previewElement(
      previewElement,
      followElement: followElement,
    );
  }

  /// 预览指定元素
  @api
  void previewElement(
    ElementPainter? previewElement, {
    //--
    bool followElement = true,
  }) {
    canvasElementManager.resetElementList(
      [if (previewElement != null) previewElement],
      followElement: followElement,
      undoType: UndoType.none,
      fit: BoxFit.contain,
    );
  }

  /// 访问所有元素
  /// [CanvasElementManager.visitElementPainter]
  @api
  void visitElementPainter(
    ElementPainterVisitor visitor, {
    bool reverse = false,
  }) =>
      canvasElementManager.visitElementPainter(visitor, reverse: reverse);

  /// 在画布中的指定位置, 显示菜单
  /// 比如鼠标右键弹起, 显示对应的菜单
  /// [showMenus]
  /// [showWidgetMenu]
  @api
  Future<T?> showMenus<T>(
    List<Widget>? menus, {
    @viewCoordinate Offset? position,
  }) async {
    final context = delegateContext;
    if (context == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return null;
    }
    return context.showMenus<T>(
      menus,
      position: position,
    );
  }

  /// [showMenus]
  /// [showWidgetMenu]
  @api
  Future<T?> showWidgetMenu<T>(
    Widget menu, {
    @viewCoordinate Offset? position,
  }) async {
    final context = delegateContext;
    if (context == null) {
      assert(() {
        l.w("无效的操作");
        return true;
      }());
      return null;
    }
    return context.showWidgetMenu(
      menu,
      position: position,
      /*color: Color(0xff232327),*/
    );
  }

  /// 隐藏菜单
  /// [showMenus]
  @api
  void hideMenu<T extends Object?>([T? result]) {
    delegateContext?.popMenu(result);
  }

  //endregion ---api---

  //region ---事件派发---

  /// each
  /// [canvasListeners]
  void _eachCanvasListener(void Function(CanvasListener listener) action) {
    try {
      for (final client in canvasListeners) {
        try {
          action(client);
        } catch (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
        }
      }
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  /// 派发画布重绘的次数
  void dispatchCanvasPaint(CanvasDelegate delegate, int paintCount) {
    _eachCanvasListener((element) {
      element.onCanvasPaintAction?.call(delegate, paintCount);
    });
  }

  /// 派发画布空闲时的回调, 当没有请求[refresh]方法时触发
  void dispatchCanvasIdle(CanvasDelegate delegate, Duration lastRefreshTime) {
    _eachCanvasListener((element) {
      element.onCanvasIdleAction?.call(delegate, lastRefreshTime);
    });
  }

  /// 当[CanvasViewBox]视口可绘制区域发生变化时触发
  /// [CanvasViewBox.updatePaintBounds]
  void dispatchCanvasViewBoxPaintBoundsChanged(
    CanvasViewBox canvasViewBox,
    Rect fromPaintBounds,
    Rect toPaintBounds,
    bool isFirstInitialize,
  ) {
    CanvasViewBoxPaintBoundsChangedNotification(
      canvasViewBox,
      fromPaintBounds,
      toPaintBounds,
      isFirstInitialize,
    ).dispatch(delegateContext);
    _eachCanvasListener((element) {
      element.onCanvasViewBoxPaintBoundsChangedAction?.call(
        canvasViewBox,
        fromPaintBounds,
        toPaintBounds,
        isFirstInitialize,
      );
    });
    refresh();
  }

  /// 当[CanvasViewBox]视口发生变化时触发
  /// [CanvasViewBox.changeMatrix]
  void dispatchCanvasViewBoxChanged(
    CanvasViewBox canvasViewBox,
    bool fromInitialize,
    bool isCompleted,
  ) {
    canvasElementManager.canvasElementControlManager.updateControlBounds();
    canvasPaintManager.axisManager.updateAxisData(canvasViewBox);
    CanvasViewBoxChangedNotification(canvasViewBox, isCompleted)
        .dispatch(delegateContext);
    _eachCanvasListener((element) {
      element.onCanvasViewBoxChangedAction?.call(
        canvasViewBox,
        fromInitialize,
        isCompleted,
      );
    });
    refresh();
  }

  /// 当[CanvasAxisManager.axisUnit]坐标系的单位发生变化时触发
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
  /// [propertyType] 标识当前的属性变化的类型
  /// [fromUndoType] 标识当前的操作是否是来自回退栈/撤销/重做
  /// [PainterPropertyType.paint] -> [ElementPainter.paintProperty]
  /// [PainterPropertyType.state] -> [ElementPainter.paintState]
  /// [PainterPropertyType.data]
  /// [PainterPropertyType.mode]
  void dispatchCanvasElementPropertyChanged(
    ElementPainter elementPainter,
    dynamic from,
    dynamic to,
    PainterPropertyType propertyType,
    Object? fromObj,
    UndoType? fromUndoType,
  ) {
    isAnyElementPropertyChanged = true;
    /*assert(() {
      l.d('元素属性发生改变:$elementPainter $from->$to :$propertyType');
      return true;
    }());*/
    canvasElementManager.canvasElementControlManager
        .onSelfElementPropertyChanged(
      elementPainter,
      propertyType,
      fromObj,
      fromUndoType,
    );
    _eachCanvasListener((element) {
      element.onCanvasElementPropertyChangedAction?.call(
        elementPainter,
        from,
        to,
        propertyType,
        fromObj,
        fromUndoType,
      );
    });
    refresh();
  }

  /// 选择的元素改变后回调
  /// [to] 为null or empty时, 表示取消选择
  void dispatchCanvasElementSelectChanged(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
    ElementSelectType selectType,
  ) {
    _eachCanvasListener((element) {
      element.onCanvasElementSelectChangedAction
          ?.call(selectComponent, from, to, selectType);
    });
    refresh();
  }

  /// 按下时, 有多个元素需要被选中.
  /// 默认按下选中回调只会回调最上层的元素, 可以通过此方法弹出选择其他元素的对话框
  void dispatchCanvasSelectElementList(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? list,
    ElementSelectType selectType,
  ) {
    _eachCanvasListener((element) {
      element.onCanvasSelectElementListAction
          ?.call(selectComponent, list, selectType);
    });
  }

  /// 元素列表发生改变
  /// 比如:
  /// [CanvasElementManager.addElementList] 添加了新元素
  /// [CanvasElementManager.removeElementList] 删除了元素
  /// [CanvasElementManager.replaceElementList] 替换了元素
  /// [CanvasElementManager.arrangeElementList] 排序了元素顺序
  /// [CanvasMultiManager.selectCanvasState] 切换了画布
  void dispatchCanvasElementListChanged(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    ElementChangeType changeType,
    UndoType undoType, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    //debugger();
    isElementChanged = true;
    canvasElementManager.canvasElementControlManager.onSelfElementListChanged(
      from,
      to,
      op,
      changeType,
      undoType,
      selectType,
    );
    _eachCanvasListener((element) {
      element.onCanvasElementListChangedAction?.call(
        from,
        to,
        op,
        changeType,
        undoType,
      );
    });
    refresh();
  }

  /// 元素列表添加元素通知
  /// [list] 有可能是[CanvasElementManager.beforeElements].[CanvasElementManager.elements].[CanvasElementManager.afterElements]
  void dispatchCanvasElementListAddChanged(
    List<ElementPainter> list,
    List<ElementPainter>? op,
  ) {
    if (op == null || isNil(op)) {
      return;
    }
    _eachCanvasListener((element) {
      element.onCanvasElementListAddChanged?.call(list, op);
    });
  }

  /// 元素列表移除元素通知
  /// [list] 有可能是[CanvasElementManager.beforeElements].[CanvasElementManager.elements].[CanvasElementManager.afterElements]
  void dispatchCanvasElementListRemoveChanged(
    List<ElementPainter> list,
    List<ElementPainter>? op,
  ) {
    if (op == null || isNil(op)) {
      return;
    }
    _eachCanvasListener((element) {
      element.onCanvasElementListRemoveChanged?.call(list, op);
    });
  }

  /// 双击元素时回调
  void dispatchDoubleTapElement(ElementPainter elementPainter) {
    _eachCanvasListener((element) {
      element.onDoubleTapElementAction?.call(elementPainter);
    });
  }

  /// 点击/长按元素时回调
  void dispatchTouchDetectorElement(
      List<ElementPainter> elementList, TouchDetectorType touchType) {
    _eachCanvasListener((element) {
      element.onTouchDetectorElement?.call(elementList, touchType);
    });
  }

  /// 移动元素时回调
  /// [targetElement] 移动的目标元素
  /// [isFirstTranslate] 是否是首次移动
  /// [isEnd] 是否移动结束
  void dispatchTranslateElement(
    ElementPainter? targetElement,
    bool isFirstTranslate,
    bool isEnd,
  ) {
    _eachCanvasListener((element) {
      element.onTranslateElementAction?.call(
        targetElement,
        isFirstTranslate,
        isEnd,
      );
    });
  }

  /// 手势按下时回调
  /// [position] 按下时的坐标
  /// [downMenu] 是否有菜单在手势下面 [ElementMenuControl.onCreateElementMenuAction]
  /// [downElementList] 按下时, 有哪些元素在手势下面
  /// [isRepeatSelect] 是否是重复按下, 在选择器上重复按下
  void dispatchPointerDown(
    @viewCoordinate Offset position,
    ElementMenu? downMenu,
    List<ElementPainter>? downElementList,
    bool isRepeatSelect,
  ) {
    _eachCanvasListener((element) {
      element.onPointerDownAction
          ?.call(position, downMenu, downElementList, isRepeatSelect);
    });
  }

  /// 点击指定菜单时回调, 和[ElementMenu.onTap]同步回调
  void dispatchElementTapMenu(ElementMenu menu) {
    _eachCanvasListener((element) {
      element.onElementTapMenuAction?.call(menu);
    });
  }

  /// 控制点[BaseControl]控制状态改变时回调
  void dispatchControlStateChanged({
    required BaseControl control,
    ElementPainter? controlElement,
    required ControlState state,
  }) {
    _eachCanvasListener((element) {
      element.onControlStateChangedAction?.call(
        control: control,
        controlElement: controlElement,
        state: state,
      );
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

  /// [CanvasContentManager.canvasCenterInner]画布内容改变通知
  void dispatchCanvasContentChanged() {
    _eachCanvasListener((element) {
      element.onCanvasContentChangedAction?.call();
    });
  }

  /// 多画布状态改变通知, 比如添加了一个画布/移除了一个画布
  /// [canvasStateData] 画布状态数据
  /// [type] 新增画布/移除画布
  void dispatchCanvasMultiStateChanged(
      CanvasStateData canvasStateData, CanvasStateType type) {
    isCanvasStateChanged = true;
    _eachCanvasListener((element) {
      element.onCanvasMultiStateChanged?.call(canvasStateData, type);
    });
  }

  /// 多画布的列表改变通知
  void dispatchCanvasMultiStateListChanged(List<CanvasStateData> to) {
    isCanvasStateChanged = true;
    _eachCanvasListener((element) {
      element.onCanvasMultiStateListChanged?.call(to);
    });
  }

  /// 选中的画布改变
  void dispatchCanvasSelectedStateChanged(
      CanvasStateData? from, CanvasStateData? to) {
    _eachCanvasListener((element) {
      element.onCanvasSelectedStateChanged?.call(from, to);
    });
  }

  /// 有元素添加到画布回调
  void dispatchElementAttachToCanvasDelegate(ElementPainter painter) {
    _eachCanvasListener((element) {
      element.onElementAttachToCanvasDelegate?.call(this, painter);
    });
  }

  /// 有元素从画布移除回调
  void dispatchElementDetachFromCanvasDelegate(ElementPainter painter) {
    _eachCanvasListener((element) {
      element.onElementDetachToCanvasDelegate?.call(this, painter);
    });
  }

  /// 构建画布右键菜单
  /// [canvasListeners]
  /// @return 返回菜单列表
  List<Widget> dispatchBuildCanvasMenu() {
    List<Widget> list = [];
    _eachCanvasListener((element) {
      element.onBuildCanvasMenu?.call(this, canvasMenuManager, list);
    });
    return list;
  }

  //endregion ---事件派发---

  //region ---辅助---

  /// 暗色主题时, 返回[dark], 否则返回[light]
  T? darkOr<T>([T? dark, T? light]) =>
      delegateContext?.isThemeDark == true ? dark : light;

  //endregion ---辅助---

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
    properties.add(FlagProperty('有元素改变', value: hasElementChangedFlag));
    properties.add(canvasViewBox.toDiagnosticsNode(
      name: '视口控制',
      style: DiagnosticsTreeStyle.sparse,
    ));
    properties.add(DiagnosticsProperty<Ticker?>('ticker', _ticker));

    properties.add(FlagProperty("重置旋转角度",
        value: canvasElementManager
            .canvasElementControlManager.enableResetElementAngle));
    properties.add(FlagProperty("激活控制交互",
        value: canvasElementManager
            .canvasElementControlManager.enableElementControl));
    properties.add(FlagProperty("激活点击元素外取消选择",
        value: canvasElementManager
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

    //--

    properties.add(DiagnosticsProperty('project', project));
    properties.add(DiagnosticsProperty('dataMap', dataMap));
  }

//endregion ---diagnostic---
}

/// 画布状态栈[CanvasDelegate], 不包含多画布, 只包含当前画布
class CanvasStateStack extends ElementStateStack {
  final CanvasDelegate canvasDelegate;

  CanvasStateStack(this.canvasDelegate);

  @override
  void saveFrom(
    ElementPainter? element, {
    List<ElementPainter>? otherStateElementList,
    List<ElementPainter>? otherStateExcludeElementList,
    bool? saveGroupChild,
  }) {
    final group = ElementGroupPainter();
    group.children = [...canvasDelegate.canvasElementManager.elements];
    super.saveFrom(
      group,
      otherStateElementList: otherStateElementList,
      otherStateExcludeElementList: otherStateExcludeElementList,
      saveGroupChild: saveGroupChild,
    );
  }

  @override
  void restore() {
    super.restore();
    final group = fromElement;
    if (group is ElementGroupPainter) {
      canvasDelegate.canvasElementManager.elements.reset(group.children);
    }
  }
}
