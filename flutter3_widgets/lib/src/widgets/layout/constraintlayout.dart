part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/08
///
/// 约束布局
///
/// - https://pub.dev/packages/flutter_constraintlayout
/// - https://github.com/hackware1993/Flutter_ConstraintLayout/blob/master/README_CN.md
/// 相对 id（这是为懒癌患者设计的，因为命名是个麻烦事。如果已经为子元素定义了 id，则不能再使用相对 id 来引用他们）
/// rId(3) 代表第三个子元素，以此类推
/// rId(-1) 代表最后一个子元素
/// rId(-2) 代表倒数第二个子元素，以此类推
///
/// sId(-1) 代表上一个兄弟元素，以此类推
/// sId(1) 代表下一个兄弟元素，以此类推
///
/// cId("xxx") 指定一个id
/// cId("canvas") 指定一个id
///
/// ```
/// @override
/// Widget build(BuildContext context) {
///   return constrainLayout(() {
///     "xxx".text().material().applyConstraint(
///           left: parent.left,
///           top: parent.top,
///           bottom: parent.bottom,
///           width: wrapContent,
///           height: matchConstraint,
///         );
///   });
/// }
/// ```

/// 快速使用一个约束布局
/// [cl_layout.ConstraintLayout]
/// [constrainLayout]
/// [cLayout]
/// [$cl]
Widget constrainLayout(void Function() block) =>
    cl_layout.ConstraintLayout().open(block);

/// [constrainLayout]
/// [cLayout]
/// [$cl]
Widget cLayout(void Function() block) => constrainLayout(block);

/// [constrainLayout]
/// [cLayout]
/// [$cl]
Widget $cl(void Function() block) => constrainLayout(block);

/// 约束扩展
extension ConstraintLayoutEx on Widget {
  /// 撑满父容器的约束
  Widget matchParentConstraint({
    //--
    double? width,
    double? height,
    //--
    cl_layout.ConstraintAlign? left,
    cl_layout.ConstraintAlign? top,
    cl_layout.ConstraintAlign? right,
    cl_layout.ConstraintAlign? bottom,
  }) =>
      applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        height: height ?? cl_layout.matchConstraint,
        //--
        left: left ?? cl_layout.parent.left,
        top: top ?? cl_layout.parent.top,
        right: right ?? cl_layout.parent.right,
        bottom: bottom ?? cl_layout.parent.bottom,
      );

  /// 对齐父容器左边的约束
  /// - 对齐父容器
  /// - 撑满对应的容器
  Widget alignParentConstraint({
    Alignment alignment = Alignment.centerLeft,
    //--
    double? width,
    double? height,
    //--
    cl_layout.ConstraintAlign? left,
    cl_layout.ConstraintAlign? top,
    cl_layout.ConstraintAlign? right,
    cl_layout.ConstraintAlign? bottom,
  }) {
    if (alignment == Alignment.centerLeft) {
      return applyConstraint(
        width: width ?? cl_layout.wrapContent,
        left: left ?? cl_layout.parent.left,
        right: right,
        top: top ?? cl_layout.parent.top,
        bottom: bottom ?? cl_layout.parent.bottom,
        height: height ?? cl_layout.matchConstraint,
      );
    } else if (alignment == Alignment.centerRight) {
      return applyConstraint(
        width: width ?? cl_layout.wrapContent,
        left: left,
        right: right ?? cl_layout.parent.right,
        top: top ?? cl_layout.parent.top,
        bottom: bottom ?? cl_layout.parent.bottom,
        height: height ?? cl_layout.matchConstraint,
      );
    } else if (alignment == Alignment.topCenter) {
      return applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        top: top ?? cl_layout.parent.top,
        bottom: bottom,
        left: left ?? cl_layout.parent.left,
        right: right ?? cl_layout.parent.right,
        height: height ?? cl_layout.wrapContent,
      );
    } else if (alignment == Alignment.bottomCenter) {
      return applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        bottom: bottom ?? cl_layout.parent.bottom,
        top: top,
        left: left ?? cl_layout.parent.left,
        right: right ?? cl_layout.parent.right,
        height: height ?? cl_layout.wrapContent,
      );
    }
    return applyConstraint(
      width: width ?? cl_layout.wrapContent,
      height: height ?? cl_layout.wrapContent,
      centerHorizontalTo: cl_layout.parent,
      centerVerticalTo: cl_layout.parent,
    );
  }

  /// 对齐指定元素的约束, 默认是上一个元素[sId]
  /// [anchor] - 对齐指定的元素, 不指定则默认
  /// - 撑满对应的约束
  ///
  /// [alignment] - 对齐方式
  ///   - [Alignment.centerRight] 将自身对齐锚点的右边中心
  ///   - [Alignment.centerLeft] 将自身对齐锚点的左边中心
  ///   - [Alignment.topCenter] 将自身对齐锚点的上边中心
  ///   - [Alignment.bottomCenter] 将自身对齐锚点的下边中心
  ///
  Widget alignConstraint({
    cl_layout.ConstraintId? anchor,
    //
    Alignment alignment = Alignment.centerRight,
    //--
    double? width,
    double? height,
    //--
    cl_layout.ConstraintAlign? left,
    cl_layout.ConstraintAlign? top,
    cl_layout.ConstraintAlign? right,
    cl_layout.ConstraintAlign? bottom,
  }) {
    anchor ??= cl_layout.sId(-1);
    if (alignment == Alignment.centerLeft) {
      return applyConstraint(
        width: width ?? cl_layout.wrapContent,
        left: left,
        right: right ?? anchor.left,
        top: top ?? anchor.top,
        bottom: bottom ?? anchor.bottom,
        height: height ?? cl_layout.matchConstraint,
      );
    } else if (alignment == Alignment.centerRight) {
      return applyConstraint(
        width: width ?? cl_layout.wrapContent,
        left: anchor.right,
        right: right,
        top: top ?? anchor.top,
        bottom: bottom ?? anchor.bottom,
        height: height ?? cl_layout.matchConstraint,
      );
    } else if (alignment == Alignment.topCenter) {
      return applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        top: top,
        bottom: bottom ?? anchor.top,
        left: left ?? anchor.left,
        right: right ?? anchor.right,
        height: height ?? cl_layout.wrapContent,
      );
    } else if (alignment == Alignment.bottomCenter) {
      return applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        bottom: bottom,
        top: top ?? anchor.bottom,
        left: left ?? anchor.left,
        right: right ?? anchor.right,
        height: height ?? cl_layout.wrapContent,
      );
    }
    return applyConstraint(
      width: width ?? cl_layout.wrapContent,
      height: height ?? cl_layout.wrapContent,
      centerHorizontalTo: anchor,
      centerVerticalTo: anchor,
    );
  }
}
