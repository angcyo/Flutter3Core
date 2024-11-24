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

/// 快速使用一个约束布局
/// [cl.ConstraintLayout]
Widget constrainLayout(void Function() block) =>
    cl.ConstraintLayout().open(block);

/// 约束扩展
extension ConstraintLayoutEx on Widget {}
