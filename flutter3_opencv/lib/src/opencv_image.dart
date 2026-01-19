part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
//MARK: - UiImage
extension MatUiImageEx on UiImage {
  /// 获取4通道颜色对应的[cv.Mat]
  /// - [toMatAsync]
  @alias
  Future<cv.Mat> get cvMat async => await toMatAsync();

  /// 获取灰度颜色对应的[cv.Mat]
  Future<cv.Mat> get cvGrayMat async =>
      await toMatAsync(flags: cv.IMREAD_GRAYSCALE);

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
}
