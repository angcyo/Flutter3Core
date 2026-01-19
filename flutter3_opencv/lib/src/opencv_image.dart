part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
//MARK: - UiImage
extension MatUiImageEx on UiImage {
  /// - [toMatAsync]
  @alias
  Future<cv.Mat> get cvMat async => await toMatAsync();

  /// [UiImage]图片转成[cv.Mat]
  ///
  /// - [cv.IMREAD_GRAYSCALE] 读取灰度图片[cv.MatType.CV_8UC1]
  /// - [cv.IMREAD_COLOR] 读取彩色图片[cv.MatType.CV_8UC3]
  /// - [cv.IMREAD_UNCHANGED] 读取所有通道[cv.MatType.CV_8UC4]
  ///
  /// 可以使用 [cv.cvtColor] 进行颜色转换
  Future<cv.Mat> toMatAsync({
    UiImageByteFormat format = UiImageByteFormat.png,
    int flags = cv.IMREAD_UNCHANGED,
  }) async {
    final bytes = await toBytes(format);
    return cvImgDecodeMatAsync(bytes!, flags: flags);
  }

  /// 获取图片的直方图信息`histogram`
  /// - Channels: 你要统计哪个通道？（如灰度图为 [0]，彩色图 BGR 分别为 [0, 1, 2]）。
  /// - Bins (histSize): 你要把 0-255 分成多少份？（默认通常是 256，即每一级亮度一个桶）。
  /// - Ranges: 像素值的范围，通常是 [0, 256]。
  ///
  /// - [fromThreshold]
  /// - [toThreshold]
  Future<List<List<double>>> calcHist({
    UiImageByteFormat format = UiImageByteFormat.png,
    double alphaThreshold = 127,
    double fromThreshold = 0 /*直方图开始的灰度值>=*/,
    double toThreshold = 256 /*直方图结束的灰度值<*/,
  }) async {
    final mat = await toMatAsync(format: format);
    final rgba = cv.split(mat); //BGRA
    //使用A通道, 创建掩码
    //final mask = cv.inRange(rgba[3], cv.Scalar(255), cv.Scalar(255));
    //将所有A通道中>127的值改成255, 其余改成0
    final (threshold, mask) = cv.threshold(
      rgba[3],
      alphaThreshold /*阈值*/,
      255 /*新值*/,
      cv.THRESH_BINARY /*cv.THRESH_BINARY_INV*/,
    );

    /*// 创建掩码：只有 Alpha >= 255 (不透明) 的地方才是 255 (白色)
    final (threshold, mask) = cv.threshold(mat, 128, 255, cv.THRESH_BINARY);
    debugger();*/

    //enumerate;
    //final mat = await toMatAsync(flags: cv.IMREAD_GRAYSCALE, format: format);
    final res = cv.calcHist(
      cv.VecMat.fromList([mat.gray]),
      cv.VecI32.fromList([0]), // Channels
      mask /*cv.Mat.empty()*/,
      cv.VecI32.fromList([256]), // Bins
      cv.VecF32.fromList([fromThreshold, toThreshold]), // Ranges
    );
    return res.toDoubleList();
  }

  /// 二值化
  /// - [threshold] 阈值
  /// - [invert] 是否反转
  Future<UiImage?> threshold({
    double threshold = 127,
    bool invert = false,
  }) async {
    final mat = await cvMat;
    return cv
        .threshold(
          mat,
          threshold,
          255,
          invert ? cv.THRESH_BINARY_INV : cv.THRESH_BINARY,
        )
        .$2
        .uiImage;
  }
}
