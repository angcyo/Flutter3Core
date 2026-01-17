part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
/// 图片一帧的数据
class ImageFrameInfo {
  //MARK: - image

  /// 图片数据
  UiImage? uiImage;

  int? get width => uiImage?.width;

  int? get height => uiImage?.height;

  //MARK: - output

  /// 处理后输出的图片
  UiImage? _resultImage;

  /// 处理后的图片
  UiImage? get outputImage => _resultImage ?? uiImage;

  set outputImage(UiImage? value) {
    _resultImage = value;
  }

  /// 图片直方图数据 `histogram`
  List<List<double>>? histData;

  ImageFrameInfo({this.uiImage});

  /// 使用[uiImage]更新直方图数据
  @api
  Future<bool> updateHistData({
    UiImage? image,
    UiImageByteFormat format = UiImageByteFormat.png,
  }) async {
    final ret = await (image ?? uiImage)?.calcHist(format: format);
    histData = ret;
    return ret != null;
  }
}
