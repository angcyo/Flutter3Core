part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/10/22
///

/// 初始化的回调
/// [State.initState]
typedef AnyWidgetInitAction<Data> = FutureOr Function(
    BuildContext? context, Data? data);

/// 计算child的偏移
typedef AnyWidgetOffsetAction = Offset? Function(
  RenderBox render,
  BoxConstraints constraints,
  Size parentSize,
  Size childSize,
  AnyParentData childParentData,
);

/// 计算布局大小
/// [AnyStatefulWidget]
/// [_AnyRenderObject.performLayout]
typedef AnyWidgetLayoutAction = Size? Function(
  RenderBox render,
  BoxConstraints constraints,
  dynamic initResult,
);

/// 绘制回调
/// [_AnyRenderObject.paint]
typedef AnyWidgetPaintAction = void Function(
  RenderBox render,
  Canvas canvas,
  Size size,
);

/// [AnyStatefulWidget]
mixin AnyWidgetMixin<Data> {
  /// 初始化时的数据
  Data? get initData;

  /// 命中行为
  /// [HitTestBehavior.deferToChild]
  HitTestBehavior? get behavior;

  /// 初始化的回调
  AnyWidgetInitAction<Data>? get onInit;

  /// 计算child的偏移
  AnyWidgetOffsetAction? get onGetChildOffset;

  /// 计算布局大小的回调
  AnyWidgetLayoutAction? get onLayout;

  /// 绘制回调
  AnyWidgetPaintAction? get onPaint;
}

/// 支持一个`child`
/// 代理回调[RenderBox]
/// [AnyStatefulWidget]
class _AnyRenderObjectWidget extends SingleChildRenderObjectWidget {
  const _AnyRenderObjectWidget({
    super.key,
    super.child,
    this.anyWidget,
    this.initResult,
  });

  final AnyWidgetMixin? anyWidget;
  final dynamic initResult;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AnyRenderObject(this,
          behavior: anyWidget?.behavior ?? HitTestBehavior.deferToChild);

  @override
  void updateRenderObject(BuildContext context, _AnyRenderObject renderObject) {
    renderObject
      ..config = this
      ..behavior = anyWidget?.behavior ?? HitTestBehavior.deferToChild
      ..markNeedsLayout();
  }
}

/// [_AnyRenderObject]
/// [_AnyContainerRenderObject]
class _AnyRenderObject extends RenderProxyBoxWithHitTestBehavior {
  _AnyRenderObjectWidget? config;

  _AnyRenderObject(
    this.config, {
    super.behavior = HitTestBehavior.deferToChild,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! AnyParentData) {
      child.parentData = AnyParentData();
    }
  }

  @override
  void performLayout() {
    final layoutSize = config?.anyWidget?.onLayout
        ?.call(this, constraints, config?.initResult);
    size = layoutSize == null
        ? constraints.biggest
        : constraints.constrain(layoutSize);

    final child = this.child;
    if (child != null) {
      //debugger();
      child.layout(BoxConstraints(maxWidth: size.width, maxHeight: size.height),
          parentUsesSize: true);
      final parentData = child.parentData;
      if (parentData is AnyParentData) {
        final offset = config?.anyWidget?.onGetChildOffset
            ?.call(this, constraints, size, child.size, parentData);
        parentData.offset = offset ?? parentData.offset;
      }
    }
  }

  /// 在手势处理, 绘制涟漪效果时, 也会触发
  /// 在[RenderBox.globalToLocal]->[RenderObject.getTransformTo]中会触发
  /// 如果自身没有变换, 则不需要处理
  /// [RenderBox.applyPaintTransform]
  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    //debugger();
    /*final BoxParentData childParentData = child.parentData! as BoxParentData;
    final Offset offset = childParentData.offset;
    transform.translate(offset.dx, offset.dy);*/
    super.applyPaintTransform(child, transform);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required ui.Offset position}) {
    return defaultHitTestChild(result, child, position);
  }

  /// [RenderProxyBoxWithHitTestBehavior]
  @override
  bool hitTestSelf(ui.Offset position) {
    return super.hitTestSelf(position);
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    defaultPaintChild(context, offset, child);

    final onPaint = config?.anyWidget?.onPaint;
    if (onPaint != null) {
      final canvas = context.canvas;
      canvas.save();
      if (offset != Offset.zero) {
        canvas.translate(offset.dx, offset.dy);
      }
      onPaint(this, canvas, size);
      canvas.restore();
    }
  }
}

