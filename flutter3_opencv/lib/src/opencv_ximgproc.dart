part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/20
///
/// 在 OpenCV 中，骨架提取（Skeletonization） 或 细化（Thinning） 是图像处理中一种重要的形态学技术，目的是将二值图像中的物体压缩成宽度仅为 1 个像素的连通中心线。
extension MatXimgprocEx on cv.Mat {
  /// 细化, 必须输入灰度图片(单通道数据)
  ///  - [cv.ximgproc.THINNING_ZHANGSUEN]
  ///  - [cv.ximgproc.THINNING_GUOHALL]
  Future<UiImage?> thinning({
    int thinningType = cv.ximgproc.THINNING_ZHANGSUEN,
  }) async {
    final mat = this;
    return cv.ximgproc.thinning(mat).uiImage;
  }
}
