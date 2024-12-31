part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/01
///
/// 画布小部件代理核心类
class CanvasWidget extends LeafRenderObjectWidget {
  final CanvasDelegate canvasDelegate;

  /// 是否要激活[WidgetElementPainter]的功能
  final bool enableWidgetRender;

  const CanvasWidget(
    this.canvasDelegate, {
    super.key,
    this.enableWidgetRender = isDebug,
  });

  @override
  LeafRenderObjectElement createElement() => enableWidgetRender
      ? CanvasRenderObjectElement(this)
      : LeafRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => CanvasRenderBox(
        context,
        canvasDelegate..delegateContext = context,
      );

  @override
  void updateRenderObject(BuildContext context, CanvasRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    canvasDelegate.delegateContext = context;
    renderObject
      ..context = context
      ..canvasDelegate = canvasDelegate
      ..markNeedsPaint();
  }

  @override
  void didUnmountRenderObject(CanvasRenderBox renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('canvasDelegate', canvasDelegate));
    properties
        .add(FlagProperty('enableWidgetRender', value: enableWidgetRender));
  }
}

/// [Element]负责控制[RenderObject]
class CanvasRenderObjectElement extends LeafRenderObjectElement {
  CanvasRenderObjectElement(super.widget);

  @override
  CanvasRenderBox get renderObject => super.renderObject as CanvasRenderBox;

  @override
  void forgetChild(Element child) {
    //debugger();
    super.forgetChild(child);
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    //debugger();
    return super.updateChild(child, newWidget, newSlot);
  }

  @override
  void deactivateChild(Element child) {
    //debugger();
    if (child.mounted) {
      super.deactivateChild(child);
    }
  }

  /// 停用时, 所有的[RenderObject]都必须[RenderObject.detach]
  /// [Element.updateChildren]
  /// ```
  /// Failed assertion: line 6658 pos 7: '!renderObject.attached': A RenderObject was still attached when attempting to deactivate its RenderObjectElement: RenderDecoratedBox#a056b relayoutBoundary=up4 NEEDS-PAINT
  /// ```
  @override
  void deactivate() {
    //debugger();
    super.deactivate();
  }

  /// [Element.visitChildElements]->[Element.visitChildren]
  @override
  void visitChildren(ElementVisitor visitor) {
    final widget = this.widget;
    if (widget is CanvasWidget) {
      widget.canvasDelegate.visitElementPainter((painter) {
        if (painter is WidgetElementPainter) {
          final element = painter._widgetElement;
          if (element != null) {
            visitor(element);
          }
        }
      });
    }
    super.visitChildren(visitor);
  }

  /// 当有[RenderObject]对象需要插入到当前的树中时, 那么就会触发此回调
  /// [RenderObjectElement._findAncestorRenderObjectElement]
  ///
  /// [Element.inflateWidget]->[Element.mount]->[RenderObjectElement.attachRenderObject]->
  /// [insertRenderObjectChild]
  ///
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    //debugger();
    renderObject.insertChild(child);
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    debugger();
  }

  /// [Element.deactivateChild]->[Element.detachRenderObject]->[Element.visitChildren]->
  /// [child.detachRenderObject()]
  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    //debugger();
    renderObject.removeChild(child);
  }

  /// 当自己是一个[RenderObjectElement]元素, 那么[mount]时, 就会触发此回调
  /// [RenderObjectWidget.createRenderObject]
  @override
  void attachRenderObject(Object? newSlot) {
    //debugger();
    super.attachRenderObject(newSlot);
  }

  //--

  /// 安装一个[Widget]得到对应的[Element]
  /// 通过[Element.findRenderObject]获取对应的[RenderObject]
  @callPoint
  Element? mountWidget(
    Widget widget, {
    Object? slot,
  }) {
    Element? widgetElement;
    final owner = this.owner;
    if (owner != null) {
      owner.lockState(() {
        final newChild = inflateWidget(widget, slot);
        widgetElement = newChild;
        /*widgetElement = newChild.findRenderObject();
        widgetElement?.attach(renderObject.owner!);*/
      });
    } else {
      assert(() {
        l.w("不支持的操作->owner is null");
        return true;
      }());
    }
    return widgetElement;
  }

  /// [CanvasRenderObjectElement.deactivateChild]
  /// 卸载一个[Element]
  ///
  /// ```
  /// Failed assertion: line 4519 pos 12: 'child._parent == this': is not true.
  /// ```
  ///
  @callPoint
  void unmountWidget(Element element) {
    try {
      //debugger();
      deactivateChild(element);
    } catch (e) {
      // Clean-up failed. Only surface original exception.
      assert(() {
        printError(e);
        return true;
      }());
    }
  }
}

