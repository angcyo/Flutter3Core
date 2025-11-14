part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/22
///
/// 定义一个包含4个点的数据结构
/// - 如果是矩形则按照 ltrb 的顺序
class FourPoint {
  static FourPoint? fromListString(String? src) {
    if (src == null || src.isEmpty) {
      return null;
    }
    final list = src.split(",").map((e) => double.parse(e)).toList();
    if (list.length != 8) {
      return null;
    }
    return FourPoint.fromList(list);
  }

  double x1 = 0.0;
  double y1 = 0.0;

  double x2 = 0.0;
  double y2 = 0.0;

  double x3 = 0.0;
  double y3 = 0.0;

  double x4 = 0.0;
  double y4 = 0.0;

  FourPoint();

  FourPoint.fromList(List<double> list) {
    x1 = list.getOrNull(0) ?? x1;
    y1 = list.getOrNull(1) ?? y1;
    x2 = list.getOrNull(2) ?? x2;
    y2 = list.getOrNull(3) ?? y2;
    x3 = list.getOrNull(4) ?? x3;
    y3 = list.getOrNull(5) ?? y3;
    x4 = list.getOrNull(6) ?? x4;
    y4 = list.getOrNull(7) ?? y4;
  }

  /// ltrb
  FourPoint.fromRect(Rect rect) {
    x1 = rect.left;
    y1 = rect.top;
    x2 = rect.right;
    y2 = rect.top;
    x3 = rect.right;
    y3 = rect.bottom;
    x4 = rect.left;
    y4 = rect.bottom;
  }

  //--

  /// ltrb
  List<double> get list => [x1, y1, x2, y2, x3, y3, x4, y4];

  Offset get lt => Offset(x1, y1);

  set lt(Offset offset) {
    x1 = offset.dx;
    y1 = offset.dy;
  }

  Offset get rt => Offset(x2, y2);

  set rt(Offset offset) {
    x2 = offset.dx;
    y2 = offset.dy;
  }

  Offset get rb => Offset(x3, y3);

  set rb(Offset offset) {
    x3 = offset.dx;
    y3 = offset.dy;
  }

  Offset get lb => Offset(x4, y4);

  set lb(Offset offset) {
    x4 = offset.dx;
    y4 = offset.dy;
  }

  /// 理论上是还原不了真正对应的矩形
  /// 只能返回最大包裹框的矩形
  Rect get rect {
    return Rect.fromLTRB(
      min(x1, min(x2, min(x3, x4))),
      min(y1, min(y2, min(y3, y4))),
      max(x1, max(x2, max(x3, x4))),
      max(y1, max(y2, max(y3, y4))),
    );
  }

  //--

  /// 创建一个透视变换
  /// - 将当前的4个点, 按照透视变换, 变换到目标的4个点
  @api
  Matrix3 createPerspectiveMatrix(FourPoint to) =>
      createPerspectiveMatrix2(list, to.list);

  //--

  String get listString => list.join(",");

  @override
  String toString() => listString;
}

/// 定义一个包含2个点的数据结构
class TwoPoint {
  static TwoPoint? fromListString(String? src) {
    if (src == null || src.isEmpty) {
      return null;
    }
    final list = src.split(",").map((e) => double.parse(e)).toList();
    if (list.length != 4) {
      return null;
    }
    return TwoPoint.fromList(list);
  }

  double x1 = 0.0;
  double y1 = 0.0;

  double x2 = 0.0;
  double y2 = 0.0;

  TwoPoint();

  TwoPoint.fromList(List<double> list) {
    x1 = list.getOrNull(0) ?? x1;
    y1 = list.getOrNull(1) ?? y1;
    x2 = list.getOrNull(2) ?? x2;
    y2 = list.getOrNull(3) ?? y2;
  }

  TwoPoint.fromOffset(Offset offset1, Offset offset2) {
    x1 = offset1.dx;
    y1 = offset1.dy;
    x2 = offset2.dx;
    y2 = offset2.dy;
  }

  List<double> get list => [x1, y1, x2, y2];

  Offset get $1 => Offset(x1, y1);

  set $1(Offset offset) {
    x1 = offset.dx;
    y1 = offset.dy;
  }

  Offset get $2 => Offset(x2, y2);

  set $2(Offset offset) {
    x2 = offset.dx;
    y2 = offset.dy;
  }

  /// 2点之间的距离
  double get distance => c(x1, y1, x2, y2);

  /// 调整为横竖直线, 避免斜线
  @api
  TwoPoint get adjustStraightLine {
    final dx = x2 - x1;
    final dy = y2 - y1;
    if (dx.abs() > dy.abs()) {
      // 横向
      y2 = y1;
    } else {
      // 纵向
      x2 = x1;
    }
    return this;
  }

  //--

  String get listString => list.join(",");

  @override
  String toString() => listString;
}

extension FourPointStringEx on String {
  FourPoint? get fourPoint => FourPoint.fromListString(this);
}

extension FourPointRectEx on Rect {
  FourPoint? get fourPoint => FourPoint.fromRect(this);
}

extension PointStringEx on String {
  Offset? get point {
    final list = split(",").map((e) => double.parse(e)).toList();
    if (list.length != 2) {
      return null;
    }
    return Offset(list[0], list[1]);
  }
}

extension PointEx on Offset {
  String get listString => [x, y].join(",");
}
