part of '../../flutter3_basics.dart';

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
  @implementation
  double get rotationZ => math.atan2(skewZ, scaleZ);

  /// 获取旋转角度, 弧度 [-PI..PI]
  double get rotation => -rotationX;

  /// 获取X轴倾斜角度, 弧度
  double get skewX => row0.y;

  /// 获取Y轴倾斜角度, 弧度
  double get skewY => row1.x;

  /// 获取Z轴倾斜比例
  @implementation
  double get skewZ => 0;

  /// 映射一个点, 返回新的点
  Offset mapPoint(Offset point) => MatrixUtils.transformPoint(this, point);

  /// 映射一个矩形, 返回新的矩形
  /// 映射后的矩形left/top依旧是小值, right/bottom依旧是大值
  Rect mapRect(Rect rect) => MatrixUtils.transformRect(this, rect);

  /// Preconcats the matrix with the specified matrix. M' = M * other
  void preConcat(Matrix4 other) {
    multiply(other);
  }

  Matrix4 preConcatIt(Matrix4 other) => Matrix4.copy(this)..preConcat(other);

  /// Postconcats the matrix with the specified matrix. M' = other * M
  void postConcat(Matrix4 other) {
    setFrom(other * this);
  }

  Matrix4 postConcatIt(Matrix4 other) => Matrix4.copy(this)..postConcat(other);

  /// 平移到指定位置
  void translateTo({
    ui.Offset? offset,
    double? x,
    double? y,
    double? z,
  }) {
    if (offset != null) {
      x = offset.dx;
      y = offset.dy;
    }
    setTranslationRaw(x ?? translateX, y ?? translateY, z ?? translateZ);
  }

  /// 平移指定的距离
  void translateBy({
    ui.Offset? anchor,
    double? x,
    double? y,
    double? z,
  }) {
    if (anchor != null) {
      x = anchor.dx;
      y = anchor.dy;
    }
    translate(x ?? 0, y ?? 0, z ?? 0);
  }

  /// 将平移矩阵*this
  void postTranslateBy({
    ui.Offset? anchor,
    double? x,
    double? y,
    double? z,
  }) {
    if (anchor != null) {
      x = anchor.dx;
      y = anchor.dy;
    }
    leftTranslate(x ?? 0, y ?? 0, z ?? 0);
  }

  /// 在指定锚点处操作矩阵
  void withPivot(
    VoidCallback action, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (anchor != null) {
      pivotX = anchor.dx;
      pivotY = anchor.dy;
    }
    if (pivotX == 0 && pivotY == 0 && pivotZ == 0) {
      action();
    } else {
      final translation = vector.Vector3(pivotX, pivotY, pivotZ);
      translate(translation);
      action();
      translate(-translation);
    }
  }

  /// 缩放指定倍数
  void scaleBy({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final scale = vector.Vector3(sx ?? 1, sy ?? 1, sz ?? 1);
      this.scale(scale);
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 缩放指定倍数
  void postScale({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final scale = vector.Vector3(sx ?? 1, sy ?? 1, sz ?? 1);
      final matrix = Matrix4.identity()..scale(scale);
      postConcat(matrix);
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 缩放到指定倍数
  void scaleTo({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
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
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 倾斜矩阵
  /// [kx] [alpha] 弧度
  /// [ky] [beta] 弧度
  void skewBy({
    double kx = 0,
    double ky = 0,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final skewMatrix = vector.Matrix4.skew(kx, ky);
      //final matrix = this * skewMatrix;
      postConcat(skewMatrix);
      //multiply(skewMatrix);
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 倾斜矩阵
  /// [skewBy]
  /// [kx].[alpha] 弧度
  /// [ky].[beta] 弧度
  void skewTo({
    double? kx,
    double? ky,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final skewMatrix = vector.Matrix4.skew(kx ?? 0, ky ?? 0);
      //debugger();
      if (kx != null) {
        //final index = this.index(0, 1);
        setEntry(0, 1, skewMatrix.entry(0, 1));
      }
      if (ky != null) {
        //final index = this.index(1, 0);
        setEntry(1, 0, skewMatrix.entry(1, 0));
      }
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 旋转矩阵
  /// [angle].[radians] 弧度
  /// [NumEx.toDegrees] 转角度
  /// [NumEx.toRadians] 转弧度
  void rotateBy(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      //rotate(vector.Quaternion.euler(x, y, z), );
      rotateZ(angle);
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  void postRotate(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      final matrix = Matrix4.identity()..rotateZ(angle);
      postConcat(matrix);
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 旋转到指定角度,弧度
  void rotateTo(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(() {
      setRotation(Matrix3.rotationZ(angle));
    }, anchor: anchor, pivotX: pivotX, pivotY: pivotY, pivotZ: pivotZ);
  }

  /// 反转当前的矩阵
  /// [invertedMatrix]
  Matrix4 invertMatrix() {
    invert();
    return this;
  }

  /// 反转矩阵, 返回新的矩阵
  /// [invertMatrix]
  Matrix4 invertedMatrix() => Matrix4.inverted(this);

  /// [Matrix4Tween]
  /// [Matrix4.compose]
  @testPoint
  void decomposeTest() {
    final Vector3 translation = Vector3.zero();
    final Quaternion rotation = Quaternion.identity();
    final Vector3 scale = Vector3.zero();
    final rotationMatrix = getRotation();
    decompose(translation, rotation, scale);
    assert(() {
      l.d('translation:$translation rotation:$rotation scale:$scale');
      return true;
    }());
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
    final kx = matrix.skewX;
    final ky = matrix.skewY;

    final radians = math.atan2(ky, sx);
    final denom = sx.pow(2) + ky.pow(2);

    final scaleX = math.sqrt(denom);
    final scaleY = (sx * sy - kx * ky) / scaleX;

    //x倾斜的角度, 弧度单位
    final skewX = math.atan2(sx * kx + ky * sy, denom);
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
      resultRadians, //弧度
      resultScaleX, //正负值
      resultScaleY, //正负值
      resultSkewX, //弧度
      resultSkewY //始终为0
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
