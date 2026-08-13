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
    kSize = kSize.odd;
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
    kSize = kSize.odd;
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

  /// 边缘检测, 寻找亮度突变的点
  /// - Canny 算法并不是一个简单的卷积，而是一套完整的流水线：
  ///   - ① 高斯滤波 (Noise Reduction)
  ///   - ② 计算梯度幅值和方向 (Gradient Calculation)
  ///   - ③ 非极大值抑制 (Non-Maximum Suppression)
  ///   - ④ 双阈值检测 (Double Thresholding)
  ///   - ⑤ 滞后边界跟踪 (Edge Tracking by Hysteresis)
  ///
  /// 通常建议 maxVal : minVal 的比例在 2:1 到 3:1 之间。
  /// - [threshold1]: minVal（低阈值）。
  /// - [threshold2]: maxVal（高阈值）。
  /// - [apertureSize]: Sobel 算子的核大小，默认是 3。
  /// - [l2gradient]: 计算梯度幅值的公式。默认为 False（使用 $L1$ 范数 $|G_x| + |G_y|$），设为 True 则使用更精确的 $L2$ 范数（欧几里得距离）。
  /// @return 边缘检测结果[CvMatType.CV_8UC1], [debug]下额外返回调试图片
  Future<(cv.Mat, UiImage?)> canny({
    double threshold1 = 100,
    double threshold2 = 200,
    int apertureSize = 3,
    bool l2gradient = false,
    //--
    bool? debug,
    Size? imageSize,
    UiImage? originImage /*原图*/,
  }) async {
    final mat = this;
    final retMat = cv.canny(
      mat,
      threshold1,
      threshold2,
      apertureSize: apertureSize,
      l2gradient: l2gradient,
    );
    //debugger();
    if (debug == true) {
      final ret = await retMat.transparentBlack.uiImage;
      final image = await drawImage(
        imageSize ?? originImage?.imageSize ?? Size.zero,
        (canvas) {
          if (originImage != null) {
            canvas.drawImage(originImage, .zero, Paint());
          }
          if (ret != null) {
            canvas.drawImage(ret, .zero, Paint());
          }
        },
      );
      return (retMat, image);
    }
    return (retMat, null);
  }

  /// 查看轮廓, 寻找物体的整体边界和形状. 请先将图片二值化
  /// - [resultObb] 是否返回最小外接矩形. 方向包围盒（Oriented Bounding Box）
  /// - [mode] 检索模式
  ///   - [cv.RETR_EXTERNAL]: 只提取最外层轮廓。
  ///   - [cv.RETR_LIST]: 提取所有轮廓，但不建立等级关系。它们在层级上都是“平级”的（只有 Next 和 Previous）。
  ///   - [cv.RETR_TREE]: 提取所有轮廓并建立完整的层级家族树。
  ///   - [cv.RETR_CCOMP]: 将轮廓组织成两级。一级是外部边界，二级是孔洞边界。
  /// - [method] 近似方法
  ///   - [cv.CHAIN_APPROX_NONE]: 存储所有边界点。
  ///   - [cv.CHAIN_APPROX_SIMPLE]: （推荐） 压缩水平、垂直和对角线段，仅保留端点。例如，一个矩形只需 4 个点。
  ///
  /// - [epsilon] 曲线拟合使能入参
  ///   - 核心参数（阈值）。表示近似精度。它是原始曲线与近似多边形之间的最大距离。
  ///   - 值越小： 拟合越精细，顶点越多，越接近原图。
  ///   - 值越大： 拟合越粗糙，顶点越少，看起来更像几何形。
  ///
  /// - [cv.threshold] 将灰度值>=thresh的像素全部变成`maxval`
  ///   - [cvThresholdMat]
  /// - [cv.contourArea] 计算轮廓的面积
  /// - [cv.minAreaRect] 计算最小外接旋转矩形
  /// - [cv.boxPoints] 计算旋转矩形的顶点
  ///
  /// @return 轮廓坐标数据, [debug]下额外返回调试图片
  Future<(cv.Contours, UiImage?)> findContours({
    //--
    bool enableBlur = true,
    int kSize = 5 /*卷积核的大小, 影响性能*/,
    double sigmaX = kSigma /*高斯核的sigma值, 影响性能*/,
    //--
    int mode = cv.RETR_TREE,
    int method = cv.CHAIN_APPROX_SIMPLE,
    //--
    double? epsilon /*拟合精度阈值*/,
    //--
    bool? debug,
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
    final contours2 = epsilon != null
        ? cvApproxPolyDP(contours, epsilon: epsilon)
        : contours;
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
    if (debug == true) {
      final debugImage = await drawImage(
        imageSize ?? originImage?.imageSize ?? Size.zero,
        (canvas) {
          if (originImage != null) {
            canvas.drawImage(originImage, .zero, Paint());
          }
          for (final contour in contours2) {
            final color = randomColor();
            for (int i = 0; i < contour.length - 1; i++) {
              final point = contour[i];
              final nextPoint = contour[i + 1];
              canvas.drawLine(
                Offset(point.x.roundToDouble(), point.y.roundToDouble()),
                Offset(
                  nextPoint.x.roundToDouble(),
                  nextPoint.y.roundToDouble(),
                ),
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
        },
      );
      return (contours2, debugImage);
    }

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
    return (contours2, null);
  }

  ///- [findContours]
  ///- [findContoursPath]
  Future<(List<(String /*svg path*/, double? /*obb旋转弧度*/)>, UiImage?)>
  findContoursPath({
    //--
    bool? resultObb,
    int digits = 3 /*小数点位数*/,
    //--
    bool enableBlur = true,
    int kSize = 5 /*卷积核的大小, 影响性能*/,
    double sigmaX = kSigma /*高斯核的sigma值, 影响性能*/,
    //--
    int? mode,
    int method = cv.CHAIN_APPROX_SIMPLE,
    //--
    double? epsilon /*拟合精度阈值*/,
    //--
    bool? debug,
    Size? imageSize,
    UiImage? originImage /*原图*/,
  }) async {
    //debugger();
    mode ??= resultObb == true ? cv.RETR_EXTERNAL : cv.RETR_TREE;
    cv.Mat mat = this;
    //高斯模糊 - 消除噪点
    if (enableBlur) {
      mat = cv.gaussianBlur(mat, (kSize, kSize), sigmaX);
    }
    //查找轮廓
    final (contours, hierarchy) = cv.findContours(mat, mode, method);
    final contoursX = epsilon != null
        ? cvApproxPolyDP(contours, epsilon: epsilon)
        : contours;
    //debugger();
    assert(() {
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
      return true;
    }());
    final data = <(String, double?)>[];
    if (resultObb == true) {
      for (final contour in contoursX) {
        final obb = cv.minAreaRect(contour);
        //左下，左上，右上，右下
        final obbPoints = cv.boxPoints(obb);
        //debugger();
        //左上 右上 右下 左下
        final ltx = obbPoints[1].x;
        final lty = obbPoints[1].y;
        final rtx = obbPoints[2].x;
        final rty = obbPoints[2].y;
        final rbx = obbPoints[3].x;
        final rby = obbPoints[3].y;
        final lbx = obbPoints[0].x;
        final lby = obbPoints[0].y;
        /*final ltx = obb.center.x - obb.size.width / 2;
        final lty = obb.center.y - obb.size.height / 2;
        final rtx = obb.center.x + obb.size.width / 2;
        final rty = obb.center.y - obb.size.height / 2;
        final rbx = obb.center.x + obb.size.width / 2;
        final rby = obb.center.y + obb.size.height / 2;
        final lbx = obb.center.x - obb.size.width / 2;
        final lby = obb.center.y + obb.size.height / 2;*/
        final svgPath =
            "M ${ltx.toStringAsFixed(digits)},${lty.toStringAsFixed(digits)}"
            "L ${rtx.toStringAsFixed(digits)},${rty.toStringAsFixed(digits)}"
            "L ${rbx.toStringAsFixed(digits)},${rby.toStringAsFixed(digits)}"
            "L ${lbx.toStringAsFixed(digits)},${lby.toStringAsFixed(digits)} Z";
        data.add((svgPath, obb.angle));
      }

      if (debug == true) {
        final debugImage = await drawImage(
          imageSize ?? originImage?.imageSize ?? Size.zero,
          (canvas) {
            if (originImage != null) {
              canvas.drawImage(originImage, .zero, Paint());
            }
            for (final contour in contoursX) {
              final color = randomColor();
              final obb = cv.minAreaRect(contour);
              //左下，左上，右上，右下
              final obbPoints = cv.boxPoints(obb);
              canvas.drawPoints(
                .polygon,
                obbPoints
                    .mapFlat(
                      (e) => [
                        Offset(obbPoints[0].x, obbPoints[0].y),
                        Offset(obbPoints[1].x, obbPoints[1].y),
                        Offset(obbPoints[2].x, obbPoints[2].y),
                        Offset(obbPoints[3].x, obbPoints[3].y),
                      ],
                    )
                    .toList(),
                Paint()..color = color,
              );
              /*canvas.drawRect(
                Rect.fromCenter(
                  center: Offset(obb.center.x, obb.center.y),
                  width: obb.size.width,
                  height: obb.size.height,
                ),
                Paint()
                  ..color = color
                  ..style = .stroke,
              );*/

              /*for (final point in contour) {
          canvas.drawCircle(
            Offset(point.x.roundToDouble(), point.y.roundToDouble()),
            1,
            Paint()..color = color,
          );
        }*/
            }
          },
        );
        return (data, debugImage);
      }
    } else {
      for (final contour in contoursX) {
        final pathBuilder = StringBuffer();
        for (int i = 0; i < contour.length - 1; i++) {
          final point = contour[i];
          final nextPoint = contour[i + 1];
          if (pathBuilder.isEmpty) {
            pathBuilder.write(
              "M ${point.x.toStringAsFixed(digits)},${point.y.toStringAsFixed(digits)}",
            );
          }
          pathBuilder.write(
            "L ${nextPoint.x.toStringAsFixed(digits)},${nextPoint.y.toStringAsFixed(digits)}",
          );
        }
        data.add((pathBuilder.toString(), null));
      }
      if (debug == true) {
        final debugImage = await drawImage(
          imageSize ?? originImage?.imageSize ?? Size.zero,
          (canvas) {
            if (originImage != null) {
              canvas.drawImage(originImage, .zero, Paint());
            }
            for (final contour in contoursX) {
              final color = randomColor();
              for (int i = 0; i < contour.length - 1; i++) {
                final point = contour[i];
                final nextPoint = contour[i + 1];
                canvas.drawLine(
                  Offset(point.x.roundToDouble(), point.y.roundToDouble()),
                  Offset(
                    nextPoint.x.roundToDouble(),
                    nextPoint.y.roundToDouble(),
                  ),
                  Paint()
                    ..color = color
                    ..style = .stroke,
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
          },
        );
        return (data, debugImage);
      }
    }
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
    return (data, null);
  }

  //MARK: grabCut

  /// 移除图片背景
  /// GrabCut 要求 8-bit 3-channel 图像, 通常为 BGR/RGB
  ///
  /// - [iterCount] 迭代次数，默认为 5
  /// ```
  /// (-5:Bad argument) image must have CV_8UC3 type in function 'cv::grabCut'
  /// ```
  Future<UiImage?> removeBackground({int iterCount = 5}) async {
    final img = this;

    // 3. 定义包含目标物体的矩形框 (x, y, width, height)
    // 注意：矩形框必须完整包含目标前景，且尽量少留背景空间
    final rect = cv.Rect(
      (img.cols * 0.1).toInt(), // x 0.1
      (img.rows * 0.1).toInt(), // y 0.1
      (img.cols * 0.8).toInt(), // width 0.8
      (img.rows * 0.8).toInt(), // height 0.8
    );

    // 4. 初始化 GrabCut 所需的参数
    // mask: 单通道 8-bit 图像，大小与原图一致
    final mask = cv.Mat.zeros(img.rows, img.cols, cv.MatType.CV_8UC1);

    // bgdModel 与 fgdModel: 必须为 1x65 的 64 位浮点数矩阵 (CV_64FC1)
    final bgdModel = cv.Mat.zeros(1, 65, cv.MatType.CV_64FC1);
    final fgdModel = cv.Mat.zeros(1, 65, cv.MatType.CV_64FC1);

    // 5. 执行 GrabCut 算法
    // iterCount: 迭代轮数，推荐设为 5
    // mode: GC_INIT_WITH_RECT 表示基于矩形框初始化
    //print('正在运行 GrabCut 前景分割算法...');
    cv.grabCut(
      img,
      mask,
      rect,
      bgdModel,
      fgdModel,
      iterCount,
      mode: cv.GC_INIT_WITH_RECT,
    );

    // 6. 后处理：解析 Mask 提取最终的前景
    // GrabCut Mask 对应的数值含义:
    // 0: GC_BGD (确信背景)
    // 1: GC_FGD (确信前景)
    // 2: GC_PR_BGD (可能背景)
    // 3: GC_PR_FGD (可能前景)
    // 我们将值为 1 (确信前景) 或 3 (可能前景) 的像素提出来作为最终前景蒙版

    final foregroundMask = cv.Mat.zeros(img.rows, img.cols, cv.MatType.CV_8UC1);

    // 遍历像素提取 1 和 3 (也可以通过位运算或逻辑矩阵快速筛选)
    for (var y = 0; y < mask.rows; y++) {
      for (var x = 0; x < mask.cols; x++) {
        final val = mask.at<int>(y, x);
        if (val == cv.GC_FGD || val == cv.GC_PR_FGD) {
          foregroundMask.set<int>(y, x, 255); // 标记为白色
        } else {
          foregroundMask.set<int>(y, x, 0); // 标记为黑色
        }
      }
    }

    //final resultWithAlpha = cv.bitwiseAND(img, img, mask: foregroundMask);

    // 7. 生成 4 通道 (BGRA) 带透明背景的 PNG 图像
    final resultWithAlpha = cv.Mat.zeros(
      img.rows,
      img.cols,
      cv.MatType.CV_8UC4,
    );

    for (var y = 0; y < img.rows; y++) {
      for (var x = 0; x < img.cols; x++) {
        final isFg = foregroundMask.at<int>(y, x) == 255;
        if (isFg) {
          //final pixel = img.atPixel(y, x);
          final vec = img.atVec<cv.Vec3b>(y, x).val; // 获取原图的 BGR 像素值
          //debugger();
          resultWithAlpha.setVec<cv.Vec4b>(
            y,
            x,
            cv.Vec4b(vec[0], vec[1], vec[2], 255),
          );
        } else {
          // 透明背景
          resultWithAlpha.setVec<cv.Vec4b>(y, x, cv.Vec4b(0, 0, 0, 0));
        }
      }
    }
    final result = await resultWithAlpha.toUiImage();

    // 9. 释放 C++ 层面的底层 OpenCV 内存资源
    img.dispose();
    mask.dispose();
    bgdModel.dispose();
    fgdModel.dispose();
    foregroundMask.dispose();
    resultWithAlpha.dispose();

    return result;
  }

  @implementation
  Future<UiImage?> removeBackground2() async {
    final image = this;

    final segmenter = PureOpenCVSegmenter(
      //
      // 大图先缩放
      //
      maxProcessSize: 1600,

      //
      // FloodFill Lab 容差
      //
      floodL: 10,
      floodA: 7,
      floodB: 7,

      //
      // Lab 背景距离基础阈值
      //
      baseDistanceThreshold: 15,

      //
      // 背景统计标准差权重
      //
      stdFactor: 2.0,

      //
      // 形态学
      //
      morphologySize: 5,

      //
      // 物体中心区域
      //
      sureForegroundRatio: 0.35,

      //
      // 最小物体
      //
      minObjectAreaRatio: 0.0005,
    );

    //
    // ----------------------------------------------------------
    // 分割
    // ----------------------------------------------------------
    //

    final segmentation = segmenter.segment(image);

    final mask = segmentation.mask;
    final foreground = createTransparentForeground(image, mask);
    final result = await foreground.toUiImage();

    foreground.dispose();
    mask.dispose();
    image.dispose();

    /*final remover = OpenCVBackgroundRemover(
      //
      // 图片边缘采样宽度
      //
      border: 10,

      //
      // 小于图片面积 0.1% 的区域删除
      //
      minAreaRatio: 0.001,

      //
      // Lab 背景差异阈值
      //
      threshold: 18,

      //
      // 形态学核
      //
      morphologySize: 5,
    );

    //
    // =========================================================
    // 分割
    // =========================================================
    //

    final mask = remover.removeBackground(image);
    final foreground = makeTransparentForeground(image, mask);
    final result = await foreground.toUiImage();

    // 9. 释放 C++ 层面的底层 OpenCV 内存资源
    foreground.dispose();
    mask.dispose();
    image.dispose();
    */

    return result;
  }
}
