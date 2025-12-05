part of '../../../flutter3_widgets.dart';

///
/// 用最大的约束约束child
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [WrapContentLayout]
class MatchParentLayout extends SingleChildRenderObjectWidget {
  /// [child]在容器中的对齐方式
  final AlignmentDirectional alignment;

  /// 自身和[child]是否都撑满宽度
  final bool matchWidth;

  /// 自身和[child]是否都撑满高度
  final bool matchHeight;

  /// [child]是否优先使用自身的宽度, 超过之后再使用约束的宽度
  final bool? childWrapWidth;

  /// [child]是否优先使用自身的高度, 超过之后再使用约束的高度
  final bool? childWrapHeight;

  /// 调试标签
  final String? debugLabel;

  const MatchParentLayout({
    super.key,
    super.child,
    this.matchWidth = true,
    this.matchHeight = true,
    this.alignment = AlignmentDirectional.center,
    this.childWrapWidth,
    this.childWrapHeight,
    this.debugLabel,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MatchParentBox(
    alignment: alignment,
    matchWidth: matchWidth,
    matchHeight: matchHeight,
    childWrapWidth: childWrapWidth,
    childWrapHeight: childWrapHeight,
    debugLabel: debugLabel,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(BuildContext context, MatchParentBox renderObject) {
    renderObject
      ..alignment = alignment
      ..matchWidth = matchWidth
      ..matchHeight = matchHeight
      ..childWrapWidth = childWrapWidth
      ..childWrapHeight = childWrapHeight
      ..debugLabel = debugLabel
      ..markNeedsLayout();
  }
}

/// [WrapContentBox]
class MatchParentBox extends WrapContentBox {
  /// 自身和[child]是否都撑满宽度
  bool matchWidth;

  /// 自身和[child]是否都撑满高度
  bool matchHeight;

  /// [child]是否优先使用自身的宽度, 超过之后再使用约束的宽度
  bool? childWrapWidth;

  /// [child]是否优先使用自身的高度, 超过之后再使用约束的高度
  bool? childWrapHeight;

  /// 调试标签
  String? debugLabel;

  MatchParentBox({
    super.alignment,
    super.textDirection,
    this.matchWidth = true,
    this.matchHeight = true,
    this.childWrapWidth,
    this.childWrapHeight,
    this.debugLabel,
  });

  @override
  void performLayout() {
    debugger(when: debugLabel != null);
    BoxConstraints constraints = this.constraints;
    BoxConstraints? parentConstraints = parentBoxConstraints;
    if (constraints.isUnconstrained) {
      constraints = parentConstraints ?? constraints;
    }
    if (child == null) {
      size = constraints.smallest;
    } else {
      //在可以滚动的布局中, maxWidth和maxHeight会是无限大
      final childConstraints = BoxConstraints(
        minWidth: matchWidth
            ? constraints.maxWidth.ensureValid(
                constraints.minWidth.ensureValid(0),
              )
            : constraints.minWidth,
        minHeight: matchHeight
            ? constraints.maxHeight.ensureValid(
                constraints.minHeight
                    .ensureValid(0)
                    .maxOf(parentConstraints?.minHeight ?? 0),
              )
            : constraints.minHeight,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      );
      if (childWrapWidth == true || childWrapHeight == true) {
        //优先使用子节点自身的宽高, 超过后再使用约束的宽高
        child!.layout(BoxConstraints(), parentUsesSize: true);
        final childSize = child!.size;
        debugger(when: debugLabel != null);
        if (constraints.isConstraintsSize(childSize)) {
          size = childConstraints.constrain(childSize);
          _alignChild();
          return;
        }
      }
      //final parentConstraints = parent?.constraints;
      //debugger();
      child!.layout(childConstraints, parentUsesSize: true);
      //debugger(when: debugLabel != null);
      size = constraints.constrain(child!.size);
      _alignChild();
    }
  }
}

extension MatchParentLayoutEx on Widget {
  /// [matchBoth] 同时设置2个值
  /// [WrapContentLayoutEx.wrapContent]
  /// [MatchParentLayoutEx.matchParent]
  Widget matchParent({
    bool? matchBoth,
    bool matchWidth = true,
    bool matchHeight = true,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    bool? childWrapWidth,
    bool? childWrapHeight,
    String? debugLabel,
  }) => MatchParentLayout(
    alignment: alignment,
    matchWidth: matchBoth ?? matchWidth,
    matchHeight: matchBoth ?? matchHeight,
    childWrapWidth: childWrapWidth,
    childWrapHeight: childWrapHeight,
    debugLabel: debugLabel,
    child: this,
  );

  /// [matchParent]
  /// [matchParentWidth]
  /// [matchParentHeight]
  Widget matchParentWidth({
    bool matchWidth = true,
    bool matchHeight = false,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    bool? childWrapWidth,
    bool? childWrapHeight,
    String? debugLabel,
  }) => matchParent(
    matchWidth: matchWidth,
    matchHeight: matchHeight,
    alignment: alignment,
    childWrapWidth: childWrapWidth,
    childWrapHeight: childWrapHeight,
    debugLabel: debugLabel,
  );

  /// [matchParent]
  /// [matchParentWidth]
  /// [matchParentHeight]
  Widget matchParentHeight({
    bool enable = true,
    bool matchWidth = false,
    bool matchHeight = true,
    AlignmentDirectional alignment = AlignmentDirectional.center,
    bool? childWrapWidth,
    bool? childWrapHeight,
    String? debugLabel,
  }) => !enable
      ? this
      : matchParent(
          matchWidth: matchWidth,
          matchHeight: matchHeight,
          alignment: alignment,
          childWrapWidth: childWrapWidth,
          childWrapHeight: childWrapHeight,
          debugLabel: debugLabel,
        );
}
