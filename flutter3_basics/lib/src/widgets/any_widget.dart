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
typedef AnyWidgetOffsetAction = Offset Function(
    BoxConstraints constraints, Size parentSize, Size childSize);

/// 计算布局大小
/// [AnyStatefulWidget]
/// [_AnyRenderObject.performLayout]
typedef AnyWidgetLayoutAction = Size Function(
    BoxConstraints constraints, dynamic initResult);

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

  /// 初始化的回调
  AnyWidgetInitAction<Data>? get onInit;

  /// 计算child的偏移
  AnyWidgetOffsetAction? get onGetChildOffset;

  /// 计算布局大小的回调
  AnyWidgetLayoutAction? get onLayout;

  /// 绘制回调
  AnyWidgetPaintAction? get onPaint;
}

/// 代理回调[RenderBox]
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
      _AnyRenderObject(this);

  @override
  void updateRenderObject(BuildContext context, _AnyRenderObject renderObject) {
    renderObject
      ..widget = this
      ..markNeedsLayout();
  }
}

class _AnyRenderObject extends RenderProxyBox {
  _AnyRenderObjectWidget? widget;

  _AnyRenderObject(this.widget);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void performLayout() {
    final layoutSize =
        widget?.anyWidget?.onLayout?.call(constraints, widget?.initResult);
    size = layoutSize == null
        ? constraints.biggest
        : constraints.constrain(layoutSize);

    final child = this.child;
    if (child != null) {
      //debugger();
      child.layout(BoxConstraints(maxWidth: size.width, maxHeight: size.height),
          parentUsesSize: true);
      final parentData = child.parentData;
      if (parentData is BoxParentData) {
        final offset = widget?.anyWidget?.onGetChildOffset
            ?.call(constraints, size, child.size);
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
    final RenderBox? child = this.child;
    if (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final childParentData = child.parentData! as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final RenderBox? child = this.child;
    if (child != null) {
      final childParentData = child.parentData! as BoxParentData;
      context.paintChild(child, childParentData.offset + offset);
    }

    final onPaint = widget?.anyWidget?.onPaint;
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

//--

/// 回调一些布局绘制关键方法给外部
/// [CustomSingleChildLayout]
class AnyStatefulWidget<Data> extends StatefulWidget with AnyWidgetMixin<Data> {
  const AnyStatefulWidget({
    super.key,
    this.child,
    this.initData,
    this.onInit,
    this.onGetChildOffset,
    this.onLayout,
    this.onPaint,
  });

  /// child
  final Widget? child;

  @override
  final Data? initData;

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
}) =>
    AnyStatefulWidget(
      key: key,
      initData: initData,
      onInit: onInit,
      onGetChildOffset: onGetChildOffset,
      onLayout: onLayout ?? (size == null ? null : (constraints, _) => size),
      onPaint: onPaint,
      child: child,
    );