/// 支持多个`children`
class _AnyContainerRenderObjectWidget extends MultiChildRenderObjectWidget {
  const _AnyContainerRenderObjectWidget({
    super.key,
    super.children,
    this.anyWidget,
    this.initResult,
  });

  final AnyWidgetMixin? anyWidget;
  final dynamic initResult;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AnyContainerRenderObject(this);

  @override
  void updateRenderObject(
      BuildContext context, _AnyContainerRenderObject renderObject) {
    renderObject
      ..config = this
      ..markNeedsLayout();
  }
}

/// [_AnyRenderObject]
/// [_AnyContainerRenderObject]
class _AnyContainerRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AnyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AnyParentData> {
  _AnyContainerRenderObjectWidget? config;

  _AnyContainerRenderObject(this.config);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! AnyParentData) {
      child.parentData = AnyParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required ui.Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    //debugger();
    final layoutSize = config?.anyWidget?.onLayout
        ?.call(this, constraints, config?.initResult);
    size = layoutSize == null
        ? constraints.biggest
        : constraints.constrain(layoutSize);

    for (final child in childrenList) {
      //debugger();
      final parentData = child.parentData;
      if (parentData is AnyParentData) {
        //--
        if (parentData.isPositioned) {
          RenderStack.layoutPositionedChild(child, parentData, size,
              parentData.alignment ?? Alignment.topLeft);
        } else {
          child.layout(
              BoxConstraints(maxWidth: size.width, maxHeight: size.height),
              parentUsesSize: true);
          if (parentData.alignment != null) {
            alignChildOffset(parentData.alignment!, size, child: child);
          }
        }

        //--
        final offset = config?.anyWidget?.onGetChildOffset
            ?.call(this, constraints, size, child.size, parentData);
        parentData.offset = offset ?? parentData.offset;
      }
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as AnyParentData;
      if (childParentData.visible) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }

    final onPaint = config?.anyWidget?.onPaint;
    if (onPaint != null) {
      final canvas = context.canvas;
      canvas.save();
      if (offset != Offset.zero) {
        canvas.translate(offset.dx, offset.dy);
      }
      onPaint(this, canvas, size);
      canvas.restore();
    }
  }
}

/// [StackParentData]
/// [RenderStack.layoutPositionedChild]
class AnyParentData extends StackParentData {
  /// 自定义携带的数据
  Object? tag;

  /// 自身在容器中的定位
  Alignment? alignment;

  /// 是否可见, 不可见则不绘制
  bool visible = true;

  @override
  String toString() {
    return '${super.toString()} tag:$tag visible:$visible alignment:$alignment';
  }
}

/// 用来赋值给[RenderObject.parentData]
/// [ParentData]
///
class AnyParentDataWidget extends ParentDataWidget<AnyParentData> {
  //--

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double? width;
  final double? height;

  //--
  final Alignment? alignment;
  final Object? tag;
  final bool visible;

  const AnyParentDataWidget({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    //--
    this.tag,
    this.alignment,
    this.visible = true,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is AnyParentData);
    final AnyParentData parentData = renderObject.parentData! as AnyParentData;
    bool needsLayout = false;

    if (parentData.left != left) {
      parentData.left = left;
      needsLayout = true;
    }

    if (parentData.top != top) {
      parentData.top = top;
      needsLayout = true;
    }

    if (parentData.right != right) {
      parentData.right = right;
      needsLayout = true;
    }

    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsLayout = true;
    }

    if (parentData.width != width) {
      parentData.width = width;
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;
      needsLayout = true;
    }

    if (parentData.alignment != alignment) {
      parentData.alignment = alignment;
      needsLayout = true;
    }

    if (parentData.tag != tag) {
      parentData.tag = tag;
      needsLayout = true;
    }

    if (parentData.visible != visible) {
      parentData.visible = visible;
      needsLayout = true;
    }

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => AnyWidgetMixin;
}

/// [AnyParentDataWidget]
/// [AnyParentData]
extension AnyParentDataEx on Widget {
  Widget anyParentData({
    double? top,
    double? right,
    double? bottom,
    double? left,
    double? width,
    double? height,
    //--
    Alignment? alignment,
    Object? tag,
    bool visible = true,
  }) {
    return AnyParentDataWidget(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      width: width,
      height: height,
      alignment: alignment,
      tag: tag,
      visible: visible,
      child: this,
    );
  }
}

//--

