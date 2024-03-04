part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 绘制元素数据
class ElementPainter extends IPainter {
  /// 元素绘制的属性信息
  /// 为空表示未初始化
  PaintProperty? _paintProperty;

  PaintProperty? get paintProperty => _paintProperty;

  set paintProperty(PaintProperty? value) {
    final old = _paintProperty;
    _paintProperty = value;
    if (old != value) {
      canvasDelegate?.dispatchCanvasElementPropertyChanged(this, old, value);
    }
  }

  /// 画笔
  Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeWidth = 1.toDpFromPx();

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPaintingSelf(canvas, paintMeta);
    });
  }

  /// 重写此方法, 实现在画布内绘制自己
  @overridePoint
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {}

  /// 判断当前元素是否与指定的点相交
  bool hitTest({Offset? point, Rect? rect, Path? path}) {
    if (point == null && rect == null && path == null) {
      return false;
    }
    path ??= Path()..addRect(rect ?? Rect.fromLTWH(point!.dx, point.dy, 1, 1));
    return _paintProperty?.paintPath.intersects(path) ?? false;
  }

  //---

  CanvasDelegate? canvasDelegate;

  /// 附加到[CanvasDelegate]
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = canvasDelegate;
  }

  /// 从[CanvasDelegate]中移除
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = null;
  }
}

/// 一组元素的绘制
class ElementGroupPainter extends ElementPainter {
  /// 子元素列表
  List<ElementPainter>? children = [];

  /// 重置子元素
  void resetChildren([List<ElementPainter>? children]) {
    this.children = children;
    if (isNullOrEmpty(children)) {
      paintProperty = null;
    } else {
      PaintProperty parentProperty = PaintProperty();
      Rect? rect;
      for (final child in children!) {
        final childBounds = child.paintProperty?.paintPath.getExactBounds();
        if (childBounds != null) {
          if (rect == null) {
            rect = childBounds;
          } else {
            rect = rect.expandToInclude(childBounds);
          }
        }
      }
      parentProperty.initWith(rect: rect);
      paintProperty = parentProperty;
    }
  }
}

/// 绘制属性, 包含坐标/缩放/旋转/倾斜等信息
/// 先倾斜, 再缩放, 最后旋转
class PaintProperty {
  /// 绘制的左上坐标
  /// 旋转后, 这个左上角也要旋转
  @dp
  double left = 0;
  @dp
  double top = 0;

  /// 绘制的宽高大小
  @dp
  double width = 0;
  @dp
  double height = 0;

  double scaleX = 1;
  double scaleY = 1;

  /// 倾斜角度, 弧度单位
  double skewX = 0;
  double skewY = 0;

  /// 旋转角度, 弧度单位
  /// [NumEx.toDegrees]
  /// [NumEx.toSanitizeDegrees]
  double angle = 0;

  /// 是否水平翻转
  bool flipX = false;

  /// 是否垂直翻转
  bool flipY = false;

  /// 元素最基础的矩形
  Rect get rect => Rect.fromLTWH(0, 0, width, height);

  /// 元素缩放/倾斜矩阵(不包含旋转)
  Matrix4 get scaleMatrix => translateToAnchor(Matrix4.identity()
    ..skewTo(kx: skewX, ky: skewY)
    ..scaleBy(sx: flipX ? -scaleX : scaleX, sy: flipY ? -scaleY : scaleY));

  /// 元素绘制的矩阵, 包含全属性
  Matrix4 get paintMatrix => translateToAnchor(scaleMatrix..rotateBy(angle));

  /// 元素缩放/倾斜后的矩形(不包含旋转)
  Rect get scaleRect => scaleMatrix.mapRect(rect);

  Rect get paintRect => paintMatrix.mapRect(rect);

  /// 元素全属性绘制路径, 用来判断是否相交
  Path get paintPath => Path().let((it) {
        it.addRect(rect);
        return it.transformPath(paintMatrix);
      });

  /// 将矩阵平移到锚点位置
  Matrix4 translateToAnchor(Matrix4 matrix) {
    //0/0矩阵作用矩阵后, 左上角所处的位置
    Offset anchor = rect.topLeft;
    anchor = matrix.mapPoint(anchor);

    //目标需要到达的左上角位置
    matrix.translateBy(x: left - anchor.dx, y: top - anchor.dy);
    return matrix;
  }

  /// 初始化属性
  void initWith({Rect? rect}) {
    if (rect != null) {
      left = rect.left;
      top = rect.top;
      width = rect.width;
      height = rect.height;
    }
  }
}
