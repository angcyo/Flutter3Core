part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/20
///
/// OpenCV 相机校准助手
/// 相机校准用来消除摄像头经过场镜后的畸变
///
/// - 推荐常规单目标定：15–30 张高质量、多角度的图片（通常最实用）。
/// - 最低可用数：6–10 张（只在受限条件下且棋盘点很多时才勉强可用）。
/// - 这里用9张测试.
///
/// ## 使用
/// - 调用[findChessboardCorners]方法寻找棋盘格角点
/// - 调用[calibrateCamera]方法计算内参矩阵和畸变参数
/// - 调用[undistort]方法测试去畸变
///
/// ## 输出:
/// - 内参矩阵 cameraMatrix
///   - fx s cx 0 fy cy 0 0 1
///   - fx, fy：在像素坐标系下的焦距（f * sx, f * sy）；
///   - s：skew（通常为0）；
///   - (cx, cy)：主点（通常接近图像中心）。
/// - 畸变参数 distCoeffs
///   - 径向： k1, k2, k3（有时更多k4,k5,k6用于更复杂模型或 Rational）
///   - 切向： p1, p2
///   - 完整表述为 distCoeffs = [k1, k2, p1, p2, k3]（也可扩展）
///
/// https://opencv-python-tutorials.readthedocs.io/zh/latest/7.%20%E7%9B%B8%E6%9C%BA%E6%A0%A1%E5%87%86%E5%92%8C3D%E9%87%8D%E5%BB%BA/7.1.%20%E7%9B%B8%E6%9C%BA%E6%A0%A1%E5%87%86/
class CameraCalibrateHelper {
  /// 棋盘的内角点数
  final (int, int) patternSize;

  CameraCalibrateHelper({this.patternSize = (7, 6)});

  /// 查找到的所有棋盘的角点, 如果找到了角点, 说明图片是有效的.
  /// - 用来计算内参矩阵
  final Map<String, List<cv.Point2f>> cornersMap = {};

  /// [cornersMap] 角落对应的在图片中的对象坐标
  final Map<String, List<cv.Point3f>> originCornersMap = {};

  /// 拍照的原图片
  final Map<String, UiImage> originImageMap = {};

  /// [originImageMap]找到角点之后的图片
  /// - 绘制了角点调试信息
  final Map<String, UiImage> cornersImageMap = {};

  /// 输出数据: 内参矩阵 cameraMatrix
  @output
  cv.Mat? cameraMatrix;

  /// 输出数据: 畸变参数 distCoeffs
  @output
  cv.Mat? distCoeffs;

  /// 寻找每一张拍照图片的棋盘格角点
  /// - 并将成功的结果存储在 corners 中
  ///
  /// - [clearTestImage] 是否清除之前的测试图片
  @api
  Future<bool> findChessboardCorners(
    String tag,
    UiImage image, {
    bool clearTestImage = true,
  }) async {
    originImageMap[tag] = image;
    cornersImageMap.remove(tag);

    if (clearTestImage) {
      testImage = null;
      testUndistortImage = null;
    }

    final img = await image.toMatAsync(flags: cv.IMREAD_GRAYSCALE);
    final (bool success, cv.VecPoint2f corners) = cv.findChessboardCorners(
      img,
      patternSize,
    );

    if (success) {
      //提高角点精度
      final corners2 = cv.cornerSubPix(img, corners, (11, 11), (-1, -1));
      cornersMap[tag] = corners2.toList();
      //--
      originCornersMap[tag] = _buildObjectPoints();
      //debug
      final revImage = await cv
          .drawChessboardCorners(img.rgb, patternSize, corners2, true)
          .toUiImage();
      cornersImageMap[tag] = revImage!;
    } else {
      cornersMap.remove(tag);
      originCornersMap.remove(tag);
    }
    return success;
  }

