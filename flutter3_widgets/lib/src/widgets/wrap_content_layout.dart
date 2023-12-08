part of flutter3_widgets;

///
/// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/20
///

class WrapContentLayout extends SingleChildRenderObjectWidget {
  final AlignmentDirectional alignment;

  const WrapContentLayout({
    super.key,
    super.child,
    this.alignment = AlignmentDirectional.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => WrapContentBox(
        alignment: alignment,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, WrapContentBox renderObject) {
    renderObject
      ..alignment = alignment
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
  WrapContentBox({
    super.alignment,
    super.textDirection,
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
      child!.layout(
        BoxConstraints(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
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
  WrapContentLayout wrapContent([
    AlignmentDirectional alignment = AlignmentDirectional.center,
  ]) =>
      WrapContentLayout(
        alignment: alignment,
        child: this,
      );
}
