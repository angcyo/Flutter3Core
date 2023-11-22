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
  RenderObject createRenderObject(BuildContext context) =>
      WrapContentBox(alignment);

  @override
  void updateRenderObject(BuildContext context, WrapContentBox renderObject) {
    renderObject.alignment = alignment;
  }
}

/// [rebuild]->[performRebuild]->[updateChild]->[inflateWidget]->
/// [mount]->[attachRenderObject]->[insertRenderObjectChild].(renderObject.child = child;)
/// [RenderObjectWithChildMixin.child]
class WrapContentBox extends RenderProxyBox {
  /// 在有效空间内的对齐方式
  AlignmentDirectional alignment;

  WrapContentBox(this.alignment);

  @override
  bool get sizedByParent => super.sizedByParent;

  /// [sizedByParent] 为true时, 才会调用此方法
  @override
  void performResize() {
    super.performResize();
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

  @override
  void performLayout() {
    //debugger();
    if (child == null) {
      size = constraints.smallest;
    } else {
      child!.layout(
        BoxConstraints(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      size = constraints.constrain(child!.size);
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
    //alignment 对齐
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
      super.paint(context, offset + Offset(dx, dy));
    } else {
      super.paint(context, offset);
    }
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