/// 回调一些布局绘制关键方法给外部
/// [CustomSingleChildLayout]
///
/// [AnyStatefulWidget]
/// [AnyContainerStatefulWidget]
class AnyStatefulWidget<Data> extends StatefulWidget with AnyWidgetMixin<Data> {
  const AnyStatefulWidget({
    super.key,
    this.child,
    this.initData,
    this.onInit,
    this.onGetChildOffset,
    this.onLayout,
    this.onPaint,
    this.behavior = HitTestBehavior.deferToChild,
  });

  /// child
  final Widget? child;

  @override
  final Data? initData;

  @override
  final HitTestBehavior? behavior;

  @override
  final AnyWidgetInitAction<Data>? onInit;

  @override
  final AnyWidgetOffsetAction? onGetChildOffset;

  @override
  final AnyWidgetLayoutAction? onLayout;

  @override
  final AnyWidgetPaintAction? onPaint;

  @override
  State<AnyStatefulWidget> createState() => _AnyStatefulWidgetState();
}

class _AnyStatefulWidgetState extends State<AnyStatefulWidget> {
  /// 初始化回调返回的值的结果
  dynamic initResult;

  @override
  void initState() {
    final onInit = widget.onInit;
    if (onInit != null) {
      () async {
        final result = await onInit(buildContext, widget.initData);
        if (mounted) {
          if (initResult != result) {
            initResult = result;
            updateState();
          }
        }
      }();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _AnyRenderObjectWidget(
      anyWidget: widget,
      initResult: initResult,
      child: widget.child,
    );
  }
}

/// [AnyStatefulWidget]
Widget $any<Data>({
  Key? key,
  //--
  Widget? child,
  //--
  Size? size,
  //--
  Data? initData,
  AnyWidgetInitAction<Data>? onInit,
  AnyWidgetOffsetAction? onGetChildOffset,
  AnyWidgetLayoutAction? onLayout,
  AnyWidgetPaintAction? onPaint,
  HitTestBehavior? behavior = HitTestBehavior.deferToChild,
}) =>
    AnyStatefulWidget(
      key: key,
      initData: initData,
      onInit: onInit,
      onGetChildOffset: onGetChildOffset,
      onLayout:
          onLayout ?? (size == null ? null : (render, constraints, _) => size),
      onPaint: onPaint,
      behavior: behavior,
      child: child,
    );

//--

/// [AnyStatefulWidget]
/// [AnyContainerStatefulWidget]
class AnyContainerStatefulWidget<Data> extends StatefulWidget
    with AnyWidgetMixin<Data> {
  const AnyContainerStatefulWidget({
    super.key,
    this.children,
    this.initData,
    this.onInit,
    this.onGetChildOffset,
    this.onLayout,
    this.onPaint,
    this.behavior = HitTestBehavior.deferToChild,
  });

  /// children
  final List<Widget>? children;

  @override
  final Data? initData;

  @override
  final HitTestBehavior? behavior;

  @override
  final AnyWidgetInitAction<Data>? onInit;

  @override
  final AnyWidgetOffsetAction? onGetChildOffset;

  @override
  final AnyWidgetLayoutAction? onLayout;

  @override
  final AnyWidgetPaintAction? onPaint;

  @override
  State<AnyContainerStatefulWidget> createState() =>
      _AnyContainerStatefulWidgetState();
}

class _AnyContainerStatefulWidgetState
    extends State<AnyContainerStatefulWidget> {
  /// 初始化回调返回的值的结果
  dynamic initResult;

  @override
  void initState() {
    final onInit = widget.onInit;
    if (onInit != null) {
      () async {
        final result = await onInit(buildContext, widget.initData);
        if (mounted) {
          if (initResult != result) {
            initResult = result;
            updateState();
          }
        }
      }();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _AnyContainerRenderObjectWidget(
      anyWidget: widget,
      initResult: initResult,
      children: widget.children ?? [],
    );
  }
}

/// [AnyContainerStatefulWidget]
Widget $anyContainer<Data>({
  Key? key,
  //--
  List<Widget>? children,
  //--
  Size? size,
  //--
  Data? initData,
  AnyWidgetInitAction<Data>? onInit,
  AnyWidgetOffsetAction? onGetChildOffset,
  AnyWidgetLayoutAction? onLayout,
  AnyWidgetPaintAction? onPaint,
  HitTestBehavior? behavior = HitTestBehavior.deferToChild,
}) =>
    AnyContainerStatefulWidget(
      key: key,
      initData: initData,
      onInit: onInit,
      onGetChildOffset: onGetChildOffset,
      onLayout:
          onLayout ?? (size == null ? null : (render, constraints, _) => size),
      onPaint: onPaint,
      behavior: behavior,
      children: children,
    );
