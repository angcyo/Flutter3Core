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

  /// 获取指定x/y的颜色
  Color getColor(int x, int y) {
    final list = atPixel(x, y);
    if (list.length == 4) {
      //BGRA
      final b = list[0].round();
      final g = list[1].round();
      final r = list[2].round();
      final a = list[3].round();
      return Color.fromARGB(a, r, g, b);
    } else if (list.length == 3) {
      //BGR
      final b = list[0].round();
      final g = list[1].round();
      final r = list[2].round();
      final a = 255;
      return Color.fromARGB(a, r, g, b);
    }
    final gray = list[0].round();
    return Color.fromARGB(255, gray, gray, gray);
  }

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

  /// 将黑色像素变成透明, 并返回带有透明像素的Mat
  /// @return 4通道图片
  cv.Mat get transparentBlack {
    //return cv.cvtColor(this, cv.COLOR_GRAY2RGB);
    final thresh = 10.0; //透明阈值, 灰度<此值视为透明颜色
    if (channels == 1) {
      final gray = this;
      final alpha = cv.threshold(gray, thresh, 255, cv.THRESH_BINARY).$2;
      return cv.merge(cv.VecMat.fromList([gray, gray, gray, alpha]));
    } else if (channels == 3) {
      final gray = cv.cvtColor(this, cv.COLOR_BGR2GRAY);
      final alpha = cv.threshold(gray, thresh, 255, cv.THRESH_BINARY).$2;
      final bgr = cv.split(this);
      return cv.merge(cv.VecMat.fromList([bgr[0], bgr[1], bgr[2], alpha]));
    } else if (channels == 4) {
      final gray = cv.cvtColor(this, cv.COLOR_BGRA2GRAY);
      final alpha = cv.threshold(gray, thresh, 255, cv.THRESH_BINARY).$2;
      final bgr = cv.split(this);
      return cv.merge(cv.VecMat.fromList([bgr[0], bgr[1], bgr[2], alpha]));
    }
    return this;
  }

  /// 将灰度图进行二值化处理
  /// - [thresh] 阈值>这个值的灰度值会被设置为255
  cv.Mat cvThreshold({double thresh = 10}) =>
      cv.threshold(this, thresh, 255, cv.THRESH_BINARY).$2;

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

  /// 对于细化后的单像素骨架，概率霍夫直线变换（Progressive Probabilistic Hough Transform） 是最直接的方案。
  /// 1. 假设 img 是你已经细化好的二值图像
  /// 2. 使用概率霍夫变换提取线段
  cv.Mat cvHoughLinesP({
    double rho = 1 /*距离分辨率（像素）*/,
    double theta = pi / 180 /*角度分辨率（弧度）*/,
    int threshold = 20 /*累加平面阈值（票数越多越可能是线）*/,
    double minLineLength = 2 /*最小线段长度*/,
    double maxLineGap = 2 /*线段间允许的最大缺口*/,
  }) {
    //cv.HoughLines(this, rho, theta, threshold);
    return cv.HoughLinesP(
      this,
      rho,
      theta,
      threshold,
      minLineLength: minLineLength,
      maxLineGap: maxLineGap,
    );
  }

  //MARK: - other

  /// # 几何变换 (Geometric Transformations)
  /// 原理：通过坐标映射改变像素位置。分为仿射变换（平行性不变）和透视变换（直线投影不变）。
  /// - [cv.resize]
  /// - [cv.warpAffine] 仿射变换（旋转、平移、缩放）。
  /// - [cv.getRotationMatrix2D]
  /// - [cv.warpPerspective] 透视变换（矫正倾斜的文档）。
  /// - [cv.remap]
  ///
  /// # 图像滤波与平滑 (Image Filtering)
  /// 原理：通过滑动窗口（Kernel/核）与图像进行卷积运算，达到去噪、模糊或锐化效果。
  /// - [cv.filter2D] 自定义卷积核进行线性滤波。
  /// - [cv.gaussianBlur] 高斯滤波，基于正态分布权重，适合滤除高斯噪声。
  ///   - [cv.BORDER_CONSTANT]: 填固定值（如黑边）。
  ///   - [cv.BORDER_REFLECT]: 镜像反射（例如 abcde | edcba）。
  ///   - [cv.BORDER_REPLICATE]: 复制边缘（例如 aaaaa | abcde）。
  /// - [cv.medianBlur] 中值滤波，取窗口中位数，对椒盐噪声效果极佳。
  /// - [cv.bilateralFilter] 双边滤波，考虑空间距离和像素差值，能在平滑图像的同时保留边缘。
  ///
  /// # 边缘检测与图像梯度 (Image Gradients & Edge Detection)
  /// 原理：计算图像一阶或二阶导数，捕捉像素值剧烈变化的区域。
  /// - [cv.sobel] 计算水平或垂直梯度（基于 Sobel 算子）。
  /// - [cv.laplacian] 二阶导数，对图像细节非常敏感。
  /// - [cv.canny] 目前最主流的边缘检测算法，包含高斯滤波、梯度计算、非极大值抑制和双阈值滞后处理。
  ///
  /// # 形态学操作 (Morphological Operations)
  /// 原理：基于集合论，通过结构元素（Kernel）在图像上移动，常用于二值图像。
  /// - [cv.erode] 腐蚀（减小高亮区域，消除细小噪点）。
  /// - [cv.dilate] 膨胀（扩大高亮区域，连接断裂部分）。
  /// - [cv.morphologyEx] 高级操作，如 开运算（先腐蚀后膨胀，去伪影）和 闭运算（先膨胀后腐蚀，填补空洞）。
  ///
  /// # 直方图处理 (Histogram Processing)
  /// 原理：分析图像像素强度分布，进行对比度增强。
  /// - [cv.calcHist] 计算图像直方图。
  /// - [cv.equalizeHist] 直方图均衡化（全局增强对比度）。
  /// - [cv.createCLAHE] 限制对比度的自适应直方图均衡化（局部增强，避免噪声过度放大）。
  ///
  /// # 轮廓与形状分析 (Contours & Shape Analysis)
  /// 原理：基于拓扑结构提取闭合边界。
  /// - [cv.findContours] 提取轮廓。
  /// - [cv.drawContours] 绘制轮廓。
  /// - [cv.boundingRect] 计算外接矩形。
  /// - [cv.arcLength].[cv.contourArea] 计算周长与面积。
  /// - [cv.approxPolyDP] 多边形拟合，用于形状简化。
  ///
  /// # 霍夫变换 (Hough Transforms)
  /// 原理：将图像空间转换到参数空间，通过累加器投票检测几何图形。
  void _other() {
    //cv.resize(src, dsize)
    //cv.warpAffine(src, dsize)
    //cv.getRotationMatrix2D(src, dsize)
    //cv.warpPerspective(src, dsize)

    //cv.filter2D()
    //cv.gaussianBlur()
    //cv.medianBlur()
    //cv.bilateralFilter()

    //cv.sobel()
    //cv.laplacian()
    //cv.canny(image, threshold1, threshold2)

    //cv.erode()
    //cv.dilate()
    //cv.morphologyEx()

    //cv.calcHist()
    //cv.equalizeHist()
    //cv.createCLAHE()

    //cv.findContours()
    //cv.drawContours()
    //cv.boundingRect()
    //cv.arcLength()
    //cv.contourArea()
    //cv.approxPolyDP()

    //cv.findHomographyUsac(srcPoints, dstPoints, params)
  }
}

/// 拟合轮廓
cv.Contours cvApproxPolyDP(
  cv.Contours contours, {
  double epsilon = 0.02 /*近似精度*/,
  int maxVertices = 1000 /*最大顶点数*/,
  bool closed = true /*是否闭合*/,
}) {
  //拟合轮廓
  // 计算轮廓周长，True 表示轮廓封闭
  //final length = cv.arcLength(contour, false);
  // 通常取周长的 1% 到 5% 作为 epsilon
  // 0.02 是一个经典的平衡点
  List<List<cv.Point>> pts = [];
  for (final contour in contours) {
    final contour2 = cv.approxPolyDP(contour, epsilon /*length * 0.02*/, false);
    pts.add(contour2.iterator.toList());
  }
  return cv.VecVecPoint.fromList(pts);
}
