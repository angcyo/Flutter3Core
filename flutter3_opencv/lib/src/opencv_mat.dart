part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
//MARK: - Mat扩展
/// Mat扩展
extension MatEx on cv.Mat {
  /// - [toUiImage]
  @alias
  Future<UiImage?> get uiImage => toUiImage();

  /// [cv.Mat]转成图片[UiImage]
  Future<UiImage?> toUiImage({String ext = ".png"}) async {
    return cvImgEncodeMat(this, ext: ext)?.toImage();
  }

  /// 获取图片的宽高
  (int width, int height) get size {
    return (width, height);
  }

  /// 获取对应的3*3矩阵
  ///
  /// ## 可视化输出的数据
  ///
  /// ```
  /// [[0.8922067941243021, 0.014188208530941089, 8.176286297216732],
  /// [-0.03583605628807173, 0.9391478601047357, 8.216367882118266],
  /// [-0.00010755186200365007, -0.000048519939015975823, 1.0]]
  /// ```
  ///
  /// ## 实际在一维数组中是
  ///
  /// ```
  /// [0.8922067941243021, -0.03583605628807173, -0.00010755186200365007,
  /// 0.014188208530941089, 0.9391478601047357, -0.000048519939015975823,
  /// 8.176286297216732, 8.216367882118266, 1.0]
  /// ```
  List<double> get matrix3List {
    final matrix3 = List<double>.filled(9, 0);
    forEachRow((row, values) {
      for (int i = 0; i < values.length; i++) {
        matrix3[i * 3 + row] = values[i].toDouble();
      }
    });
    return matrix3;
  }

  Matrix3 get matrix3 {
    final matrix3 = Matrix3.identity();
    forEachRow((row, values) {
      matrix3.setRow(
        row,
        Vector3(
          values[0].toDouble(),
          values[1].toDouble(),
          values[2].toDouble(),
        ),
      );
    });
    return matrix3;
  }

  Matrix4 get matrix4 => matrix3.toMatrix4();

  //MARK: - channel

  /// 是否是单通道数据
  /// - 单通道就是灰度图
  bool get isGray => channels == 1;

  /// 转成灰度图片
  cv.Mat get gray {
    return cv.cvtColor(this, cv.COLOR_BGR2GRAY);
  }

  /// BGR转成RGB图片
  cv.Mat get rgb {
    return cv.cvtColor(this, cv.COLOR_BGR2RGB);
  }

  /// 灰度图转成RGB图片
  cv.Mat get gray2rgb {
    return cv.cvtColor(this, cv.COLOR_GRAY2RGB);
  }

  /// 将矩阵转换成字符串
  String flattenString() {
    final list = toList();
    final flatten = list.flatten<num>();
    return flatten.join(',');
  }

  /// 将相机内参矩阵转换成字符串, 方便传输
  /// - [MatEx.cameraMatrixString]
  /// - [MatStringEx.cvCameraMatrix]
  ///
  /// ```
  /// //cameraMatrix:Mat(addr=0x6000012e8890, type=CV_64FC1, rows=3, cols=3, channels=1)
  /// [[802.4764753450518, 0.0, 12.792931450932988],
  /// [0.0, 1934.0012961748434, -14.44565026590872],
  /// [0.0, 0.0, 1.0]]
  /// ```
  String cameraMatrixString() => flattenString();

  /// 将相机畸变参数转换成字符串, 方便传输
  /// - [MatEx.distCoeffsString]
  /// - [MatStringEx.cvDistCoeffs]
  ///
  /// ```
  /// distCoeffs:Mat(addr=0x6000012e88c0, type=CV_64FC1, rows=1, cols=5, channels=1)
  /// [[-0.7881097007309008, 2.8231170733523783, 0.02692497935255397, 0.08256194583654793, -7.601687967063381]]
  ///
  /// ```
  String distCoeffsString() => flattenString();

  /// 3*3的矩阵
  /// - [MatEx.matrix3String]
  /// - [MatStringEx.cvMatrix3]
  ///
  /// ```
  /// Mat(addr=0x600000d662d0, type=CV_64FC1, rows=3, cols=3, channels=1)
  /// [25.115459457396405, -0.37128071248135014, -6985.416105677234],[10.56256529565071, 15.73150297766723, -8164.720811665292],[0.019392064126516825, -0.0004494108804756873, 1.0]
  /// ```
  String matrix3String() => flattenString();

  //MARK: - list

  /// - [toList]
  List<List<double>> toDoubleList() {
    final ret = <List<double>>[];
    forEachRow((r, v) => ret.add(v.map((e) => e.toDouble()).toList()));
    return ret;
  }

  /// - [toList]
  List<List<int>> toIntList() {
    final ret = <List<int>>[];
    forEachRow((r, v) => ret.add(v.map((e) => e.round()).toList()));
    return ret;
  }
}
