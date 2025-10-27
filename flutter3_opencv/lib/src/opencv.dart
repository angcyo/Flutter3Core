part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/09
///
/// https://opencv-python-tutorials.readthedocs.io/zh/latest/
///
/// Opencv 默认的颜色通道排序是 BGR
/// - [cv.MatType.CV_8UC3] BGR
/// - [cv.MatType.CV_8UC4] BGRA

/// OpenCV版本
/// - `4.12.0` 2025-07-09 √
/// - `4.11.0` 2025-02-18
String cvVersion() => cv.openCvVersion();

/// Otsu算法, 获取图片的阈值
/// - [cvThresholdMat]
double cvOtsu(cv.InputArray src) {
  final (threshold, _) = cv.threshold(
    src,
    0,
    255,
    cv.THRESH_BINARY + cv.THRESH_OTSU,
  );
  return threshold;
}

/// 透视变换. 左上、右上、右下、左下
/// - [srcPoints] 原4个角的坐标
/// - [dstPoints] 变换后4个角的坐标
/// https:///docs.opencv.org/master/da/d54/group__imgproc__transform.html#ga8c1ae0e3589a9d77fffc962c49b22043
///
/// - [cv.warpPerspective] 透视变换作用到图片
///
cv.Mat cvPerspectiveTransform(
  List<cv.Point> srcPoints,
  List<cv.Point> dstPoints,
) {
  return cv.getPerspectiveTransform(
    cv.VecPoint.fromList(srcPoints),
    cv.VecPoint.fromList(dstPoints),
  );
}

/// 浮点数值
cv.Mat cvPerspectiveTransform2f(
  List<cv.Point2f> srcPoints,
  List<cv.Point2f> dstPoints,
) {
  return cv.getPerspectiveTransform2f(
    cv.VecPoint2f.fromList(srcPoints),
    cv.VecPoint2f.fromList(dstPoints),
  );
}

/// 从路径中读取图片Mat
/// - [filePath] 必须要是绝对路径, 否则会报错
/// - [flags]
///   - [cv.IMREAD_COLOR] 彩色图片, 透明图片也是3通道 BGR
///   - [cv.IMREAD_UNCHANGED] 支持透明图片 4通道 BGRA
///   - [cv.IMREAD_GRAYSCALE] 灰度图片
cv.Mat cvLoadMat(String filePath, {int flags = cv.IMREAD_COLOR}) {
  return cv.imread(filePath, flags: flags);
}

/// 解码图片, 从内存中读取图片[cv.Mat]
cv.Mat cvImgDecodeMat(Uint8List bytes, {int flags = cv.IMREAD_COLOR}) {
  return cv.imdecode(bytes, flags);
}

Future<cv.Mat> cvImgDecodeMatAsync(
  Uint8List bytes, {
  int flags = cv.IMREAD_COLOR,
}) {
  return cv.imdecodeAsync(bytes, flags);
}

/// 编码Mat成成图片字节数组
Uint8List? cvImgEncodeMat(cv.InputArray img, {String ext = ".png"}) {
  final (success, bytes) = cv.imencode(ext, img);
  return success ? bytes : null;
}

/// 颜色空间转换
/// - [code]
///   - [cv.COLOR_BGR2RGBA] 转成RGBA
///   - [cv.COLOR_BGR2GRAY] 转成灰度
///   - [cv.COLOR_BGR2HSV] 转成HSV
///   - [cv.COLOR_BGR2HLS] 转成HLS
cv.Mat cvCvtColorMat(
  cv.InputArray src, {
  int code = cv.COLOR_BGR2RGBA,
  cv.OutputArray? dst,
}) {
  return cv.cvtColor(src, code, dst: dst);
}

/// 灰度化
///
/// - [cvCvtColorMat]
cv.Mat cvGrayMat(
  cv.InputArray src, {
  int code = cv.COLOR_BGR2GRAY,
  cv.OutputArray? dst,
}) {
  return cv.cvtColor(src, code, dst: dst);
}

/// 灰色化的图片转成彩色空间
cv.Mat cvColorMat(
  cv.InputArray src, {
  int code = cv.COLOR_GRAY2BGR,
  cv.OutputArray? dst,
}) {
  return cv.cvtColor(src, code, dst: dst);
}

/// 获取B通道的图片
cv.Mat cvGetBMat(cv.InputArray img) {
  final bgrMat = cv.split(img);
  final b = bgrMat[0];
  final g = cv.Mat.zeros(b.rows, b.cols, b.type);
  final r = cv.Mat.zeros(b.rows, b.cols, b.type);
  return cv.merge(cv.VecMat.fromList([b, g, r]));
}

