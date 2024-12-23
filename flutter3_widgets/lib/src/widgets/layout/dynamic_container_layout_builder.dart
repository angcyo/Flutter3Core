part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/22
///

//region ---基础代码---

/// [BaseDynamicConstrainedLayoutBuilder]
/// 来自[ConstrainedLayoutBuilder]
@fromFramework
abstract class BaseDynamicMultiConstrainedLayoutBuilder<
        ConstraintType extends Constraints,
        Condition,
        ParentDataType extends ContainerParentDataMixin<RenderObject>>
    extends RenderObjectWidget
    with DynamicConstrainedLayoutBuilderMixin<ConstraintType, Condition> {
  const BaseDynamicMultiConstrainedLayoutBuilder({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.initCondition,
  });

  /// [MultiChildRenderObjectWidget.children]
  final List<Widget> children;

  /// 动态构建布局的回调
  @override
  final Widget? Function(BuildContext context, ConstraintType constraints,
      Condition? condition)? builder;

  /// 初始化时的条件, 只在首次[Element.mount]时有效
  @override
  final Condition? initCondition;

  /// [MultiChildRenderObjectElement]
  @override
  _DynamicContainerLayoutBuilderElement createElement() =>
      _DynamicContainerLayoutBuilderElement<ConstraintType, Condition,
          ParentDataType>(this);

  @protected
  bool updateShouldRebuild(
          covariant BaseDynamicConstrainedLayoutBuilder<ConstraintType,
                  Condition>
              oldWidget) =>
      true;

  /// [Element.performRebuild]↓
  /// [Element._performRebuild]↓
  /// [RenderObjectWidget.updateRenderObject]↓
  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
  }

  /// [Element.unmount]↓ 卸载
  /// [RenderObjectWidget.didUnmountRenderObject]↓
  /// [RenderObject.dispose]↓
  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

// updateRenderObject is redundant with the logic in the LayoutBuilderElement below.
}

