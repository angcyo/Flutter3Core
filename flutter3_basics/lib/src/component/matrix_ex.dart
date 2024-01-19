part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/29
///
/// 矩阵扩展, 矩阵相关操作
/// [MatrixUtils]
/// [Matrix44Operations]
/// 4*4矩阵
/// [Matrix4Tween]
///
/// https://pub.dev/packages/matrix4_transform
///
extension Matrix4Ex on vector.Matrix4 {
  /// 获取X轴缩放比例
  /// [getMaxScaleOnAxis]
  double get scaleX => row0.x;

  /// 获取Y轴缩放比例
  double get scaleY => row1.y;

  /// 获取Z轴缩放比例
  double get scaleZ => row2.z;

  /// 获取X轴平移距离
  double get translateX => row3.x;

  /// 获取Y轴平移距离
  double get translateY => row3.y;

  /// 获取Z轴平移距离
  double get translateZ => row3.z;

  /// 获取X轴旋转角度
  double get rotateX => vector.Quaternion.fromRotation(getRotation()).x;

  /// 获取Y轴旋转角度
  double get rotateY => vector.Quaternion.fromRotation(getRotation()).y;

  /// 获取Z轴旋转角度
  double get rotateZ => vector.Quaternion.fromRotation(getRotation()).z;

  /// 获取旋转角度
  double get rotate => max(rotateX, rotateY);

  /// 映射一个点
  Offset mapPoint(Offset point) => MatrixUtils.transformPoint(this, point);

  /// 映射一个矩形
  Rect mapRect(Rect rect) => MatrixUtils.transformRect(this, rect);

  /// 矩阵转换为字符串
  String toMatrixString() {
    return 'Matrix4('
        '${row0.x}, ${row0.y}, ${row0.z}, ${row0.w}, '
        '${row1.x}, ${row1.y}, ${row1.z}, ${row1.w}, '
        '${row2.x}, ${row2.y}, ${row2.z}, ${row2.w}, '
        '${row3.x}, ${row3.y}, ${row3.z}, ${row3.w}'
        ')';
  }
}
