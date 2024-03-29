part of '../flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/29
///
/// # GCode 常用指令
/// - `G20` 英寸单位
/// - `G21` 毫米单位
/// - ---
/// - `G90` 绝对位置
/// - `G91` 相对位置
/// - ---
/// - `G0` moveTo
/// - `G1` lineTo
/// - `G2` 顺时针画弧
/// - `G3` 逆时针画弧
/// - ---
/// - `M05` 关闭主轴,所有`G`操作, 都变成`moveTo`
/// - `M03` 打开主轴
///
/// ```
/// G90
/// G21
/// M03S255
/// G0X0Y0
/// G1X100Y0
/// G1X100Y100
/// G1X0Y100
/// G1X0Y0
/// M05S0
/// ```
class GCode {}
