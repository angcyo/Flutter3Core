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
  /// 获取X轴平移距离
  /// [getTranslation]
  double get translateX => row0.w;

  /// 获取Y轴平移距离
  double get translateY => row1.w;

  /// 获取Z轴平移距离
  double get translateZ => row2.w;

  /// 获取X轴缩放比例
  /// [getMaxScaleOnAxis]
  double get scaleX => row0.x;

  /// 获取Y轴缩放比例
  double get scaleY => row1.y;

  /// 获取Z轴缩放比例
  double get scaleZ => row2.z;

  /// 获取X轴旋转角度, 弧度 [-PI..PI]
  /// ```
  /// /*vector.Quaternion.fromRotation(getRotation()).x*/
  /// ```
  double get rotationX => math.atan2(skewX, scaleX);

  /// 获取Y轴旋转角度, 弧度 [-PI..PI]
  /// ```
  /// /*vector.Quaternion.fromRotation(getRotation()).y*/
  /// ```
  double get rotationY => math.atan2(skewY, scaleY);

  /// 获取Z轴旋转角度, 弧度 [-PI..PI]
  /// ```
  /// vector.Quaternion.fromRotation(getRotation()).z
  /// ```
  @implemented
  double get rotationZ => math.atan2(skewZ, scaleZ);

  /// 获取旋转角度, 弧度 [-PI..PI]
  double get rotation => -rotationX;

  /// 获取X轴倾斜角度, 弧度
  double get skewX => row0.y;

  /// 获取Y轴倾斜角度, 弧度
  double get skewY => row1.x;

  /// 获取Z轴倾斜比例
  @implemented
  double get skewZ => 0;

  /// 映射一个点
  Offset mapPoint(Offset point) => MatrixUtils.transformPoint(this, point);

  /// 映射一个矩形
  Rect mapRect(Rect rect) => MatrixUtils.transformRect(this, rect);

  /// 平移到指定位置
  void translateTo({
    double? x,
    double? y,
    double? z,
  }) {
    setTranslationRaw(x ?? translateX, y ?? translateY, z ?? translateZ);
  }

  /// 平移指定的距离
  void translateBy({
    double? x,
    double? y,
    double? z,
  }) {
    translate(x ?? 0, y ?? 0, z ?? 0);
  }

  /// 在指定锚点处操作矩阵
  void withPivot(
    VoidCallback action, {
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    final translation = vector.Vector3(pivotX, pivotY, pivotZ);
    translate(translation);
    action();
    translate(-translation);
  }

  /// 缩放指定倍数
  void scaleBy({
    double sx = 1,
    double sy = 1,
    double sz = 1,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final scale = vector.Vector3(sx, sy, sz);
      this.scale(scale);
    }, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
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
    withPivot(() {
      if (sx != null) {
        setEntry(0, 0, sx);
      }
      if (sy != null) {
        setEntry(1, 1, sy);
      }
      if (sz != null) {
        setEntry(2, 2, sz);
      }
    }, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 倾斜矩阵
  /// [kx] [alpha] 弧度
  /// [ky] [beta] 弧度
  void skewBy({
    double kx = 0,
    double ky = 0,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final skewMatrix = vector.Matrix4.skew(kx, ky);
      //final matrix = this * skewMatrix;
      multiply(skewMatrix);
    }, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 倾斜矩阵
  /// [skewBy]
  /// [kx] [alpha] 弧度
  /// [ky] [beta] 弧度
  void skewTo({
    double? kx,
    double? ky,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final skewMatrix = vector.Matrix4.skew(kx ?? 0, ky ?? 0);
      if (kx != null) {
        setEntry(0, 1, skewMatrix.entry(0, 1));
      }
      if (ky != null) {
        setEntry(1, 0, skewMatrix.entry(1, 0));
      }
    }, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 旋转矩阵
  /// [angle] [radians] 弧度
  /// [NumEx.toDegrees] 转角度
  /// [NumEx.toRadians] 转弧度
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
  @testPoint
  void decomposeTest() {
    final Vector3 translation = Vector3.zero();
    final Quaternion rotation = Quaternion.identity();
    final Vector3 scale = Vector3.zero();
    final rotationMatrix = getRotation();
    decompose(translation, rotation, scale);
    //debugger();
  }

  /// 将[matrix]拆解成[CanvasRenderProperty]
  /// QR分解
  /// https://stackoverflow.com/questions/5107134/find-the-rotation-and-skew-of-a-matrix-transformation
  ///
  /// https://ristohinno.medium.com/qr-decomposition-903e8c61eaab
  ///
  /// https://zh.wikipedia.org/zh-hans/QR%E5%88%86%E8%A7%A3
  ///
  /// https://rosettacode.org/wiki/QR_decomposition#Java
  ///
  ///
  List<double> qrDecomposition() {
    Matrix4 matrix = this;
    final sx = matrix.scaleX;
    final sy = matrix.scaleY;
    final radians = math.atan2(matrix.skewY, sx);
    final denom = sx.pow(2) + matrix.skewY.pow(2);

    final scaleX = math.sqrt(denom);
    final scaleY = (sx * sy - matrix.skewX * matrix.skewY) / scaleX;

    //x倾斜的角度, 弧度单位
    final skewX = math.atan2((sx * matrix.skewX + matrix.skewY * sy), denom);
    //y倾斜的角度, 弧度单位, 始终为0, 这是关键.
    const skewY = 0.0;

    //updateAngle(angle);
    final resultRadians = radians; //旋转的角度, 弧度单位
    //final resultFlipX = scaleX < 0; //是否x翻转
    //final resultFlipY = scaleY < 0; //是否y翻转
    final resultScaleX = scaleX; //x缩放比例
    final resultScaleY = scaleY; //y缩放比例
    final resultSkewX = skewX;
    const resultSkewY = skewY;
    return [
      resultRadians,
      resultScaleX,
      resultScaleY,
      resultSkewX,
      resultSkewY
    ];
  }

  /// 转换成3*3的矩阵
  /// ```
  /// /*getNormalMatrix()
  ///     ..setEntry(0, 2, translateX)
  ///     ..setEntry(1, 2, translateY);*/
  /// ```
  /// [getNormalMatrix] 返回的只有旋转数据, 没有平移数据
  /// [Matrix3Ex.toMatrix4]
  Matrix3 toMatrix3() => Matrix3.identity()
    ..setEntry(0, 0, entry(0, 0))
    ..setEntry(0, 1, entry(0, 1))
    ..setEntry(0, 2, entry(0, 3))
    ..setEntry(1, 0, entry(1, 0))
    ..setEntry(1, 1, entry(1, 1))
    ..setEntry(1, 2, entry(1, 3))
    ..setEntry(2, 0, 0)
    ..setEntry(2, 1, 0)
    ..setEntry(2, 2, 1);

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

extension Matrix3Ex on vector.Matrix3 {
  double get translateX => row0.z;

  double get translateY => row1.z;

  /// 转换成4*4矩阵[Matrix4]
  /// [Matrix4Ex.toMatrix3]
  Matrix4 toMatrix4() => Matrix4.identity()
    ..setRotation(this)
    ..setTranslationRaw(translateX, translateY, 0);

  /// 矩阵转换为字符串
  /// [toString]
  /// [Vector4.toString]
  String toMatrixString() {
    const digits = 6;
    return '[0] ${row0.x.toDigits(digits: digits)}, ${row0.y.toDigits(digits: digits)}, ${row0.z.toDigits(digits: digits)}$lineSeparator'
        '[1] ${row1.x.toDigits(digits: digits)}, ${row1.y.toDigits(digits: digits)}, ${row1.z.toDigits(digits: digits)}$lineSeparator'
        '[2] ${row2.x.toDigits(digits: digits)}, ${row2.y.toDigits(digits: digits)}, ${row2.z.toDigits(digits: digits)}';
  }
}
