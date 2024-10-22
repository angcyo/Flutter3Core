part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/22
///
/// 动态布局构建器, 类似于[LayoutBuilder], 但是可以添加一些自定义的条件
///

//region ---基础代码---

/// 来自[LayoutWidgetBuilder]
@fromFramework
typedef DynamicLayoutWidgetBuilder<Condition> = Widget? Function(
  BuildContext context,
  BoxConstraints constraints,
  Condition? condition,
);

/// 来自[LayoutCallback]
typedef ConditionLayoutCallback<Condition> = void Function(
    Condition? condition);

/// 混入
mixin DynamicConstrainedLayoutBuilderMixin<ConstraintType extends Constraints,
    Condition> on RenderObjectWidget {
  /// 动态构建布局的回调
  Widget? Function(BuildContext context, ConstraintType constraints,
      Condition? condition)? get builder;

  /// 初始化时的条件, 只在首次[Element.mount]时有效
  Condition? get initCondition;
}

/// 来自[ConstrainedLayoutBuilder]
@fromFramework
abstract class BaseDynamicConstrainedLayoutBuilder<
        ConstraintType extends Constraints,
        Condition> extends RenderObjectWidget
    with DynamicConstrainedLayoutBuilderMixin<ConstraintType, Condition> {
  const BaseDynamicConstrainedLayoutBuilder({
    super.key,
    this.builder,
    this.initCondition,
  });

  /// 动态构建布局的回调
  @override
  final Widget? Function(BuildContext context, ConstraintType constraints,
      Condition? condition)? builder;

  /// 初始化时的条件, 只在首次[Element.mount]时有效
  @override
  final Condition? initCondition;

  @override
  RenderObjectElement createElement() =>
      _DynamicLayoutBuilderElement<ConstraintType, Condition>(this);

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

/// 来自[_LayoutBuilderElement]
@fromFramework
class _DynamicLayoutBuilderElement<ConstraintType extends Constraints,
    Condition> extends RenderObjectElement {
  _DynamicLayoutBuilderElement(
      DynamicConstrainedLayoutBuilderMixin<ConstraintType, Condition>
          super.widget);

  /// 这里需要[RenderObject.invokeLayoutCallback]方法
  @override
  DynamicRenderConstrainedLayoutBuilderMixin<ConstraintType, RenderObject,
          Condition>
      get renderObject =>
          super.renderObject as DynamicRenderConstrainedLayoutBuilderMixin<
              ConstraintType, RenderObject, Condition>;

  /// 当前动态创建的child
  Element? _child;

  /// 当前的条件
  Condition? _condition;

  /// 是否是首次安装
  bool isFirstMount = true;

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

  /// [Hero._allHeroesFor]
  /// [Element.visitChildren]
  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }

  @override
  void forgetChild(Element child) {
    debugger();
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
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
    super.mount(parent, newSlot); // Creates the renderObject.
    renderObject._conditionCallback = _rebuildWithCondition;
    renderObject.updateCallback(_rebuildWithConstraints);
  }

  /// 当更新[Widget]后, 触发
  /// [Element.performRebuild]↓
  /// [Element.updateChildren]↓
  /// [Element.updateChild]↓
  /// [Element.update]↓
  @override
  void update(
      BaseDynamicConstrainedLayoutBuilder<ConstraintType, Condition>
          newWidget) {
    debugger();
    assert(widget != newWidget);
    final BaseDynamicConstrainedLayoutBuilder<ConstraintType, Condition>
        oldWidget = widget
            as BaseDynamicConstrainedLayoutBuilder<ConstraintType, Condition>;
    super.update(newWidget);
    assert(widget == newWidget);

    renderObject._conditionCallback = _rebuildWithCondition;
    renderObject.updateCallback(_rebuildWithConstraints);
    if (newWidget.updateShouldRebuild(oldWidget)) {
      _needsBuild = true;
      renderObject.markNeedsLayout();
    }
  }

  /// [Element.reassemble] 热加载时, 会触发此方法
  @override
  void markNeedsBuild() {
    super.markNeedsBuild();
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
            as BaseDynamicConstrainedLayoutBuilder<ConstraintType, Condition>);
        built = dynamicWidget.builder?.call(this, constraints,
            isFirstMount ? dynamicWidget.initCondition : _condition);
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
        _child = updateChild(_child, built, null);
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
        _child = updateChild(null, built, slot);
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

  /// 当有child 被插入到当前元素中时, 会调用此方法, 自身的[RenderObject]不算
  /// [RenderObjectElement.mount]↓
  /// [RenderObjectElement.attachRenderObject]↓
  /// [RenderObjectElement.insertRenderObjectChild]↓
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    //debugger();
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(
      RenderObject child, Object? oldSlot, Object? newSlot) {
    debugger();
    assert(false);
  }

  /// 当[insertRenderObjectChild]插入的child需要移除时触发
  /// [Element.updateChild]↓
  /// [Element.deactivateChild]↓
  /// [Element.detachRenderObject]↓
  /// [Element.visitChildren]↓
  /// [Element.removeRenderObjectChild]↓
  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    //debugger();
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

/// 来自[RenderConstrainedLayoutBuilder]
/// [RenderObjectWithChildMixin] 单个child
/// [ContainerRenderObjectMixin] 多个child
@fromFramework
mixin DynamicRenderConstrainedLayoutBuilderMixin<
    ConstraintType extends Constraints,
    ChildType extends RenderObject,
    Condition> on RenderObject {
  LayoutCallback<ConstraintType>? _callback;
  ConditionLayoutCallback<Condition>? _conditionCallback;

  void updateCallback(LayoutCallback<ConstraintType>? value) {
    if (value == _callback) {
      return;
    }
    _callback = value;
    markNeedsLayout();
  }

  void rebuildIfNecessary() {
    if (_callback != null) {
      invokeLayoutCallback(_callback!);
    }
  }

  /// 使用新的[condition]条件重新构建
  void rebuildWithCondition(Condition? condition) {
    _conditionCallback?.call(condition);
  }
}

/// 来自[_reportException]
@fromFramework
FlutterErrorDetails reportException(
  DiagnosticsNode context,
  Object exception,
  StackTrace stack, {
  InformationCollector? informationCollector,
}) {
  final FlutterErrorDetails details = FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'angcyo widgets library',
    context: context,
    informationCollector: informationCollector,
  );
  FlutterError.reportError(details);
  return details;
}

