part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/03
///
class BasicsDebug {
  BasicsDebug();

  /// 在指定位置, 创建一个象限[Path]
  /// - [r1] 1象限的半径
  /// - [r2] 2象限的半径
  /// - [r3] 3象限的半径
  /// - [r4] 4象限的半径
  /// - [scale] 半径放大倍数
  ///
  static Path generateQuadrantPath(
    double cx,
    double cy, {
    @dp double r1 = 2.0,
    @dp double r2 = 4.0,
    @dp double r3 = 6.0,
    @dp double r4 = 8.0,
    @dp double offsetX = 2.0,
    @dp double offsetY = 2.0,
    double scale = 2.0,
  }) {
    final Path result = Path();

    //右上 第一象限
    result.addPath(
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(cx + r1 + offsetX, cy - r1 - offsetY),
          width: r1 * scale,
          height: r1 * scale,
        ),
      ),
      .zero,
    );
    //左上 第二象限
    result.addPath(
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(cx - r2 - offsetX, cy - r2 - offsetY),
          width: r2 * scale,
          height: r2 * scale,
        ),
      ),
      .zero,
    );
    //左下 第三象限
    result.addPath(
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(cx - r3 - offsetX, cy + r3 + offsetY),
          width: r3 * scale,
          height: r3 * scale,
        ),
      ),
      .zero,
    );
    //右下 第四象限
    result.addPath(
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(cx + r4 + offsetX, cy + r4 + offsetY),
          width: r4 * scale,
          height: r4 * scale,
        ),
      ),
      .zero,
    );

    return result;
  }
}
