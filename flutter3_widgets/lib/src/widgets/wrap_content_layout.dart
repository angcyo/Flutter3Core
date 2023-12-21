part of flutter3_widgets;

///
/// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/20
///

class WrapContentLayout extends SingleChildRenderObjectWidget {
  /// 对齐方式
  final AlignmentDirectional alignment;

  /// 指定最小的宽度, 不指定则使用[child]的宽度
  /// [BoxConstraints.minWidth]
  final double? minWidth;
  final double? minHeight;

  const WrapContentLayout({
    super.key,
    super.child,
    this.alignment = AlignmentDirectional.center,
    this.minWidth,
    this.minHeight,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => WrapContentBox(
        alignment: alignment,
        textDirection: Directionality.of(context),
        minWidth: minWidth,
        minHeight: minHeight,
      );

  @override
  void updateRenderObject(BuildContext context, WrapContentBox renderObject) {
    renderObject
      ..alignment = alignment
      ..minWidth = minWidth
      ..minHeight = minHeight
      ..markNeedsLayout();
  }
}

/// [rebuild]->[performRebuild]->[updateChild]->[inflateWidget]->
/// [mount]->[attachRenderObject]->[insertRenderObjectChild].(renderObject.child = child;)
/// [RenderObjectWithChildMixin.child]
/// 要自己实现位置偏移需要考虑, 绘制时的偏移和点击事件的偏移
/// [RenderShiftedBox.paint]实现绘制上的偏移
/// [RenderShiftedBox.hitTestChildren]实现点击事件的偏移
class WrapContentBox extends RenderAligningShiftedBox {
  double? minWidth;
  double? minHeight;

  WrapContentBox({
    super.alignment,
    super.textDirection,
    this.minWidth,
    this.minHeight,
  });

  @override
  bool get sizedByParent => super.sizedByParent;

  /// [sizedByParent] 为true时, 才会调用此方法
  @override
  void performResize() {
    super.performResize();
  }

  /// [ParentData]只是用来存储测量数据的, 没有逻辑
  /// [RenderBox.setupParentData]
  /// [BoxParentData]
  ///
  /// [RenderProxyBoxMixin.setupParentData]
  @override
  void setupParentData(covariant RenderObject child) {
    //这里不能调用super, 因为会在[RenderProxyBoxMixin.setupParentData]中重置为[ParentData]
    //var parentData = child.parentData;
    //debugger();
    super.setupParentData(child);
    /*if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }*/
  }

  /// [performResize]中触发此方法
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return super.computeDryLayout(constraints);
  }

  /// 最终还是会调用 [computeDryLayout]
  @override
  Size getDryLayout(BoxConstraints constraints) {
    return super.getDryLayout(constraints);
  }

  /// 对齐子元素, 通过修改[child!.parentData]这样的方式手势碰撞就会自动计算
  void _alignChild() {
    if (child != null) {
      var dx = 0.0;
      var dy = 0.0;
      switch (alignment) {
        case AlignmentDirectional.topStart:
        case AlignmentDirectional.centerStart:
        case AlignmentDirectional.bottomStart:
          dx = 0;
          break;
        case AlignmentDirectional.topCenter:
        case AlignmentDirectional.center:
        case AlignmentDirectional.bottomCenter:
          dx = (size.width - child!.size.width) / 2;
          break;
        case AlignmentDirectional.topEnd:
        case AlignmentDirectional.centerEnd:
        case AlignmentDirectional.bottomEnd:
          dx = size.width - child!.size.width;
          break;
      }
      switch (alignment) {
        case AlignmentDirectional.topStart:
        case AlignmentDirectional.topCenter:
        case AlignmentDirectional.topEnd:
          dy = 0;
          break;
        case AlignmentDirectional.centerStart:
        case AlignmentDirectional.center:
        case AlignmentDirectional.centerEnd:
          dy = (size.height - child!.size.height) / 2;
          break;
        case AlignmentDirectional.bottomStart:
        case AlignmentDirectional.bottomCenter:
        case AlignmentDirectional.bottomEnd:
          dy = size.height - child!.size.height;
          break;
      }
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      //debugger();
      childParentData.offset = Offset(dx, dy);
    }
  }

  @override
  void performLayout() {
    //debugger();
    if (child == null) {
      size = constraints.smallest;
    } else {
      //在可以滚动的布局中, maxWidth和maxHeight会是无限大
      final p = parent;
      final parentConstraints = p?.constraints;
      double parentMaxWidth = double.infinity;
      double parentMaxHeight = double.infinity;
      if (p is RenderBox && p.hasSize) {
        parentMaxWidth = p.size.width;
        parentMaxHeight = p.size.height;
      } else if (parentConstraints is BoxConstraints) {
        parentMaxWidth = parentConstraints.maxWidth;
        parentMaxHeight = parentConstraints.maxHeight;
      }
      //debugger();
      child!.layout(
        BoxConstraints(
          minWidth: minWidth ?? 0,
          minHeight: minHeight ?? 0,
          maxWidth: constraints.maxWidth == double.infinity
              ? parentMaxWidth
              : constraints.maxWidth,
          maxHeight: constraints.maxHeight == double.infinity
              ? parentMaxHeight
              : constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      size = constraints.constrain(child!.size);
      _alignChild();
    }
  }

  /// 由[paint]调用
  @override
  bool paintsChild(covariant RenderObject child) {
    return super.paintsChild(child);
  }

  /// 最终调用[paintsChild]
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}

extension WrapContentLayoutEx on Widget {
  /// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
  WrapContentLayout wrapContent({
    AlignmentDirectional alignment = AlignmentDirectional.center,
    double? minWidth,
    double? minHeight,
  }) =>
      WrapContentLayout(
        alignment: alignment,
        minWidth: minWidth,
        minHeight: minHeight,
        child: this,
      );
}
