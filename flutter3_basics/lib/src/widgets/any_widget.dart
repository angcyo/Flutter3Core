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

/// 计算布局大小
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

mixin AnyWidgetMixin<Data> {
  /// 初始化时的数据
  Data? get initData;

  /// 初始化的回调
  AnyWidgetInitAction<Data>? get onInit;

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
  void performLayout() {
    super.performLayout();
    final layoutSize =
        widget?.anyWidget?.onLayout?.call(constraints, widget?.initResult);
    size = layoutSize ?? constraints.biggest;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
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

class AnyStatefulWidget<Data> extends StatefulWidget with AnyWidgetMixin<Data> {
  const AnyStatefulWidget({
    super.key,
    this.child,
    this.initData,
    this.onInit,
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
    () async {
      final result = await widget.onInit?.call(buildContext, widget.initData);
      if (mounted) {
        if (initResult != result) {
          initResult = result;
          updateState();
        }
      }
    }();
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
  Widget? child,
  Data? initData,
  AnyWidgetInitAction<Data>? onInit,
  AnyWidgetLayoutAction? onLayout,
  AnyWidgetPaintAction? onPaint,
}) =>
    AnyStatefulWidget(
      key: key,
      child: child,
      initData: initData,
      onInit: onInit,
      onLayout: onLayout,
      onPaint: onPaint,
    );