/// 获取G通道的图片
cv.Mat cvGetGMat(cv.InputArray img) {
  final bgrMat = cv.split(img);
  final g = bgrMat[1];
  final b = cv.Mat.zeros(g.rows, g.cols, g.type);
  final r = cv.Mat.zeros(g.rows, g.cols, g.type);
  return cv.merge(cv.VecMat.fromList([b, g, r]));
}

/// 获取R通道的图片
cv.Mat cvGetRMat(cv.InputArray img) {
  final bgrMat = cv.split(img);
  final r = bgrMat[2];
  final b = cv.Mat.zeros(r.rows, r.cols, r.type);
  final g = cv.Mat.zeros(r.rows, r.cols, r.type);
  return cv.merge(cv.VecMat.fromList([b, g, r]));
}

/// 二值化图片
/// - [src] 源图片, 建议已经灰度化了. 否则二值化的输出结果可能有问题
/// - [threshold] 阈值,
///   - [cv.THRESH_BINARY] <=这个值的像素值变成0, 其它像素变成[maxVal]
///   - [cv.THRESH_BINARY_INV] 与[cv.THRESH_BINARY] 相反
/// - [maxVal] 限制数值的最大值
/// https:///docs.opencv.org/3.3.0/d7/d1b/group__imgproc__misc.html#gae8a4a146d1ca78c626a53577199e9c57
///
/// - [cvOtsu]
cv.Mat cvThresholdMat(
  cv.InputArray src, {
  double threshold = 127,
  double maxVal = 255,
  int type = cv.THRESH_BINARY,
}) {
  //cv.THRESH_BINARY + cv.THRESH_OTSU
  final (reThreshold, dst) = cv.threshold(src, threshold, maxVal, type);
  //debugger();
  return dst;
}

/// 自适应二值化
/// - [cv.ADAPTIVE_THRESH_MEAN_C]：阈值是邻域的平均值。
/// - [cv.ADAPTIVE_THRESH_GAUSSIAN_C]：阈值是邻域值的加权和，其中权重是高斯窗口。
cv.Mat cvAdaptiveThresholdMat(
  cv.InputArray src, {
  double maxValue = 255,
  int adaptiveMethod = cv.ADAPTIVE_THRESH_GAUSSIAN_C,
  int thresholdType = cv.THRESH_BINARY,
  int size = 11,
  double c = 2, //它只是从计算的平均值或加权平均值中减去的常数。
}) {
  return cv.adaptiveThreshold(
    src,
    maxValue,
    adaptiveMethod,
    thresholdType,
    size,
    c,
  );
}

/// 滤波处理, 降噪. 可以消除噪点.  但是会模糊边缘.
/// - [cv.blur] 平均滤波/均值滤波. 均值滤波是一种通过替换每个像素值为邻域像素的平均值来减少图像中噪声的方法。
/// - [cv.gaussianBlur] 高斯滤波. 高斯滤波通过使用高斯函数加权邻域像素值，可以更有效地减少噪声。
///   - [cv.getGaussianKernel] 创建高斯卷积核
/// - [cv.medianBlur] 中值滤波. 中值滤波替换每个像素值为邻域像素的中位数，适用于去除椒盐噪声。
/// - [cv.bilateralFilter] 双边滤波. 双边滤波是同时考虑空间距离和强度差异的滤波器，可以更好地保留边缘。
/// - [cv.filter2D] 自定义滤波器
///
/// - [cv.boxFilter] 方框滤波. 方框滤波使用均匀权重的邻域像素值来计算每个像素的新值，通常用于平滑图像。
/// - [cv.laplacian] 拉普拉斯滤波. 拉普拉斯滤波用于边缘检测，能够增强图像的细节。
/// - [cv.sobel] Sobel算子. Sobel算子用于计算图像的梯度，并计算每个像素的梯度方向和强度。
/// - [cv.scharr] Scharr算子. Scharr算子用于计算图像的梯度，并计算每个像素的梯度方向和强度。
/// - [cv.dft] 快速傅里叶变换. 快速傅里叶变换是一种用于处理图像的快速变换算法，可以计算图像的频谱。
/// - [cv.idft] 快速傅里叶逆变换. 快速傅里叶逆变换是一种用于处理图像的快速变换算法，可以计算图像的时域信号。
/// - [cv.morphologyEx] 形态学处理. 形态学处理是一种用于处理图像的滤波算法，可以进行图像的开、闭、腐蚀、膨胀、形态学梯度、顶帽和黑帽等操作。
///   - https://blog.csdn.net/qq_39507748/article/details/104539673
///
/// ## Depth combinations
/// https://docs.opencv.org/4.x/d4/d86/group__imgproc__filter.html#filter_depths
///
/// Input depth (src.depth()) | Output depth (ddepth)
/// |-------------------------|----------------------|
/// CV_8U                     |-1/CV_16S/CV_32F/CV_64F
/// CV_16U/CV_16S             |-1/CV_32F/CV_64F
/// CV_32F                    |-1/CV_32F
/// CV_64F                    |-1/CV_64F
///
/// https:///docs.opencv.org/master/d4/d86/group__imgproc__filter.html#ga27c049795ce870216ddfb366086b5a04
cv.Mat cvFilterMat(cv.InputArray src, int size) {
  final (int, int) ksize = (size, size); //窗口大小
  //return cv.blur(src, ksize);

  final sigma = 0.0;
  //return cv.gaussianBlur(src, ksize, sigma, sigmaY: sigma);

  return cv.medianBlur(src, size);

  //效果不明显
  //return cv.bilateralFilter(src, size, 75, 75);

  //锐化滤波器。
  /*final kernel = cv.Mat.from2DList([
    [0, -1, 0],
    [-1, 5, -1],
    [0, -1, 0],
    */ /*[-1, 1, 1],
    [1, -1, 1],
    [1, 1, -1],*/ /*
  ], cv.MatType.CV_8UC1);
  return cv.filter2D(src, -1, kernel);*/
}