/// [_DynamicContainerLayoutBuilderElement]
/// 来自[_LayoutBuilderElement]
@fromFramework
class _DynamicContainerLayoutBuilderElement<
        ConstraintType extends Constraints,
        Condition,
        ParentDataType extends ContainerParentDataMixin<RenderObject>>
    extends RenderObjectElement {
  _DynamicContainerLayoutBuilderElement(
      DynamicConstrainedLayoutBuilderMixin<ConstraintType, Condition>
          super.widget);

  /// 这里需要[RenderObject.invokeLayoutCallback]方法
  @override
  DynamicRenderConstrainedLayoutBuilderMixin<ConstraintType, RenderObject,
          Condition>
      get renderObject =>
          super.renderObject as DynamicRenderConstrainedLayoutBuilderMixin<
              ConstraintType, RenderObject, Condition>;

  /// 来自[MultiChildRenderObjectElement]
  @fromFramework
  @protected
  @visibleForTesting
  Iterable<Element> get children =>
      _children.where((Element child) => !_forgottenChildren.contains(child));

  late List<Element> _children;

  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  /// 当前创建[_child]时的[Widget]
  Widget? _childWidget;

  /// 当前动态创建的child
  Element? _child;

  /// 当前的条件
  /// [_rebuildWithConstraints]
  Condition? _condition;

  /// 是否是首次安装
  bool isFirstMount = true;

  List<Widget> get _childrenWidget {
    final BaseDynamicMultiConstrainedLayoutBuilder
        multiChildRenderObjectWidget =
        widget as BaseDynamicMultiConstrainedLayoutBuilder;
    return [
      ...multiChildRenderObjectWidget.children,
      if (_childWidget != null) _childWidget!
    ];
  }

  @override
  BuildScope get buildScope => _buildScope;

  late final BuildScope _buildScope =
      BuildScope(scheduleRebuild: _scheduleRebuild);

  // To schedule a rebuild, markNeedsLayout needs to be called on this Element's
  // render object (as the rebuilding is done in its performLayout call). However,
  // the render tree should typically be kept clean during the postFrameCallbacks
  // and the idle phase, so the layout data can be safely read.
  bool _deferredCallbackScheduled = false;

  void _scheduleRebuild() {
    if (_deferredCallbackScheduled) {
      return;
    }

    final bool deferMarkNeedsLayout =
        switch (SchedulerBinding.instance.schedulerPhase) {
      SchedulerPhase.idle || SchedulerPhase.postFrameCallbacks => true,
      SchedulerPhase.transientCallbacks ||
      SchedulerPhase.midFrameMicrotasks ||
      SchedulerPhase.persistentCallbacks =>
        false,
    };
    if (!deferMarkNeedsLayout) {
      renderObject.markNeedsLayout();
      return;
    }
    _deferredCallbackScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
  }

  void _frameCallback(Duration timestamp) {
    _deferredCallbackScheduled = false;
    // This method is only called when the render tree is stable, if the Element
    // is deactivated it will never be reincorporated back to the tree.
    if (mounted) {
      renderObject.markNeedsLayout();
    }
  }

  /// [RenderObjectElement.mount]↓
  /// [RenderObjectElement.attachRenderObject]↓
  /// [RenderObjectElement.insertRenderObjectChild]↓
  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    //debugger();
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject as ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>>;
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child, after: slot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  /// child从一个槽, 移动到另一个槽
  /// [Element.updateChild]↓
  /// [Element.updateSlotForChild]↓
  /// [Element.visit]↓
  /// [Element.updateSlot]↓
  /// [Element.moveRenderObjectChild]↓
  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element?> oldSlot,
      IndexedSlot<Element?> newSlot) {
    debugger();
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject as ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>>;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    //debugger();
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject as ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>>;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    //debugger();
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    debugger();
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'The children of `MultiChildRenderObjectElement` must each has an associated render object.'),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                  'The following element does not have an associated render object'),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }

  /// [update]->[updateChild]->[updateChildren]
  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    //debugger();
    return super.updateChild(child, newWidget, newSlot);
  }

  /// 更新多个时调用, 更新多个里面又会调用更新单个[updateChild]
  /// [MultiChildRenderObjectElement.update]
  @override
  List<Element> updateChildren(
      List<Element> oldChildren, List<Widget> newWidgets,
      {Set<Element>? forgottenChildren, List<Object?>? slots}) {
    //debugger();
    return super.updateChildren(
      oldChildren,
      newWidgets,
      forgottenChildren: forgottenChildren,
      slots: slots,
    );
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  /// 执行顺序: 1
  /// [Element.mount]↓
  /// [Element.updateChild]↓
  /// [Element.inflateWidget]↓
  /// [Element.mount]↓
  ///
  /// 并负责创建对应的[_renderObject].[RenderObjectWidget.createRenderObject]
  ///
  /// [parent] 父元素
  /// [newSlot] null
  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final childrenWidget = _childrenWidget;
    final List<Element> children =
        List<Element>.filled(childrenWidget.length, _NullElement.instance);
    Element? previousChild;
    for (int i = 0; i < children.length; i += 1) {
      final Element newChild = inflateWidget(
          childrenWidget[i], IndexedSlot<Element?>(i, previousChild));
      children[i] = newChild;
      previousChild = newChild;
    }
    _children = children;
    renderObject._conditionCallback = _rebuildWithCondition;
    renderObject.updateCallback(_rebuildWithConstraints);
  }

  /// [update]->[updateChild]->[updateChildren]
  @override
  void update(covariant BaseDynamicMultiConstrainedLayoutBuilder newWidget) {
    //debugger();
    super.update(newWidget);
    final childrenWidget = _childrenWidget;
    assert(widget == newWidget);
    assert(!debugChildrenHaveDuplicateKeys(widget, childrenWidget));
    _updateElement(childrenWidget);
  }

  /// 当有新的[Widget]动态添加或移除时, 更新[Element]
  void _updateElement(List<Widget> childrenWidget) {
    _children = updateChildren(
      _children,
      childrenWidget,
      forgottenChildren: _forgottenChildren,
    );
    _forgottenChildren.clear();
    renderObject._conditionCallback = _rebuildWithCondition;
    renderObject.updateCallback(_rebuildWithConstraints);
  }

  /// [Element.reassemble] 热加载时, 会触发此方法
  @override
  void markNeedsBuild() {
    //debugger();
    super.markNeedsBuild();
    //debugger();
    renderObject.markNeedsLayout();
    _needsBuild = true;
  }

  /// [BuildOwner.buildScope]↓
  /// [BuildScope.buildScope]↓
  /// [BuildScope._tryRebuild]↓
  /// [Element.rebuild]↓
  /// [Element.performRebuild]↓
  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.

    // Force the callback to be called, even if the layout constraints are the
    // same. This is because that callback may depend on the updated widget
    // configuration, or an inherited widget.
    renderObject.markNeedsLayout();
    _needsBuild = true;
    super
        .performRebuild(); // Calls widget.updateRenderObject (a no-op in this case).
  }

  /// [Element.unmount]↓ 卸载
  /// [RenderObjectWidget.didUnmountRenderObject]
  /// [RenderObject.dispose]
  @override
  void unmount() {
    isFirstMount = true;
    renderObject._conditionCallback = null;
    renderObject.updateCallback(null);
    super.unmount();
  }

  /// 使用新的条件, 重新构建child
  void _rebuildWithCondition(Condition? condition) {
    if (_condition == condition) {
      l.v("条件未发生变化, 不需要重新构建child");
      return;
    }
    _condition = condition;
    markNeedsBuild();
  }

  // The constraints that were passed to this class last time it was laid out.
  // These constraints are compared to the new constraints to determine whether
  // [ConstrainedLayoutBuilder.builder] needs to be called.
  ConstraintType? _previousConstraints;
  bool _needsBuild = true;

  /// [RenderObject.invokeLayoutCallback]
  /// [DynamicRenderLayoutBuilder.performLayout]
  void _rebuildWithConstraints(ConstraintType constraints) {
    @pragma('vm:notify-debugger-on-exception')
    void updateChildCallback() {
      Widget? built;
      try {
        final dynamicWidget = (widget
            as DynamicConstrainedLayoutBuilderMixin<ConstraintType, Condition>);
        built = dynamicWidget.builder?.call(this, constraints,
            isFirstMount ? dynamicWidget.initCondition : _condition);
        _childWidget = built;
        if (isFirstMount) {
          _condition = dynamicWidget.initCondition;
        }
        isFirstMount = false;
        //debugWidgetBuilderValue(widget, built);
      } catch (e, stack) {
        built = ErrorWidget.builder(
          reportException(
            ErrorDescription('building $widget'),
            e,
            stack,
            informationCollector: () => <DiagnosticsNode>[
              if (kDebugMode) DiagnosticsDebugCreator(DebugCreator(this)),
            ],
          ),
        );
      }
      try {
        _updateElement(_childrenWidget);
        //debugger();
        //_children.remove(_child);
        // _child = updateChild(_child, built,
        //     IndexedSlot<Element?>(_children.length, _children.lastOrNull));
        /*if (_child != null) {
          _children.add(_child!);
        }*/
        /*if (built != null) {
          debugger();
            _child = updateChild(_child, built, null);
          //forgetChild(child)
          _children.remove(_child);
          _child = inflateWidget(built,
              IndexedSlot<Element?>(_children.length, _children.lastOrNull));
          if (_child != null) {
            _children.add(_child!);
          }
        }*/
        //assert(_child != null);
      } catch (e, stack) {
        built = ErrorWidget.builder(
          reportException(
            ErrorDescription('building $widget'),
            e,
            stack,
            informationCollector: () => <DiagnosticsNode>[
              if (kDebugMode) DiagnosticsDebugCreator(DebugCreator(this)),
            ],
          ),
        );
        //_child = updateChild(null, built, slot);
      } finally {
        _needsBuild = false;
        _previousConstraints = constraints;
      }
    }

    final VoidCallback? callback =
        _needsBuild || (constraints != _previousConstraints)
            ? updateChildCallback
            : null;
    owner!.buildScope(this, callback);
  }
}

