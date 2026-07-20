import 'dart:math';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/20
///
/// 表盘布局助手
/// - 核心布局算法
abstract class DialLayoutHelper {
  /// 核心布局器：保证所有矩形在二维空间内绝对不相交（支持自旋转开关）
  ///
  /// * [rectangles] - 待排布的矩形队列
  /// * [initialRadius] - 最内圈的起始尝试半径
  /// * [radialGap] - 环与环之间的绝对物理净距 (径向)
  /// * [arcGap] - 同一环内，矩形内侧边缘之间的最小弦长间距 (切向)
  /// * [autoRotate] - 是否允许矩形随圆周进行自旋转。
  ///                  设置为 true 时，矩形底边朝向圆心；
  ///                  设置为 false 时，矩形始终保持水平正立。
  static List<PlacedRectangle> arrangeNonIntersectingCircles({
    required List<LayoutRectangle> rectangles,
    required double initialRadius,
    required double radialGap,
    required double arcGap,
    required bool autoRotate,
  }) {
    final List<PlacedRectangle> results = [];
    if (rectangles.isEmpty) return results;

    double currentRadius = initialRadius;
    double currentAngle = 0.0;

    double maxOuterRadiusInCurrentRing = 0.0;
    double maxOuterRadiusInPreviousRing = 0.0;

    int i = 0;
    while (i < rectangles.length) {
      // 1. 每当新一圈开始，动态锁定当前轨道的安全半径
      if (currentAngle == 0.0) {
        double maxRemainingHeight = 0.0;
        for (int j = i; j < rectangles.length; j++) {
          // 如果不自旋转，保守估计可能的最大径向跨度为对角线长度
          double effectiveHeight = autoRotate
              ? rectangles[j].height
              : sqrt(
                  pow(rectangles[j].width, 2) + pow(rectangles[j].height, 2),
                );

          if (effectiveHeight > maxRemainingHeight) {
            maxRemainingHeight = effectiveHeight;
          }
        }

        double safeStartRadius = (results.isEmpty)
            ? initialRadius
            : maxOuterRadiusInPreviousRing + radialGap;

        currentRadius = safeStartRadius + maxRemainingHeight / 2.0;
      }

      final rect = rectangles[i];

      // 2. 核心突破：根据是否自旋转，动态计算当前角度下游标对应的“等效切向宽度”与“等效径向高度”
      double effWidth;
      double effHeight;
      if (autoRotate) {
        effWidth = rect.width;
        effHeight = rect.height;
      } else {
        // 不自旋转时，随着圆周角度 currentAngle 的变化，宽和高在极坐标轴上的投影动态坍缩与拉伸
        effWidth =
            rect.width * sin(currentAngle).abs() +
            rect.height * cos(currentAngle).abs();
        effHeight =
            rect.width * cos(currentAngle).abs() +
            rect.height * sin(currentAngle).abs();
      }

      // 容错防御
      if (currentRadius <= effHeight / 2.0) {
        currentRadius = effHeight / 2.0 + 5.0;
      }

      // 3. 基于动态投影尺寸计算彻底防撞所需的圆心角
      double halfWidthWithGap = effWidth / 2.0 + arcGap / 2.0;
      double thetaHalf = atan2(
        halfWidthWithGap,
        currentRadius - effHeight / 2.0,
      );
      double angleNeeded = 2.0 * thetaHalf;

      // 4. 换圈判定
      if (currentAngle + angleNeeded > 2.0 * pi) {
        maxOuterRadiusInPreviousRing = maxOuterRadiusInCurrentRing;
        currentAngle = 0.0;
        maxOuterRadiusInCurrentRing = 0.0;
        continue;
      }

      // 5. 计算中心摆放极角与标准笛卡尔坐标
      double placementAngle = currentAngle + thetaHalf;
      double centerX = currentRadius * cos(placementAngle);
      double centerY = currentRadius * sin(placementAngle);

      results.add(
        PlacedRectangle(
          id: rect.id,
          centerX: centerX,
          centerY: centerY,
          rotationRad: autoRotate ? placementAngle : 0.0,
          // 控制核心：是否应用自旋转弧度
          radius: currentRadius,
        ),
      );

      // 6. 动态更新当前轨道的最大外包络半径
      double outerCornerRadius;
      if (autoRotate) {
        outerCornerRadius = sqrt(
          pow(currentRadius + rect.height / 2.0, 2) + pow(rect.width / 2.0, 2),
        );
      } else {
        // 不自旋转时，通过精确遍历无旋转矩形的 4 个绝对顶点，找出触及最远的外壳半径
        double maxR = 0.0;
        final xOffsets = [-rect.width / 2.0, rect.width / 2.0];
        final yOffsets = [-rect.height / 2.0, rect.height / 2.0];
        for (final dx in xOffsets) {
          for (final dy in yOffsets) {
            double vertexX = centerX + dx;
            double vertexY = centerY + dy;
            double r = sqrt(vertexX * vertexX + vertexY * vertexY);
            if (r > maxR) maxR = r;
          }
        }
        outerCornerRadius = maxR;
      }

      if (outerCornerRadius > maxOuterRadiusInCurrentRing) {
        maxOuterRadiusInCurrentRing = outerCornerRadius;
      }

      // 7. 推进游标
      currentAngle += angleNeeded;
      i++;
    }

    return results;
  }
}

/// 输入的矩形元数据
class LayoutRectangle {
  final int id;
  final double width;
  final double height;

  LayoutRectangle({
    required this.id,
    required this.width,
    required this.height,
  });
}

/// 排布完成后的高精度位置状态
class PlacedRectangle {
  final int id;

  /// 矩形中心点坐标
  final double centerX;
  final double centerY;

  /// 自身的旋转角度-弧度
  final double rotationRad;

  /// 所在的轨道中心半径
  final double radius;

  PlacedRectangle({
    required this.id,
    required this.centerX,
    required this.centerY,
    required this.rotationRad,
    required this.radius,
  });

  @override
  String toString() {
    final deg = (rotationRad * 180.0 / pi).toStringAsFixed(1);
    return 'ID: ${id.toString().padLeft(2, '0')} | 轨道半径: ${radius.toStringAsFixed(1)} | 坐标: (${centerX.toStringAsFixed(1)}, ${centerY.toStringAsFixed(1)}) | 自身角度: $deg°';
  }
}