/// 学习不同的形态学操作，如侵蚀，膨胀，开放，关闭等
/// 学习不同的函数，如：cv.erode()，cv.dilate()，cv.morphologyEx()等
///
/// - [cv.erode] 侵蚀操作
/// - [cv.dilate] 膨胀操作
/// - [cv.morphologyEx] 形态学操作
///  - [cv.MORPH_OPEN] 开操作
///  - [cv.MORPH_CLOSE] 闭操作
///  - [cv.MORPH_GRADIENT] 形态学梯度
///  - [cv.MORPH_TOPHAT] 礼帽
///  - [cv.MORPH_BLACKHAT] 黑帽
///
/// - [cv.getStructuringElement] 创建结构元素, 获得所需的卷积核。
///
/// https://opencv-python-tutorials.readthedocs.io/zh/latest/4.%20OpenCV%E4%B8%AD%E7%9A%84%E5%9B%BE%E5%83%8F%E5%A4%84%E7%90%86/4.5.%20%E5%BD%A2%E6%80%81%E5%8F%98%E6%8D%A2/
cv.Mat cvMorphologyMat(
  cv.InputArray src,
  cv.Mat kernel, {
  int operation = cv.MORPH_OPEN,
}) {
  //final kernel = cv.getStructuringElement(cv.MORPH_RECT, (size, size));
  return cv.morphologyEx(src, operation, kernel);
}

/// 查找图像梯度，边缘等
/// 学习函数：cv.Sobel()，cv.Scharr()，cv.Laplacian()
///
/// - [cv.sobel] Sobel算子是高斯联合平滑加微分运算，因此它更能抵抗噪声。
/// - [cv.scharr]
/// - [cv.laplacian] 它的计算由关系给出的图像的拉普拉斯（Laplacian）算子
///
cv.Mat cvFindGradientMat(cv.InputArray src, {int size = 5}) {
  return cv.sobel(src, -1, 1, 0, ksize: size);
  //return cv.Laplacian(src, -1);
}

/// 存储图片到指定路径
/// http://docs.opencv.org/master/d4/da8/group__imgcodecs.html#gabbc7ef1aa2edfaa87772f1202d67e0ce
bool cvSaveMat(String filePath, cv.InputArray? mat) {
  if (mat == null) {
    return false;
  }
  return cv.imwrite(filePath, mat);
}

/// 获取图片RGBA像素数组
Uint8List cvGetMatPixels(cv.InputArray mat) {
  //return mat.reshape(cn);
  /*mat.forEachPixel((row, col, pixel) {
    //debugger(when: pixel.any((num) => num != 0));
  });*/
  //mat.reshape(cn);
  return mat.data; //这个是图片的字节数组, 就是散装的RGB数据
}

/// 获取图片的宽高
(int width, int height) cvGetMatSize(cv.InputArray mat) {
  return (mat.width, mat.height);
}

/// 调整图片的大小
/// - [interpolation] 插值方式
///   - [cv.INTER_NEAREST] 就近插值
///   - [cv.INTER_LINEAR] 线性插值
/// https:///docs.opencv.org/master/da/d54/group__imgproc__transform.html#ga47a974309e9102f5f08231edc7e7529d
cv.Mat cvResizeMat(
  cv.InputArray src, {
  int? width,
  int? height,
  int interpolation = cv.INTER_LINEAR,
}) {
  if (width == null && height == null) {
    return src;
  }
  final (oldWidth, oldHeight) = cvGetMatSize(src);
  return cv.resize(src, (width ?? oldWidth, height ?? oldHeight));
}