/// 画布渲染核心类
/// 负责画布的绘制入口
/// 负责画布的手势入口
class CanvasRenderBox extends RenderBox {
  BuildContext context;
  CanvasDelegate canvasDelegate;

  CanvasRenderBox(
    this.context,
    this.canvasDelegate,
  );

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    final constraints = this.constraints;
    double? width =
        constraints.maxWidth == double.infinity ? null : constraints.maxWidth;
    double? height =
        constraints.maxHeight == double.infinity ? null : constraints.maxHeight;
    size = Size(
      width ?? height ?? screenWidth,
      height ?? width ?? screenHeight,
    );
    //debugger();
    canvasDelegate.layout(size);
  }

  /// [RenderProxyBoxMixin.performLayout]
  ///
  /// ```
  /// To set the gesture recognizers at other times, trigger a new build using setState() and provide the new gesture recognizers as constructor arguments to the corresponding RawGestureDetector or GestureDetector object.
  /// ```
  ///
  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    //debugger();
    /*visitWidgetElementPainter((painter) {
      //debugger();
      final render = painter._widgetRender;
      if (render?.hasRenderSize == true) {
        //no op
      } else if (render != null) {
        final paintProperty = painter.paintProperty;
        if (paintProperty == null) {
          render.layout(BoxConstraints(), parentUsesSize: true);
          final renderSize = render.renderSize;
          if (renderSize == null) {
            assert(() {
              l.w("[WidgetElementPainter][${render.runtimeType}] renderSize == null");
              return true;
            }());
          }
          final size = renderSize ?? Size.zero;
          //debugger();
          painter.initPaintProperty(
              rect: Rect.fromLTWH(0, 0, size.width, size.height));
        } else {
          render.layout(
              BoxConstraints.expand(
                width: paintProperty.width,
                height: paintProperty.height,
              ),
              parentUsesSize: true);
        }
      }
    });*/
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  /// [RendererBinding.drawFrame]->[PipelineOwner.flushPaint]->[PaintingContext.repaintCompositedChild]
  /// [RenderProxyBoxMixin.paint]
  @override
  void paint(PaintingContext context, Offset offset) {
    //debugger();
    canvasDelegate.paint(context, offset);
  }

  /// [GestureBinding.handlePointerEvent]->[RenderView.hitTest]->[RenderBox.hitTest]
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return super.hitTestChildren(result, position: position);
  }

  /// [GestureBinding.handlePointerEvent]->[RendererBinding.dispatchEvent]->[RenderBox.handleEvent]
  ///
  /// [RenderTransform]
  /// [RenderPointerListener]
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    final hitInterceptBox = GestureHitInterceptScope.of(context);
    hitInterceptBox?.interceptHitBox = this;
    canvasDelegate.handleEvent(event, entry);
    /*assert((){
      l.w("handleEvent:${event.runtimeType} ${event.buttons}");
      return true;
    }());*/
    //debugger();
  }

  /// [CanvasRenderBox]
  /// [RenderObjectElement.attachRenderObject]->[SingleChildRenderObjectElement.insertRenderObjectChild]->
  /// [RenderObjectWithChildMixin.adoptChild]->[RenderObject.attach]
  /// 在这里直接[mountWidget]会出现
  /// ```
  /// parent!._relayoutBoundary
  /// ```
  /// 所以延迟调用.
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    //debugger();
    postFrame(() {
      visitWidgetElementPainter((painter) {
        //debugger();
        painter.mountWidget(canvasDelegate, isUpdate: false);
      });
    });
    canvasDelegate.repaint.addListener(_repaintListener);
    canvasDelegate.attach();
  }

  /// [CanvasRenderBox]
  /// 所有的[RenderObject]child都必须[remove]
  /// [ContainerRenderObjectMixin.remove]
  ///
  /// ```
  /// Failed assertion: line 1873 pos 12: 'child.attached == attached': is not true.
  /// ```
  ///
  @override
  void detach() {
    //debugger();
    visitWidgetElementPainter((painter) {
      final render = painter._widgetRender;
      if (render != null) {
        //debugger();
        removeChild(render);
      }
    });
    super.detach();
    canvasDelegate.repaint.removeListener(_repaintListener);
    canvasDelegate.detach();
  }

  @override
  void dispose() {
    canvasDelegate.dispose();
    super.dispose();
  }

  //--

  /// 重绘
  void _repaintListener() {
    if (owner != null && !owner!.debugDoingPaint) {
      markNeedsPaint();
    } else {
      postCallback(() {
        _repaintListener();
      });
    }
  }

  //--

  /// 只有在[Layer]层的[RenderObject]才能调用[paint]方法
  ///
  /// ```
  /// A RenderObject that still has dirty compositing bits cannot be painted because this indicates that the tree has not yet been properly configured for creating the layer tree.
  /// This usually indicates an error in the Flutter framework itself.
  /// ```
  ///
  @callPoint
  void insertChild(RenderObject child) {
    //debugger();
    adoptChild(child);
  }

  @callPoint
  void removeChild(RenderObject child) {
    //debugger();
    dropChild(child);
  }

  /// [CanvasRenderBox]
  ///
  /// [RendererBinding.drawFrame]->[PipelineOwner.flushCompositingBits]->
  /// [RenderObject._updateCompositingBits]->[RenderObject.visitChildren]
  ///
  /// [ContainerRenderObjectMixin.visitChildren]
  @override
  void visitChildren(RenderObjectVisitor visitor) {
    //debugger();
    visitWidgetElementPainter((painter) {
      final render = painter._widgetRender;
      if (render != null) {
        visitor(render);
      }
    });
  }

  @callPoint
  void visitElementPainter(ElementPainterVisitor visitor) {
    canvasDelegate.visitElementPainter(visitor);
  }

  @callPoint
  void visitWidgetElementPainter(
      void Function(WidgetElementPainter element) visitor) {
    visitElementPainter((painter) {
      if (painter is WidgetElementPainter) {
        visitor(painter);
      }
    });
  }
}

