part of flutter3_widgets;

///
/// 用最大的约束约束child
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [WrapContentLayout]
class MatchParentLayout extends SingleChildRenderObjectWidget {

  /// 对齐方式
  final AlignmentDirectional alignment;

  /// 是否撑满宽度
  final bool matchWidth;

  /// 是否撑满高度
  final bool matchHeight;

  const MatchParentLayout({
    super.key,
    super.child,
    this.matchWidth = true,
    this.matchHeight = true,
    this.alignment = AlignmentDirectional.center,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MatchParentBox(
        alignment: alignment,
        matchHeight: matchHeight,
        matchWidth: matchWidth,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, MatchParentBox renderObject) {
    renderObject
      ..alignment = alignment
      ..matchWidth = matchWidth
      ..matchHeight = matchHeight
      ..markNeedsLayout();
  }
}

/// [WrapContentBox]
class MatchParentBox extends WrapContentBox {
  /// 是否撑满宽度
  bool matchWidth;

  /// 是否撑满高度
  bool matchHeight;

  MatchParentBox({
    super.alignment,
    super.textDirection,
    this.matchWidth = true,
    this.matchHeight = true,
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
          minWidth: matchWidth ? constraints.maxWidth : constraints.minWidth,
          minHeight:
              matchHeight ? constraints.maxHeight : constraints.minHeight,
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
  MatchParentLayout matchParent({
    bool matchWidth = true,
    bool matchHeight = true,
    AlignmentDirectional alignment = AlignmentDirectional.center,
  }) =>
      MatchParentLayout(
        alignment: alignment,
        matchWidth: matchWidth,
        matchHeight: matchHeight,
        child: this,
      );
}