/// 旋转图片, 只能是90°的倍数
/// - [rotateCode]
///   - [cv.ROTATE_180]
///   - [cv.ROTATE_90_CLOCKWISE]
///   - [cv.ROTATE_90_COUNTERCLOCKWISE]
/// https://docs.opencv.org/master/d2/de8/group__core__array.html#ga4ad01c0978b0ce64baa246811deeac24
cv.Mat cvRotateMat(cv.InputArray src, int rotateCode) {
  return cv.rotate(src, rotateCode);
}

/// 图像拼接, 将边缘内容差不多的图片拼接在一起
cv.Mat? cvStitchMat(List<cv.InputArray> images) {
  final stitcher = cv.Stitcher.create(mode: cv.StitcherMode.PANORAMA);
  final (status, dst) = stitcher.stitch(images.cvd);
  if (status == cv.StitcherStatus.ERR_NEED_MORE_IMGS) {
    assert(() {
      l.w("需要更多图片");
      return true;
    }());
  }
  return status == cv.StitcherStatus.OK ? dst : null;
}

/// Mat扩展
extension MatEx on cv.Mat {
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
  List<double> get matrix3 {
    final matrix3 = List<double>.filled(9, 0);
    forEachRow((row, values) {
      for (int i = 0; i < values.length; i++) {
        matrix3[i * 3 + row] = values[i].toDouble();
      }
    });
    return matrix3;
  }

  /// 转成灰度图片
  cv.Mat get gray {
    return cv.cvtColor(this, cv.COLOR_BGR2GRAY);
  }

  /// 转成RGB图片
  cv.Mat get rgb {
    return cv.cvtColor(this, cv.COLOR_BGR2RGB);
  }

  /// [cv.Mat]转成图片[UiImage]
  Future<UiImage> toUiImage() async {
    return cvImgEncodeMat(this)!.toImage();
  }

  /// 将相机内参矩阵转换成字符串, 方便传输
  /// - [MatEx.cameraMatrixString]
  /// - [MatStringEx.cameraMatrix]
  ///
  /// ```
  /// //cameraMatrix:Mat(addr=0x6000012e8890, type=CV_64FC1, rows=3, cols=3, channels=1)
  /// [[802.4764753450518, 0.0, 12.792931450932988],
  /// [0.0, 1934.0012961748434, -14.44565026590872],
  /// [0.0, 0.0, 1.0]]
  /// ```
  String cameraMatrixString() {
    final list = toList();
    final flatten = list.flatten<num>();
    return flatten.join(',');
  }

  /// 将相机畸变参数转换成字符串, 方便传输
  /// - [MatEx.distCoeffsString]
  /// - [MatStringEx.distCoeffs]
  ///
  /// ```
  /// distCoeffs:Mat(addr=0x6000012e88c0, type=CV_64FC1, rows=1, cols=5, channels=1)
  /// [[-0.7881097007309008, 2.8231170733523783, 0.02692497935255397, 0.08256194583654793, -7.601687967063381]]
  ///
  /// ```
  String distCoeffsString() {
    final list = toList();
    final flatten = list.flatten<num>();
    return flatten.join(',');
  }
}

extension MatUiImageEx on UiImage {
  /// [UiImage]图片转成[cv.Mat]
  Future<cv.Mat> toMatAsync({
    UiImageByteFormat format = UiImageByteFormat.png,
    int flags = cv.IMREAD_COLOR,
  }) async {
    final bytes = await toBytes(format);
    return cvImgDecodeMatAsync(bytes!, flags: flags);
  }
}

extension MatStringEx on String {
  /// 将存储的相机内参矩阵字符串转换成[cv.Mat]
  /// - [MatEx.cameraMatrixString]
  /// - [MatStringEx.cameraMatrix]
  ///
  /// ```
  /// 953.3601440185421,0.0,20.99147803728926, 0.0,1150.5279533663834,34.79296704018406 ,0.0,0.0,1.0
  /// ```
  cv.Mat? get cameraMatrix {
    final list = split(',').map((e) => double.parse(e)).toList();
    final cameraMatrix = cv.Mat.from2DList(
      list.to2DList(3),
      cv.MatType.CV_64FC1,
    );
    return cameraMatrix;
  }

  /// 将存储的相机畸变参数字符串转换成[cv.Mat]
  /// - [MatEx.distCoeffsString]
  /// - [MatStringEx.distCoeffs]
  ///
  /// ```
  /// -0.15912404178645986,-1.3501136289999192,0.021079322288846902,0.058574551893847956,2.2543234290446703
  /// ```
  cv.Mat? get distCoeffs {
    final list = split(',').map((e) => double.parse(e)).toList();
    final cameraMatrix = cv.Mat.from2DList(
      list.to2DList(list.length),
      cv.MatType.CV_64FC1,
    );
    return cameraMatrix;
  }
}
