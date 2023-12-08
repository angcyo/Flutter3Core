part of flutter3_widgets;

///
/// 用最大的约束约束child
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [WrapContentLayout]
class MatchParentLayout extends SingleChildRenderObjectWidget {
  final AlignmentDirectional alignment;

  const MatchParentLayout({
    super.key,
    super.child,
    this.alignment = AlignmentDirectional.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MatchParentBox(
        alignment: alignment,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, MatchParentBox renderObject) {
    renderObject
      ..alignment = alignment
      ..markNeedsLayout();
  }
}

/// [WrapContentBox]
class MatchParentBox extends WrapContentBox {
  MatchParentBox({
    super.alignment,
    super.textDirection,
  });

  @override
  void performLayout() {
    //debugger();
    if (child == null) {
      size = constraints.smallest;
    } else {
      //在可以滚动的布局中, maxWidth和maxHeight会是无限大
      child!.layout(
        BoxConstraints(
          minWidth: constraints.maxWidth,
          minHeight: constraints.maxHeight,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      size = constraints.constrain(child!.size);
      _alignChild();
    }
  }
}

extension MatchParentLayoutEx on Widget {
  /// [WrapContentLayoutEx.wrapContent]
  MatchParentLayout matchParent([
    AlignmentDirectional alignment = AlignmentDirectional.center,
  ]) =>
      MatchParentLayout(
        alignment: alignment,
        child: this,
      );
}
