part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/20
///
/// 在 OpenCV 中，骨架提取（Skeletonization） 或 细化（Thinning） 是图像处理中一种重要的形态学技术，目的是将二值图像中的物体压缩成宽度仅为 1 个像素的连通中心线。
extension MatXimgprocEx on cv.Mat {
  /// 细化算法, 必须输入单通道数据
  cv.Mat cvThinning({int thinningType = cv.ximgproc.THINNING_ZHANGSUEN}) =>
      cv.ximgproc.thinning(this, thinningType: thinningType);

  /// 细化, 必须输入灰度图片(单通道数据)
  ///  - [cv.ximgproc.THINNING_ZHANGSUEN]
  ///  - [cv.ximgproc.THINNING_GUOHALL]
  Future<UiImage?> thinning({
    int thinningType = cv.ximgproc.THINNING_ZHANGSUEN,
  }) => cvThinning(thinningType: thinningType).uiImage;

  /// 使用形态学细化
  Future<UiImage?> morphologyThinning({int kSize = 3}) {
    cv.Mat img = this;
    cv.Mat temp;
    cv.Mat skel = cv.Mat.zeros(img.rows, img.cols, cv.MatType.CV_8UC1);
    // 定义 3x3 结构元素
    kSize = kSize.odd;
    final kernel = cv.getStructuringElement(cv.MORPH_CROSS, (kSize, kSize));
    bool done = false;
    while (!done) {
      // Step 1: 腐蚀
      final eroded = cv.erode(img, kernel);
      // Step 2: 开运算 (消除小物体/平滑边界)
      temp = cv.dilate(eroded, kernel);
      temp = cv.subtract(img, temp);
      // Step 3: 将提取出的边缘骨架合并
      skel = cv.bitwiseOR(skel, temp);
      cv.copyTo(eroded, img);
      // 如果所有像素都被腐蚀完，则退出
      if (cv.countNonZero(img) == 0) done = true;
    }
    return skel.uiImage;
  }

  //MARK: - morphology 形态学

  /// 腐蚀
  /// - [cv.erode] 侵蚀操作
  /// - 腐蚀 (Erosion): 核在图像上滑动，只有当核覆盖的所有像素都是 1 时，中心像素才保持 1。效果是“收缩”白色区域，去除细小的噪声。
  /// - 如果结构元素内的像素全部为 1，则中心点保留为 1，否则为 0。
  Future<UiImage?> erode({int kSize = 3}) {
    cv.Mat img = this;
    kSize = kSize.odd;
    final kernel = cv.getStructuringElement(cv.MORPH_CROSS, (kSize, kSize));
    return cv.erode(img, kernel).uiImage;
  }

  /// 膨胀
  /// - [cv.dilate] 膨胀操作
  /// - 膨胀 (Dilation): 核在图像上滑动，只要核覆盖范围内有一个像素是 1，中心像素就变为 1。效果是“扩张”白色区域，填充小孔洞。
  /// - 如果结构元素内只要有一个像素为 1，则中心点变为 1。
  Future<UiImage?> dilate({int kSize = 3}) {
    cv.Mat img = this;
    kSize = kSize.odd;
    final kernel = cv.getStructuringElement(cv.MORPH_CROSS, (kSize, kSize));
    return cv.dilate(img, kernel).uiImage;
  }

  /// 学习不同的形态学操作，如侵蚀，膨胀，开放，关闭等
  /// [cvMorphologyMat]
  Future<UiImage?> morphology({int operation = cv.MORPH_OPEN, int kSize = 3}) {
    cv.Mat img = this;
    kSize = kSize.odd;
    final kernel = cv.getStructuringElement(cv.MORPH_CROSS, (kSize, kSize));
    return cvMorphologyMat(img, kernel, operation: operation).uiImage;
  }
}
