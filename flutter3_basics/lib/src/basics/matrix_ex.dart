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
/// https://developer.mozilla.org/zh-CN/docs/Web/CSS/transform-function/matrix
///
extension Matrix4Ex on vector.Matrix4 {
  /// 用来存储矩阵的数据结构
  ///
  /// ```
  /// [0] [0.9525653704794811,-0.30433405160002863,0.0,335.1483767553776]
  /// [1] [0.30433405160002863,0.9525653704794811,0.0,240.92653749772006]
  /// [2] [0.0,0.0,1.0,0.0]
  /// [3] [0.0,0.0,0.0,1.0]
  /// ##
  /// 0.9525653704794811,0.30433405160002863,0.0,0.0,-0.30433405160002863,0.9525653704794811,0.0,0.0,0.0,0.0,1.0,0.0,335.1483767553776,240.92653749772006,0.0,1.0
  /// ```
  ///
  /// - [Matrix4Ex.matrix4String]
  /// - [Matrix4StringEx.matrix4]
  String get matrix4String {
    return storage.join(",");
  }

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

  /// 获取X轴倾斜角度, 弧度
  double get skewX => row0.y;

  //--

  /// 获取Y轴缩放比例
  double get scaleY => row1.y;

  /// 获取Y轴倾斜角度, 弧度
  double get skewY => row1.x;

  //--

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
  /// vector.Quaternion.fromRotation(getRotation()).w
  /// ```
  @implementation
  double get rotationZ => math.atan2(skewZ, scaleZ);

  /// 获取旋转角度, 弧度 [-PI..PI]
  double get rotation => -rotationX;

  /// 获取Z轴倾斜比例
  @implementation
  double get skewZ => 0;

  /// 映射一个点[Offset], 返回新的点
  Offset mapPoint(Offset point) => MatrixUtils.transformPoint(this, point);

  /// 映射一个点[Size], 返回新的大小
  Size mapSize(Size size) {
    final offset = mapPoint(Offset(size.width, size.height));
    return Size(offset.dx, offset.dy);
  }

  /// 映射一个矩形[Rect], 返回新的矩形
  /// 映射后的矩形left/top依旧是小值, right/bottom依旧是大值
  Rect mapRect(Rect rect) => MatrixUtils.transformRect(this, rect);

  /// 映射一个[Path]
  Path mapPath(Path path) => path.transformPath(this);

  /// Preconcats the matrix with the specified matrix. M' = M * other
  void preConcat(Matrix4 other) {
    multiply(other);
  }

  /// 返回一个新的矩阵
  Matrix4 preConcatIt(Matrix4 other) => Matrix4.copy(this)..preConcat(other);

  /// Postconcats the matrix with the specified matrix. M' = other * M
  void postConcat(Matrix4 other) {
    setFrom(other * this);
  }

  /// 返回一个新的矩阵
  Matrix4 postConcatIt(Matrix4 other) => Matrix4.copy(this)..postConcat(other);

  /// 平移到指定位置
  Matrix4 translateTo({ui.Offset? offset, double? x, double? y, double? z}) {
    if (offset != null) {
      x = offset.dx;
      y = offset.dy;
    }
    setTranslationRaw(x ?? translateX, y ?? translateY, z ?? translateZ);
    return this;
  }

  /// 平移指定的距离
  Matrix4 translateBy({ui.Offset? offset, double? dx, double? dy, double? dz}) {
    if (offset != null) {
      dx = offset.dx;
      dy = offset.dy;
    }
    translate(dx ?? 0.0, dy ?? 0.0, dz ?? 0.0);
    return this;
  }

