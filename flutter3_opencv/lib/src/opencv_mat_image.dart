part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/19
///
///
extension MatImageEx on cv.Mat {
  /// 获取彩色图片的直方图信息`histogram`
  /// - Channels: 你要统计哪个通道？（如灰度图为 [0]，彩色图 BGR 分别为 [0, 1, 2]）。
  /// - Bins (histSize): 你要把 0-255 分成多少份？（默认通常是 256，即每一级亮度一个桶）。
  /// - Ranges: 像素值的范围，通常是 [0, 256]。
  ///
  /// - [fromThreshold]
  /// - [toThreshold]
  Future<List<List<double>>> calcHist({
    double alphaThreshold = 127,
    double fromThreshold = 0 /*直方图开始的灰度值>=*/,
    double toThreshold = 256 /*直方图结束的灰度值<*/,
  }) async {
    final mat = this;
    //debugger();
    cv.Mat mask = cv.Mat.empty();
    if (!mat.isGray) {
      final rgba = cv.split(mat); //BGRA
      //使用A通道, 创建掩码
      //final mask = cv.inRange(rgba[3], cv.Scalar(255), cv.Scalar(255));
      //将所有A通道中>127的值改成255, 其余改成0
      final (threshold, dst) = cv.threshold(
        rgba[3],
        alphaThreshold /*阈值*/,
        255 /*新值*/,
        cv.THRESH_BINARY /*cv.THRESH_BINARY_INV*/,
      );
      mask = dst;
    }

    /*// 创建掩码：只有 Alpha >= 255 (不透明) 的地方才是 255 (白色)
    final (threshold, mask) = cv.threshold(mat, 128, 255, cv.THRESH_BINARY);
    debugger();*/

    //enumerate;
    //final mat = await toMatAsync(flags: cv.IMREAD_GRAYSCALE, format: format);
    final res = cv.calcHist(
      cv.VecMat.fromList([mat.isGray ? mat : mat.gray]),
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
    final mat = this;
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

  //MARK: filter

  /// 中值滤波 (Median Blur)
  /// - 能极好地保护边缘，但如果核太大，图像会看起来像“油画”。
  /// - 极快，不损边缘
  /// - 容易产生块状感
  Future<UiImage?> medianBlur({int kSize = 5 /*卷积核的大小, 影响性能, 必须要是基数*/}) async {
    final mat = this;
    if (kSize % 2 == 0) {
      kSize += 1;
    }
    return cv.medianBlur(mat, kSize).uiImage;
  }

  /// 高斯模糊
  /// - （边缘会变模糊）来换取平滑。
  /// - 极快，最通用
  /// - 模糊边缘
  Future<UiImage?> gaussianBlur({
    int kSize = 5 /*卷积核的大小, 影响性能, 必须要是基数*/,
    double sigmaX = kSigma /*高斯核的sigma值, 影响性能*/,
  }) async {
    final mat = this;
    if (kSize % 2 == 0) {
      kSize += 1;
    }
    return cv.gaussianBlur(mat, (kSize, kSize), sigmaX).uiImage;
  }

  /// 双边滤波 (Bilateral Filter)
  ///
  /// - [diameter] 像素邻域直径
  /// - [sigmaColor]: 颜色空间标准差；
  /// - [sigmaSpace] 坐标空间标准差
  ///
  /// - 保护轮廓清晰
  /// - 运算速度中等
  Future<UiImage?> bilateralFilter({
    int diameter = 9,
    double sigmaColor = 75,
    double sigmaSpace = 75,
  }) async {
    final mat = this;
    return cv.bilateralFilter(mat, diameter, sigmaColor, sigmaSpace).uiImage;
  }

  /// 非局部均值去噪 (Non-Local Means Denoising)
  ///
  /// - [h] (Luminance H - 亮度分量去噪强度)
  ///   - 决定了算法对亮度噪声的过滤程度。
  /// - [hColor] (Color H - 颜色分量去噪强度)
  ///   - 专门针对彩色噪声（Color Artifacts）的强度。
  /// - [templateWindowSize] (模板窗口大小)
  ///   - 计算相似度时使用的小滑块的大小（以像素为单位）。必须是奇数。
  /// - [searchWindowSize] (搜索窗口大小)
  ///   - 算法寻找相似块的范围。必须是奇数。
  ///
  /// - 这是目前 OpenCV 中去噪效果最自然的方法，能保留精细纹理，但计算开销非常大。
  /// - 细节保留最好
  /// - 非常慢
  ///
  /// ```
  /// # 实验建议参数
  /// # 轻微去噪：h=3, hColor=3, template=7, search=21
  /// # 强力去噪：h=10, hColor=10, template=7, search=21
  /// ```
  Future<UiImage?> fastNlMeansDenoisingColored({
    double h = 3,
    double hColor = 3,
    int templateWindowSize = 7,
    int searchWindowSize = 21,
  }) async {
    final mat = this;
    return cv
        .fastNlMeansDenoisingColored(
          mat,
          h: h,
          hColor: hColor,
          templateWindowSize: templateWindowSize,
          searchWindowSize: searchWindowSize,
        )
        .uiImage;
  }

  //MARK: find

  /// 边缘检测
  Future<UiImage?> canny() async {
    return null;
  }

  /// 查看轮廓, 请先将图片二值化
  /// - [mode] 检索模式
  ///   - [cv.RETR_EXTERNAL]: 只提取最外层轮廓。
  ///   - [cv.RETR_LIST]: 提取所有轮廓，但不建立等级关系。它们在层级上都是“平级”的（只有 Next 和 Previous）。
  ///   - [cv.RETR_TREE]: 提取所有轮廓并建立完整的层级家族树。
  ///   - [cv.RETR_CCOMP]: 将轮廓组织成两级。一级是外部边界，二级是孔洞边界。
  /// - [method] 近似方法
  ///   - [cv.CHAIN_APPROX_NONE]: 存储所有边界点。
  ///   - [cv.CHAIN_APPROX_SIMPLE]: （推荐） 压缩水平、垂直和对角线段，仅保留端点。例如，一个矩形只需 4 个点。
  Future<UiImage?> findContours({
    //--
    bool enableBlur = true,
    int kSize = 5 /*卷积核的大小, 影响性能*/,
    double sigmaX = kSigma /*高斯核的sigma值, 影响性能*/,
    //--
    int mode = cv.RETR_TREE,
    int method = cv.CHAIN_APPROX_SIMPLE,
    //--
    Size? imageSize,
    UiImage? originImage /*原图*/,
  }) async {
    //debugger();
    cv.Mat mat = this;
    //高斯模糊 - 消除噪点
    if (enableBlur) {
      mat = cv.gaussianBlur(mat, (kSize, kSize), sigmaX);
    }
    //查找轮廓
    final (contours, hierarchy) = cv.findContours(mat, mode, method);
    //debugger();
    for (final hierarchy in hierarchy) {
      //Next (下一个): 与当前轮廓处于同一层级的下一个轮廓的索引。
      //Previous (上一个): 与当前轮廓处于同一层级的上一个轮廓的索引。
      //First_Child (第一个子轮廓): 当前轮廓内部包含的第一个子轮廓的索引。
      //Parent (父轮廓): 包含当前轮廓的外部轮廓索引。
      hierarchy.val1;
      hierarchy.val2;
      hierarchy.val3;
      hierarchy.val4;
    }
    return drawImage(imageSize ?? originImage?.imageSize ?? Size.zero, (
      canvas,
    ) {
      if (originImage != null) {
        canvas.drawImage(originImage, .zero, Paint());
      }
      for (final contour in contours) {
        final color = randomColor();
        for (int i = 0; i < contour.length - 1; i++) {
          final point = contour[i];
          final nextPoint = contour[i + 1];
          canvas.drawLine(
            Offset(point.x.roundToDouble(), point.y.roundToDouble()),
            Offset(nextPoint.x.roundToDouble(), nextPoint.y.roundToDouble()),
            Paint()..color = color,
          );
        }
        //--
        /*for (final point in contour) {
          canvas.drawCircle(
            Offset(point.x.roundToDouble(), point.y.roundToDouble()),
            1,
            Paint()..color = color,
          );
        }*/
      }
    });

    /*final ret = cv.drawContours(
      mat.gray2rgb,
      contours,
      0,
      cv.Scalar.fromRgb(250, 255, 100),
      thickness: 1,
    );
    //debugger();
    return ret.uiImage;*/
    //debugger();
    return null;
  }
}
