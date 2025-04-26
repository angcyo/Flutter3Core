part of '../../../flutter3_widgets.dart';

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

  final String? debugLabel;

  const MatchParentLayout({
    super.key,
    super.child,
    this.matchWidth = true,
    this.matchHeight = true,
    this.alignment = AlignmentDirectional.center,
    this.debugLabel,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => MatchParentBox(
        alignment: alignment,
        matchHeight: matchHeight,
        matchWidth: matchWidth,
        debugLabel: debugLabel,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, MatchParentBox renderObject) {
    renderObject
      ..alignment = alignment
      ..matchWidth = matchWidth
      ..matchHeight = matchHeight
      ..debugLabel = debugLabel
      ..markNeedsLayout();
  }
}

/// [WrapContentBox]
class MatchParentBox extends WrapContentBox {
  /// 是否撑满宽度
  bool matchWidth;

  /// 是否撑满高度
  bool matchHeight;

  String? debugLabel;

  MatchParentBox({
    super.alignment,
    super.textDirection,
    this.matchWidth = true,
    this.matchHeight = true,
    this.debugLabel,
  });

  @override
  void performLayout() {
    //debugger(when: debugLabel != null);
    BoxConstraints constraints = this.constraints;
    BoxConstraints? parentConstraints = parentBoxConstraints;
    if (constraints.isUnconstrained) {
      constraints = parentConstraints ?? constraints;
    }
    if (child == null) {
      size = constraints.smallest;
    } else {
      //在可以滚动的布局中, maxWidth和maxHeight会是无限大
      final innerConstraints = BoxConstraints(
        minWidth: matchWidth
            ? constraints.maxWidth
                .ensureValid(constraints.minWidth.ensureValid(0))
            : constraints.minWidth,
        minHeight: matchHeight
            ? constraints.maxHeight.ensureValid(constraints.minHeight
                .ensureValid(0)
                .maxOf(parentConstraints?.minHeight ?? 0))
            : constraints.minHeight,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      );
      //final parentConstraints = parent?.constraints;
      //debugger();
      child!.layout(innerConstraints, parentUsesSize: true);
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
    String? debugLabel,
  }) =>
      MatchParentLayout(
        alignment: alignment,
        matchWidth: matchBoth ?? matchWidth,
        matchHeight: matchBoth ?? matchHeight,
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
  }) =>
      matchParent(
        matchWidth: matchWidth,
        matchHeight: matchHeight,
        alignment: alignment,
      );

  /// [matchParent]
  /// [matchParentWidth]
  /// [matchParentHeight]
  Widget matchParentHeight({
    bool matchWidth = false,
    bool matchHeight = true,
    AlignmentDirectional alignment = AlignmentDirectional.center,
  }) =>
      matchParent(
        matchWidth: matchWidth,
        matchHeight: matchHeight,
        alignment: alignment,
      );
}