//--

class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}

//endregion ---基础代码---

//endregion ---可直接使用的widget--

/// [MultiChildRenderObjectWidget]
class DynamicContainerLayoutBuilder
    extends BaseDynamicMultiConstrainedLayoutBuilder<BoxConstraints, dynamic,
        StackParentData> {
  const DynamicContainerLayoutBuilder({
    super.key,
    super.children,
    super.builder,
    super.initCondition,
  });

  @override
  DynamicContainerRenderLayoutBuilder createRenderObject(
          BuildContext context) =>
      DynamicContainerRenderLayoutBuilder();
}

class DynamicContainerRenderLayoutBuilder extends RenderStack
    with
        DynamicRenderConstrainedLayoutBuilderMixin<BoxConstraints, RenderBox,
            dynamic> {
  DynamicContainerRenderLayoutBuilder({
    super.children,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection = TextDirection.ltr,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
  });

  /// [RenderObject.layout]↓
  /// [RenderObject.performLayout]↓
  @override
  void performLayout() {
    rebuildIfNecessary();
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //final count = childCount;
    //debugger();
    context.canvas.drawRect(
        offset & size.ensureValid(height: 100),
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black38);
    super.paint(context, offset);

    if (lastChild != null) {
      context.paintChild(lastChild!, offset);

      context.canvas.drawRect(
          offset & lastChild!.size,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.red);
    }
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    rebuildWithCondition(event.localPosition);
  }
}

//endregion ---可直接使用的widget--
