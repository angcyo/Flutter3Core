part of flutter3_widgets;

///
/// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/20
///

class WrapContentLayout extends SingleChildRenderObjectWidget {
  const WrapContentLayout({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => WrapContentBox();
}

/// [rebuild]->[performRebuild]->[updateChild]->[inflateWidget]->
/// [mount]->[attachRenderObject]->[insertRenderObjectChild].(renderObject.child = child;)
/// [RenderObjectWithChildMixin.child]
class WrapContentBox extends RenderProxyBox {
  WrapContentBox();

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
    super.paint(context, offset);
  }
}

extension WrapContentLayoutEx on Widget {
  /// 用最小的约束包裹住child, 用自身的约束限制child的最大宽高
  WrapContentLayout wrapContent() => WrapContentLayout(child: this);
}
