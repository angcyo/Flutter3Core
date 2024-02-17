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
  /// [getTranslation]
  double get translateX => row0.w;

  /// 获取Y轴平移距离
  double get translateY => row1.w;

  /// 获取Z轴平移距离
  double get translateZ => row2.w;

  /// 获取X轴旋转角度
  double get rotationX => vector.Quaternion.fromRotation(getRotation()).x;

  /// 获取Y轴旋转角度
  double get rotationY => vector.Quaternion.fromRotation(getRotation()).y;

  /// 获取Z轴旋转角度
  double get rotationZ => vector.Quaternion.fromRotation(getRotation()).z;

  /// 获取旋转角度
  double get rotation => max(rotationX, rotationY);

  /// 映射一个点
  Offset mapPoint(Offset point) => MatrixUtils.transformPoint(this, point);

  /// 映射一个矩形
  Rect mapRect(Rect rect) => MatrixUtils.transformRect(this, rect);

  /// 缩放指定倍数
  void scaleBy({
    double sx = 1,
    double sy = 1,
    double sz = 1,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    final translation = vector.Vector3(pivotX, pivotY, pivotZ);
    final scale = vector.Vector3(sx, sy, sz);
    translate(translation);
    this.scale(scale);
    translate(-translation);
  }

  /// 缩放到指定倍数
  void scaleTo({
    double? sx,
    double? sy,
    double? sz,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    final translation = vector.Vector3(pivotX, pivotY, pivotZ);
    translate(translation);
    if (sx != null) {
      setEntry(0, 0, sx);
    }
    if (sy != null) {
      setEntry(1, 1, sy);
    }
    if (sz != null) {
      setEntry(2, 2, sz);
    }
    translate(-translation);
  }

  /// 旋转矩阵
  /// [angle] 弧度
  void rotateBy(
    double angle, {
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    final translation = vector.Vector3(pivotX, pivotY, pivotZ);
    translate(translation);
    //rotate(vector.Quaternion.euler(x, y, z), );
    rotateZ(angle);
    translate(-translation);
  }

  /// 旋转到指定角度,弧度
  void rotateTo(
    double angle, {
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    final translation = vector.Vector3(pivotX, pivotY, pivotZ);
    translate(translation);
    setRotation(Matrix3.rotationZ(angle));
    translate(-translation);
  }

  /// 反转矩阵
  Matrix4 invertMatrix() {
    final matrix = clone();
    final det = matrix.invert();
    debugger();
    return matrix;
  }

  /// [Matrix4Tween]
  /// [Matrix4.compose]
  void decomposeTest() {
    final Vector3 translation = Vector3.zero();
    final Quaternion rotation = Quaternion.identity();
    final Vector3 scale = Vector3.zero();
    final rotationMatrix = getRotation();
    decompose(translation, rotation, scale);
    debugger();
  }

  /// 矩阵转换为字符串
  /// [toString]
  /// [Vector4.toString]
  String toMatrixString() {
    const digits = 6;
    return '[0] ${row0.x.toDigits(digits: digits)}, ${row0.y.toDigits(digits: digits)}, ${row0.z.toDigits(digits: digits)}, ${row0.w.toDigits(digits: digits)}$lineSeparator'
        '[1] ${row1.x.toDigits(digits: digits)}, ${row1.y.toDigits(digits: digits)}, ${row1.z.toDigits(digits: digits)}, ${row1.w.toDigits(digits: digits)}$lineSeparator'
        '[2] ${row2.x.toDigits(digits: digits)}, ${row2.y.toDigits(digits: digits)}, ${row2.z.toDigits(digits: digits)}, ${row2.w.toDigits(digits: digits)}$lineSeparator'
        '[3] ${row3.x.toDigits(digits: digits)}, ${row3.y.toDigits(digits: digits)}, ${row3.z.toDigits(digits: digits)}, ${row3.w.toDigits(digits: digits)}';
  }
}