/// 画布回调监听
class CanvasListener {
  /// [CanvasDelegate.dispatchCanvasPaint]
  final void Function(
    CanvasDelegate delegate,
    int paintCount,
  )? onCanvasPaintAction;

  /// [CanvasDelegate.dispatchCanvasIdle]
  final void Function(
    CanvasDelegate delegate,
    Duration lastRefreshTime,
  )? onCanvasIdleAction;

  /// [CanvasDelegate.dispatchCanvasViewBoxPaintBoundsChanged]
  final void Function(
    CanvasViewBox canvasViewBox,
    Rect fromPaintBounds,
    Rect toPaintBounds,
    bool isFirstInitialize,
  )? onCanvasViewBoxPaintBoundsChangedAction;

  /// [CanvasDelegate.dispatchCanvasViewBoxChanged]
  final void Function(
    CanvasViewBox canvasViewBox,
    bool fromInitialize,
    bool isCompleted,
  )? onCanvasViewBoxChangedAction;

  /// [CanvasDelegate.dispatchCanvasUnitChanged]
  final void Function(
    IUnit from,
    IUnit to,
  )? onCanvasUnitChangedAction;

  /// [CanvasDelegate.dispatchCanvasSelectBoundsChanged]
  final void Function(Rect? bounds)? onCanvasSelectBoundsChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  final void Function(
    ElementPainter elementPainter,
    dynamic from,
    dynamic to,
    PainterPropertyType propertyType,
    Object? fromObj,
    UndoType? fromUndoType,
  )? onCanvasElementPropertyChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementSelectChanged]
  /// 选择的元素改变后回调
  /// 要想监听在一个选中的元素上重复点击, 可以通过[onPointerDownAction].[isRepeatSelect]参数实现
  final void Function(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? from,
    List<ElementPainter>? to,
    ElementSelectType selectType,
  )? onCanvasElementSelectChangedAction;

  /// [CanvasDelegate.dispatchCanvasSelectElementList]
  /// 按下时, 有多个元素需要被选中.
  final void Function(
    ElementSelectComponent selectComponent,
    List<ElementPainter>? list,
    ElementSelectType selectType,
  )? onCanvasSelectElementListAction;

  /// [CanvasDelegate.dispatchCanvasElementListChanged]
  final void Function(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    ElementChangeType changeType,
    UndoType undoType,
  )? onCanvasElementListChangedAction;

  /// [CanvasDelegate.dispatchCanvasElementListAddChanged]
  final void Function(
    List<ElementPainter> list,
    List<ElementPainter> op,
  )? onCanvasElementListAddChanged;

  /// [CanvasDelegate.dispatchCanvasElementListRemoveChanged]
  final void Function(
    List<ElementPainter> list,
    List<ElementPainter> op,
  )? onCanvasElementListRemoveChanged;

  /// [CanvasDelegate.dispatchDoubleTapElement]
  final void Function(ElementPainter elementPainter)? onDoubleTapElementAction;

  /// [CanvasDelegate.dispatchTouchDetectorElement]
  final void Function(
          List<ElementPainter> elementList, TouchDetectorType touchType)?
      onTouchDetectorElement;

  /// [CanvasDelegate.dispatchTranslateElement]
  final void Function(
    ElementPainter? targetElement,
    bool isFirstTranslate,
    bool isEnd,
  )? onTranslateElementAction;

  /// [CanvasDelegate.dispatchPointerDown]
  final void Function(
    @viewCoordinate Offset position,
    ElementMenu? downMenu,
    List<ElementPainter>? downElementList,
    bool isRepeatSelect,
  )? onPointerDownAction;

  /// [CanvasDelegate.dispatchElementTapMenu]
  final void Function(ElementMenu menu)? onElementTapMenuAction;

  /// [CanvasDelegate.dispatchControlStateChanged]
  final void Function({
    required BaseControl control,
    ElementPainter? controlElement,
    required ControlState state,
  })? onControlStateChangedAction;

  /// [CanvasDelegate.dispatchCanvasUndoChanged]
  final void Function(CanvasUndoManager undoManager)? onCanvasUndoChangedAction;

  /// [CanvasDelegate.dispatchCanvasGroupChanged]
  final void Function(
    ElementGroupPainter group,
    List<ElementPainter> elements,
  )? onCanvasGroupChangedAction;

  /// [CanvasDelegate.dispatchCanvasUngroupChanged]
  final void Function(ElementGroupPainter group)? onCanvasUngroupChangedAction;

  /// [CanvasDelegate.dispatchCanvasContentChanged]
  final void Function()? onCanvasContentChangedAction;

  /// [CanvasDelegate.dispatchCanvasMultiStateChanged]
  final void Function(CanvasStateData canvasStateData, CanvasStateType type)?
      onCanvasMultiStateChanged;

  /// [CanvasDelegate.dispatchCanvasMultiStateListChanged]
  final void Function(List<CanvasStateData> to)? onCanvasMultiStateListChanged;

  /// [CanvasDelegate.dispatchCanvasSelectedStateChanged]
  final void Function(CanvasStateData? from, CanvasStateData? to)?
      onCanvasSelectedStateChanged;

  /// [CanvasDelegate.dispatchElementAttachToCanvasDelegate]
  final void Function(CanvasDelegate delegate, ElementPainter painter)?
      onElementAttachToCanvasDelegate;

  /// [CanvasDelegate.dispatchElementAttachToCanvasDelegate]
  final void Function(CanvasDelegate delegate, ElementPainter painter)?
      onElementDetachToCanvasDelegate;

  CanvasListener({
    this.onCanvasPaintAction,
    this.onCanvasIdleAction,
    this.onCanvasViewBoxPaintBoundsChangedAction,
    this.onCanvasViewBoxChangedAction,
    this.onCanvasUnitChangedAction,
    this.onCanvasSelectBoundsChangedAction,
    this.onCanvasElementPropertyChangedAction,
    this.onCanvasElementSelectChangedAction,
    this.onCanvasSelectElementListAction,
    this.onCanvasElementListChangedAction,
    this.onCanvasElementListAddChanged,
    this.onCanvasElementListRemoveChanged,
    this.onDoubleTapElementAction,
    this.onTouchDetectorElement,
    this.onTranslateElementAction,
    this.onPointerDownAction,
    this.onElementTapMenuAction,
    this.onCanvasUndoChangedAction,
    this.onCanvasGroupChangedAction,
    this.onCanvasUngroupChangedAction,
    this.onControlStateChangedAction,
    this.onCanvasContentChangedAction,
    this.onCanvasMultiStateChanged,
    this.onCanvasMultiStateListChanged,
    this.onCanvasSelectedStateChanged,
    this.onElementAttachToCanvasDelegate,
    this.onElementDetachToCanvasDelegate,
  });
}