  /// 开始标定
  ///
  /// - [clearTestImage] 是否清除之前的测试图片
  @api
  Future calibrateCamera({bool clearTestImage = true}) async {
    if (clearTestImage) {
      testImage = null;
      testUndistortImage = null;
    }

    List<List<cv.Point3f>> objectPoints = [];
    List<List<cv.Point2f>> imagePoints = [];
    for (final tag in cornersMap.keys) {
      objectPoints.add(originCornersMap[tag]!);
      imagePoints.add(cornersMap[tag]!);
    }
    //获取标定结果
    final (
      double rmsErr,
      cv.Mat cameraMatrix,
      cv.Mat distCoeffs,
      cv.Mat rvecs,
      cv.Mat tvecs,
    ) = await cv.calibrateCameraAsync(
      cv.Contours3f.fromList(objectPoints),
      cv.Contours2f.fromList(imagePoints),
      patternSize,
      cv.Mat.empty(),
      cv.Mat.empty(),
    );
    this.cameraMatrix = cameraMatrix;
    this.distCoeffs = distCoeffs;

    assert(() {
      final cameraMatrix2 = cameraMatrix.cameraMatrixString().cvCameraMatrix;
      final distCoeffs2 = distCoeffs.distCoeffsString().cvDistCoeffs;
      //debugger();
      return true;
    }());

    assert(() {
      //distCoeffs:Mat(addr=0x6000012e88c0, type=CV_64FC1, rows=1, cols=5, channels=1) [[-0.7881097007309008, 2.8231170733523783, 0.02692497935255397, 0.08256194583654793, -7.601687967063381]]
      //cameraMatrix:Mat(addr=0x6000012e8890, type=CV_64FC1, rows=3, cols=3, channels=1) [[802.4764753450518, 0.0, 12.792931450932988], [0.0, 1934.0012961748434, -14.44565026590872], [0.0, 0.0, 1.0]]
      l.d(
        "distCoeffs: $distCoeffs",
      ); //distCoeffs: Mat(addr=0x600002fdb060, type=CV_64FC1, rows=1, cols=5, channels=1)
      l.i("distCoeffs: ${distCoeffs.toList()}");
      l.d(
        "cameraMatrix: $cameraMatrix",
      ); //Mat(addr=0x600002fdb470, type=CV_64FC1, rows=3, cols=3, channels=1)
      l.i("cameraMatrix: ${cameraMatrix.toList()}");
      return true;
    }());

    assert(() {
      final list = cameraMatrix.toList();
      //final flatten = list.flattenList<num>();
      final flatten = list.flatten<num>();
      l.d("list->${list.runtimeType} ${flatten.runtimeType}");
      final cameraMatrix2 = cv.Mat.from2DList(
        flatten.to2DList(3),
        cv.MatType.CV_64FC1,
      );
      l.i("cameraMatrix2: ${cameraMatrix2.toList()}");
      return true;
    }());

    assert(() {
      final (cv.Mat rval, cv.Rect validPixROI) = cv.getOptimalNewCameraMatrix(
        cameraMatrix,
        distCoeffs,
        patternSize,
        1,
      );
      //rval: [[251.89067723195916, 0.0, 13.173594365507311], [0.0, 328.36261300909996, 120.09392185903232], [0.0, 0.0, 1.0]]
      l.d("rval: ${rval.toList()}");
      //validPixROI: Rect(0, 1, 6, 4)
      l.d("validPixROI: $validPixROI");
      return true;
    }());
  }

  /// 测试畸变的原图
  UiImage? testImage;

  /// 测试去畸变后的图片
  @output
  UiImage? testUndistortImage;

  /// 测试区畸变
  @api
  Future<UiImage?> undistort(UiImage image) async {
    testImage = image;
    final img = await image.toMatAsync();
    //undistort 去畸变
    final dst = await cv.undistortAsync(img, cameraMatrix!, distCoeffs!);
    final revImage = await dst.toUiImage();
    testUndistortImage = revImage;
    return revImage;
  }

  /// 重置
  @api
  void reset() {
    cornersMap.clear();
    originCornersMap.clear();
  }

  /// 获取[tag]对应的渲染图
  @api
  UiImage? getImage(String tag) {
    return cornersImageMap[tag] ?? originImageMap[tag];
  }

  /// [tag]对应的角点是否有效
  /// - [null] 表示还未拍照
  /// - [true] 表示有效
  /// - [false] 拍照的图片无效
  @api
  bool? isCornersValid(String tag) {
    if (originImageMap.containsKey(tag)) {
      return cornersMap.containsKey(tag);
    }
    return null;
  }

  /// 所有角点是否有效
  @api
  bool isAllCornersValid() {
    for (final tag in originImageMap.keys) {
      if (!cornersMap.containsKey(tag)) {
        return false;
      }
    }
    return cornersMap.isNotEmpty;
  }

  /// 有效角点数据的数量
  @api
  int get validCornersCount {
    return cornersMap.length;
  }

  /// 是否校准成功了
  @api
  bool get isCalibrated {
    return cameraMatrix != null && distCoeffs != null;
  }

  //--

  /// 构建对象世界坐标点
  List<cv.Point3f> _buildObjectPoints({double space = 10}) {
    List<cv.Point3f> objectPoints = [];
    for (var r = 0; r < patternSize.$2; r++) {
      for (var c = 0; c < patternSize.$1; c++) {
        objectPoints.add(cv.Point3f(r * space, c * space, 0));
      }
    }
    return objectPoints;
  }

  @override
  String toString() {
    if (isCalibrated) {
      return "相机矩阵: ${cameraMatrix?.toList()}\n畸变系数: ${distCoeffs?.toList()}";
    }
    return "请先校准!";
  }
}
