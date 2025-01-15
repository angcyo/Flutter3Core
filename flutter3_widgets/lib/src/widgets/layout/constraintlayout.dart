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
Widget constrainLayout(void Function() block) =>
    cl_layout.ConstraintLayout().open(block);

/// [constrainLayout]
Widget cLayout(void Function() block) => constrainLayout(block);

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
        right: right ?? cl_layout.parent.right,
        left: left ?? cl_layout.parent.left,
        height: height ?? cl_layout.wrapContent,
      );
    } else if (alignment == Alignment.bottomCenter) {
      return applyConstraint(
        width: width ?? cl_layout.matchConstraint,
        bottom: bottom ?? cl_layout.parent.bottom,
        top: top,
        right: right ?? cl_layout.parent.right,
        left: left ?? cl_layout.parent.left,
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
}