//endregion ---基础代码---

//region ---可直接使用的widget---

/// [BaseDynamicConstrainedLayoutBuilder]的一种实现
class DynamicLayoutBuilder
    extends BaseDynamicConstrainedLayoutBuilder<BoxConstraints, dynamic> {
  const DynamicLayoutBuilder({
    super.key,
    super.builder,
    super.initCondition,
  });

  @override
  DynamicRenderLayoutBuilder createRenderObject(BuildContext context) =>
      DynamicRenderLayoutBuilder();
}

/// 来自[_RenderLayoutBuilder]
@fromFramework
class DynamicRenderLayoutBuilder extends RenderBox
    with
        RenderObjectWithChildMixin<RenderBox>,
        DynamicRenderConstrainedLayoutBuilderMixin<BoxConstraints, RenderBox,
            dynamic> {
  @override
  double computeMinIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0.0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    assert(debugCannotComputeDryLayout(
      reason:
          'Calculating the dry layout would require running the layout callback '
          'speculatively, which might mutate the live render object tree.',
    ));
    return Size.zero;
  }

  @override
  double? computeDryBaseline(
      BoxConstraints constraints, TextBaseline baseline) {
    assert(debugCannotComputeDryLayout(
      reason:
          'Calculating the dry baseline would require running the layout callback '
          'speculatively, which might mutate the live render object tree.',
    ));
    return null;
  }

  /// [RenderObject.layout]↓
  /// [RenderObject.performLayout]↓
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    rebuildIfNecessary();
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints.biggest;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return child?.getDistanceToActualBaseline(baseline) ??
        super.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child?.hitTest(result, position: position) ?? false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
        offset & size.ensureValid(height: 100),
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black38);
    if (child != null) {
      context.paintChild(child!, offset);

      context.canvas.drawRect(
          offset & child!.size,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.red);
    }
  }

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw FlutterError(
          'LayoutBuilder does not support returning intrinsic dimensions.\n'
          'Calculating the intrinsic dimensions would require running the layout '
          'callback speculatively, which might mutate the live render object tree.',
        );
      }
      return true;
    }());

    return true;
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