  /// 将平移矩阵*this
  Matrix4 postTranslateBy({
    ui.Offset? anchor,
    double? x,
    double? y,
    double? z,
  }) {
    if (anchor != null) {
      x = anchor.dx;
      y = anchor.dy;
    }
    leftTranslate(x ?? 0.0, y ?? 0.0, z ?? 0.0);
    return this;
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
  Matrix4 scaleBy({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    return postScale(
      sx: sx,
      sy: sy,
      sz: sz,
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
  }

  /// 缩放指定倍数
  Matrix4 postScale({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (sx == null && sy == null && sz == null) {
      return this;
    }
    if (sx == 1 && sy == 1 && sz == 1) {
      return this;
    }
    withPivot(
      () {
        final scale = vector.Vector3(sx ?? 1.0, sy ?? 1.0, sz ?? 1.0);
        this.scale(scale);
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );

    /*final translation =
        vector.Vector3(anchor?.dx ?? pivotX, anchor?.dy ?? pivotY, pivotZ);

    // 真实的缩放矩阵
    final scale = vector.Vector3(sx ?? 1, sy ?? 1, sz ?? 1);
    final scaleMatrix = Matrix4.identity()
      ..translate(translation)
      ..scale(scale)
      ..translate(-translation);

    postConcat(scaleMatrix);*/
    return this;
  }

  /// 在指定位置翻转矩阵
  void postFlip({
    bool? flipX,
    bool? flipY,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    //debugger();
    if (flipX == null && flipY == null) {
      return;
    }
    scaleBy(
      sx: flipX == true ? -1 : 1,
      sy: flipY == true ? -1 : 1,
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
  }

  /// 缩放到指定倍数
  Matrix4 scaleTo({
    double? sx,
    double? sy,
    double? sz,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (sx == null && sy == null && sz == null) {
      return this;
    }
    if (sx == 1 && sy == 1 && sz == 1) {
      return this;
    }
    withPivot(
      () {
        if (sx != null) {
          setEntry(0, 0, sx);
        }
        if (sy != null) {
          setEntry(1, 1, sy);
        }
        if (sz != null) {
          setEntry(2, 2, sz);
        }
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
    return this;
  }

  /// 倾斜矩阵, 锚点似乎不影响结果
  /// [kx] [alpha] 弧度
  /// [ky] [beta] 弧度
  Matrix4 skewBy({
    double kx = 0,
    double ky = 0,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (kx == 0 && ky == 0) {
      return this;
    }

    withPivot(
      () {
        final skewMatrix = vector.Matrix4.skew(kx, ky);
        //final matrix = this * skewMatrix;
        postConcat(skewMatrix);
        //multiply(skewMatrix);
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );

    //倾斜矩阵的translate, 似乎不影响结果
    /*
    final translation =
        vector.Vector3(anchor?.dx ?? pivotX, anchor?.dy ?? pivotY, pivotZ);
    // 真实的倾斜矩阵
    final skewMatrix = vector.Matrix4.skew(kx, ky);
    final targetMatrix = Matrix4.identity()
      ..translate(translation)
      ..postConcat(skewMatrix)
      ..translate(-translation);

    postConcat(targetMatrix);*/
    return this;
  }

  /// 倾斜矩阵
  /// [skewBy]
  /// [kx].[alpha] 弧度
  /// [ky].[beta] 弧度
  Matrix4 skewTo({
    double? kx,
    double? ky,
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (kx == null && ky == null) {
      return this;
    }
    if (kx == 0 && ky == 0) {
      return this;
    }
    withPivot(
      () {
        final skewMatrix = vector.Matrix4.skew(kx ?? 0.0, ky ?? 0.0);
        //debugger();
        if (kx != null) {
          //final index = this.index(0, 1);
          setEntry(0, 1, skewMatrix.entry(0, 1));
        }
        if (ky != null) {
          //final index = this.index(1, 0);
          setEntry(1, 0, skewMatrix.entry(1, 0));
        }
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
    return this;
  }

  /// 旋转矩阵
  /// [angle].[radians] 弧度
  /// [NumEx.toDegrees] 转角度
  /// [NumEx.toRadians] 转弧度
  Matrix4 rotateBy(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (angle % (2 * math.pi) == 0) {
      return this;
    }
    withPivot(
      () {
        //rotate(vector.Quaternion.euler(x, y, z), );
        rotateZ(angle);
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
    return this;
  }

  /// [angle].[radians] 弧度
  /// [rotateBy]
  Matrix4 postRotate(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    if (angle % (2 * math.pi) == 0) {
      return this;
    }
    withPivot(
      () {
        final matrix = Matrix4.identity()..rotateZ(angle);
        postConcat(matrix);
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
    return this;
  }

  /// 旋转到指定角度,弧度
  Matrix4 rotateTo(
    double angle, {
    ui.Offset? anchor,
    double pivotX = 0,
    double pivotY = 0,
    double pivotZ = 0,
  }) {
    withPivot(
      () {
        setRotation(Matrix3.rotationZ(angle));
      },
      anchor: anchor,
      pivotX: pivotX,
      pivotY: pivotY,
      pivotZ: pivotZ,
    );
    return this;
  }

  /// 当前矩阵是否可以逆变换
  bool get canInvert => determinant() != 0;

  /// 反转当前的矩阵
  /// [invertedMatrix]
  Matrix4 invertMatrix() {
    invert();
    return this;
  }

  /// 反转矩阵
  /// [invertMatrix]
  /// @return 返回新的矩阵
  Matrix4 invertedMatrix() {
    try {
      return canInvert ? Matrix4.inverted(this) : this;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
      return this;
    }
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
      resultSkewY, //始终为0
    ];
  }

  /// 保证相对于(0,0)位置的锚点保持不变
  /// [anchorOriginMatrix] 锚点之前作用的矩阵
  /// @return 返回包含平移的矩阵
  Matrix4 keepAnchor(Offset anchor, {Matrix4? anchorOriginMatrix}) {
    //debugger();
    final Matrix4 beforeMatrix = anchorOriginMatrix ?? Matrix4.identity();

    //锚点目标位置
    final Offset beforeAnchor = beforeMatrix.mapPoint(anchor);

    final Matrix4 afterMatrix = beforeMatrix * this;
    final Offset afterAnchor = afterMatrix.mapPoint(anchor);

    //当前矩阵需要平移的量
    final offset = beforeAnchor - afterAnchor;
    return offset.translateMatrix * this;
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

  /// matrix(<a> <b> <c> <d> <e> <f>) 变换函数以六个值的变换矩阵形式指定变换。matrix(a,b,c,d,e,f) 等同于应用变换矩阵：
  ///
  /// ```
  /// (  a  c  e
  ///    b  d  f
  ///    0  0  1 )
  /// ```
  /// https://developer.mozilla.org/zh-CN/docs/Web/SVG/Attribute/transform
  ///
  /// ```
  /// matrix(scaleX(), skewY(), skewX(), scaleY(), translateX(), translateY())
  /// ```
  /// https://developer.mozilla.org/zh-CN/docs/Web/CSS/transform-function/matrix
  ///
  /// [Matrix3Ex.toTransformString]
  /// [Matrix4Ex.toTransformString]
  /// [StringPaintEx.transformMatrix]
  String toTransformString({int digits = 15}) {
    return 'matrix(${scaleX.toDigits(digits: digits)}, ${skewY.toDigits(digits: digits)}, ${skewX.toDigits(digits: digits)}, ${scaleY.toDigits(digits: digits)}, ${translateX.toDigits(digits: digits)}, ${translateY.toDigits(digits: digits)})';
  }

  /// 矩阵转换为字符串
  /// [lineNumber] 是否显示行号
  /// [toString]
  /// [Vector4.toString]
  String toMatrixString({
    bool lineNumber = true,
    int padWidth = 0,
    int digits = 6,
  }) {
    String wrap(double value, [bool end = false]) =>
        "${value.toDigits(digits: digits)}${end ? "" : ", "}".padRight(
          padWidth,
        );
    return '${lineNumber ? "[0] " : ""}${wrap(row0.x)}${wrap(row0.y)}${wrap(row0.z)}${wrap(row0.w, true)}$lineSeparator'
        '${lineNumber ? "[1] " : ""}${wrap(row1.x)}${wrap(row1.y)}${wrap(row1.z)}${wrap(row1.w, true)}$lineSeparator'
        '${lineNumber ? "[2] " : ""}${wrap(row2.x)}${wrap(row2.y)}${wrap(row2.z)}${wrap(row2.w, true)}$lineSeparator'
        '${lineNumber ? "[3] " : ""}${wrap(row3.x)}${wrap(row3.y)}${wrap(row3.z)}${wrap(row3.w, true)}$lineSeparator';
  }
}

extension Matrix4StringEx on String {
  /// 用来存储矩阵的数据结构
  ///
  /// ```
  /// 0.9525653704794811,0.30433405160002863,0.0,0.0,-0.30433405160002863,0.9525653704794811,0.0,0.0,0.0,0.0,1.0,0.0,335.1483767553776,240.92653749772006,0.0,1.0
  /// ```
  ///
  /// - [Matrix4Ex.matrix4String]
  /// - [Matrix4StringEx.matrix4]
  Matrix4 get matrix4 => Matrix4.fromList(doubleList);
}

extension Matrix3Ex on vector.Matrix3 {
  double get translateX => row0.z;

  double get translateY => row1.z;

  /// 获取X轴缩放比例
  /// [getMaxScaleOnAxis]
  double get scaleX => row0.x;

  /// 获取X轴倾斜角度, 弧度
  double get skewX => row0.y;

  //--

  /// 获取Y轴缩放比例
  double get scaleY => row1.y;

  /// 获取Y轴倾斜角度, 弧度
  double get skewY => row1.x;

  //--

  /// 转换成4*4矩阵[Matrix4]
  /// [Matrix4Ex.toMatrix3]
  Matrix4 toMatrix4() => Matrix4.fromList([
    //sx ky . .
    this[0], this[1], this[2], 0.0,
    //kx sy . .
    this[3], this[4], this[5], 0.0,
    // . . . .
    0, 0, 1, 0,
    //tx ty tz .
    this[6], this[7], 0, this[8],
  ]);

  /*Matrix4.fromList([
        // Row 1
        scaleX, skewX, 0, translateX,
        // Row 2
        skewY, scaleY, 0, translateY,
        // Row 3
        0, 0, 1, 0,
        // Row 4
        0, 0, 0, 1,
      ]);*/

  /// [Matrix3Ex.toTransformString]
  /// [Matrix4Ex.toTransformString]
  /// [StringPaintEx.transformMatrix]
  String toTransformString({int digits = 15}) {
    return 'matrix(${scaleX.toDigits(digits: digits)}, ${skewY.toDigits(digits: digits)}, ${skewX.toDigits(digits: digits)}, ${scaleY.toDigits(digits: digits)}, ${translateX.toDigits(digits: digits)}, ${translateY.toDigits(digits: digits)})';
  }

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

/// 在指定锚点[anchor],创建一个翻转矩阵
Matrix4 createFlipMatrix({bool? flipX, bool? flipY, Offset? anchor}) {
  anchor ??= Offset.zero;
  return Matrix4.identity()
    ..translate(anchor.dx, anchor.dy, 0)
    ..scale(flipX == true ? -1.0 : 1.0, flipY == true ? -1.0 : 1.0, 1.0)
    ..translate(-anchor.dx, -anchor.dy, 0);
}

/// 创建一个平移矩阵
/// [offset] 同时设置[tx].[ty]
Matrix4 createTranslateMatrix({
  double? tx,
  double? ty,
  double? tz,
  Offset? offset,
}) {
  tx ??= offset?.dx;
  ty ??= offset?.dy;
  return Matrix4.identity()..translate(tx ?? 0.0, ty ?? 0.0, tz ?? 0.0);
}

/// 在指定锚点[anchor],创建一个缩放矩阵
Matrix4 createScaleMatrix({
  double? scale,
  double? sx,
  double? sy,
  Offset? anchor,
}) {
  anchor ??= Offset.zero;
  final tv = vector.Vector3(anchor.dx, anchor.dy, 0);
  final sv = vector.Vector3(scale ?? sx ?? 1.0, scale ?? sy ?? 1.0, 1.0);
  return Matrix4.identity()
    ..translate(tv)
    ..scale(sv)
    ..translate(-tv);
}

/// 在指定锚点[anchor],创建一个旋转矩阵
/// [radians] 旋转的弧度
Matrix4 createRotateMatrix(double? radians, {Offset? anchor}) {
  anchor ??= Offset.zero;
  final translation = vector.Vector3(anchor.dx, anchor.dy, 0);
  return Matrix4.identity()
    ..translate(translation)
    ..rotateZ(radians ?? 0)
    ..translate(-translation);
}

/// 创建一个3*3矩阵
/// [Matrix3]
/// [Matrix4.toMatrix3]
/// [Matrix3.toMatrix4]
/// [Matrix3Ex.toTransformString]
/// [Matrix4Ex.toTransformString]
/// [StringPaintEx.transformMatrix]
Matrix3 createMatrix3({
  double scaleX = 1.0,
  double skewX = 0.0 /*弧度*/,
  double skewY = 0.0 /*弧度*/,
  double scaleY = 1.0,
  double translateX = 0.0,
  double translateY = 0.0,
}) => Matrix3.fromList([
  //sx ky .
  scaleX, skewY, 0,
  //kx sy .
  skewY, scaleX, 0,
  //tx ty .
  translateX, translateY, 1,
]);

/// [createMatrix3]
Matrix4 createMatrix4({
  double scaleX = 1.0,
  double skewX = 0.0 /*弧度*/,
  double skewY = 0.0 /*弧度*/,
  double scaleY = 1.0,
  double translateX = 0.0,
  double translateY = 0.0,
}) => createMatrix3(
  scaleX: scaleX,
  skewX: skewX,
  skewY: skewY,
  scaleY: scaleY,
  translateX: translateX,
  translateY: translateY,
).toMatrix4();

//--

/// 创建一个透视矩阵, `精度不够`
/// 透视矩阵变换, 4个原始点, 4个目标点, 计算透视矩阵
///
/// https://franklinta.com/2014/09/08/computing-css-matrix3d-transforms/
///
/// https://github.com/jlouthan/perspective-transform
///
/// [Matrix4Ex.toMatrix3]
///
@Deprecated("请使用[createPerspectiveMatrix2]")
Matrix4 createPerspectiveMatrix(List<Offset> from, List<Offset> to) {
  assert(from.length == 4 && to.length == 4);

  List<List<double>> A = []; // 8x8 matrix
  for (int i = 0; i < 4; i++) {
    A.add([
      from[i].x,
      from[i].y,
      1,
      0,
      0,
      0,
      -from[i].x * to[i].x,
      -from[i].y * to[i].x,
    ]);
    A.add([
      0,
      0,
      0,
      from[i].x,
      from[i].y,
      1,
      -from[i].x * to[i].y,
      -from[i].y * to[i].y,
    ]);
  }

  List<double> b = []; // 8x1 vector
  for (int i = 0; i < 4; i++) {
    b.add(to[i].x);
    b.add(to[i].y);
  }

  // Solve A * h = b for h (homogeneous coordinates)
  List<double> h = _solve(A, b);

  // Construct the transformation matrix H
  List<List<double>> H = [
    [h[0], h[1], 0, h[2]],
    [h[3], h[4], 0, h[5]],
    [0, 0, 1, 0],
    [h[6], h[7], 0, 1],
  ];

  return Matrix4.fromList([
    H[0][0],
    H[1][0],
    H[2][0],
    H[3][0],
    H[0][1],
    H[1][1],
    H[2][1],
    H[3][1],
    H[0][2],
    H[1][2],
    H[2][2],
    H[3][2],
    H[0][3],
    H[1][3],
    H[2][3],
    H[3][3],
  ]);
}

/// 线性方程组求解
List<double> _solve(List<List<double>> A, List<double> b) {
  int n = A.length;

  // 增强矩阵 A，将常数项 b 添加到 A 的最后一列
  for (int i = 0; i < n; i++) {
    A[i].add(b[i]);
  }

  // 前向消元
  for (int i = 0; i < n; i++) {
    // 找到当前列中的最大元素
    double maxEl = A[i][i].abs();
    int maxRow = i;
    for (int k = i + 1; k < n; k++) {
      if (A[k][i].abs() > maxEl) {
        maxEl = A[k][i].abs();
        maxRow = k;
      }
    }

    // 将最大行与当前行交换
    if (maxRow != i) {
      List<double> temp = A[maxRow];
      A[maxRow] = A[i];
      A[i] = temp;
    }

    // 使主元素下方的元素等于零
    for (int k = i + 1; k < n; k++) {
      double c = -A[k][i] / A[i][i]; // 计算消元因子
      for (int j = i; j < n + 1; j++) {
        if (i == j) {
          A[k][j] = 0; // 主对角线元素置为零
        } else {
          A[k][j] += c * A[i][j]; // 更新当前行
        }
      }
    }
  }

  // 回代过程
  List<double> x = List<double>.filled(n, 0); // 初始化解向量
  for (int i = n - 1; i >= 0; i--) {
    x[i] = A[i][n] / A[i][i]; // 计算每个变量的值
    for (int k = i - 1; k >= 0; k--) {
      A[k][n] -= A[k][i] * x[i]; // 更新前面行的常数项
    }
  }

  return x; // 返回解向量
}

/// Dart 纯实现：4点求透视矩阵, 8个点坐标.（单精度）
/// [createPerspectiveMatrix]
/// [createPerspectiveMatrix2]
Matrix3 createPerspectiveMatrix2(List<double> from, List<double> to) {
  assert(from.length >= 8 && to.length >= 8);

  // 构建8x9增广矩阵
  List<List<double>> A = List.generate(8, (_) => List.filled(9, 0.0));

  for (int i = 0; i < 4; i++) {
    final index = i * 2;
    final index2 = i * 2 + 1;
    double x = from[index], y = from[index2];
    double u = to[index], v = to[index2];

    A[index][0] = x;
    A[index][1] = y;
    A[index][2] = 1;
    A[index][3] = 0;
    A[index][4] = 0;
    A[index][5] = 0;
    A[index][6] = -u * x;
    A[index][7] = -u * y;
    A[index][8] = -u;

    A[index2][0] = 0;
    A[index2][1] = 0;
    A[index2][2] = 0;
    A[index2][3] = x;
    A[index2][4] = y;
    A[index2][5] = 1;
    A[index2][6] = -v * x;
    A[index2][7] = -v * y;
    A[index2][8] = -v;
  }

  // 高斯-约旦消元，解 null space
  List<double> h = _solveHomographyMatrix(A);

  // 得到3x3矩阵（最后一位归一化为1.0）
  //debugger();
  //return Matrix3.fromList(h);
  /*return [
    [h[0], h[1], h[2]],
    [h[3], h[4], h[5]],
    [h[6], h[7], h[8]],
  ];*/
  return Matrix3.columns(
    Vector3(h[0], h[3], h[6]),
    Vector3(h[1], h[4], h[7]),
    Vector3(h[2], h[5], h[8]),
  );
}

/// 解 8x9 增广矩阵的 null space，返回解向量
List<double> _solveHomographyMatrix(List<List<double>> A) {
  int row = A.length;
  int col = A[0].length;

  // 逐列消元
  for (int i = 0; i < row; i++) {
    // 寻找主元
    int maxRow = i;
    for (int k = i + 1; k < row; k++) {
      if (A[k][i].abs() > A[maxRow][i].abs()) maxRow = k;
    }
    // 交换行
    var temp = A[i];
    A[i] = A[maxRow];
    A[maxRow] = temp;

    // 主元归一化
    double div = A[i][i];
    if (div.abs() < 1e-12) continue;
    for (int j = i; j < col; j++) {
      A[i][j] /= div;
    }

    // 消元
    for (int k = 0; k < row; k++) {
      if (k == i) continue;
      double factor = A[k][i];
      for (int j = i; j < col; j++) {
        A[k][j] -= factor * A[i][j];
      }
    }
  }

  // 取最后一列（自由变量）为1，回代解
  List<double> h = List.filled(9, 0.0);
  h[8] = 1.0;
  for (int i = row - 1; i >= 0; i--) {
    double s = 0.0;
    for (int j = i + 1; j < 8; j++) {
      s += A[i][j] * h[j];
    }
    h[i] = -s - A[i][8] * h[8];
  }
  return h;
}
