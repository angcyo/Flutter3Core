part of '../../flutter3_canvas.dart';

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
    //debugger();
    final old = _paintProperty;
    _paintProperty = value;
    if (old != value) {
      onSelfPaintPropertyChanged(old, value, PropertyType.paint);
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
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //paint.color = Colors.black;
    //paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
    if (paintMeta.host is CanvasDelegate) {
      //debugger();
      if (canvasDelegate?.canvasElementManager.isElementSelected(this) ==
          true) {
        //debugger();
        //绘制元素旋转的矩形边界
        paint.color = canvasStyle?.canvasAccentColor ?? paint.color;
        paintPropertyRect(canvas, paintMeta, paint);

        assert(() {
          //绘制元素包裹的边界矩形
          paint.color = Colors.red;
          paintPropertyBounds(canvas, paintMeta, paint);
          return true;
        }());
      }
    }
  }

  /// 绘制元素的旋转矩形
  void paintPropertyRect(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      final rect = it.paintScaleRect;
      /*final c1 = rect.center;
      final c2 = it.paintRect.center;
      final c3 = it.paintCenter;
      debugger();
      canvas.drawRect(it.scaleRect, paint);
      canvas.drawRect(
          Rect.fromLTWH(
              it.left, it.top, it.scaleRect.width, it.scaleRect.height),
          paint);
      canvas.drawRect(rect, paint);*/
      canvas.withRotateRadians(it.angle, () {
        canvas.drawRect(rect, paint);
      }, anchor: rect.center);
    });
  }

  /// 绘制元素的包裹框边界
  void paintPropertyBounds(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      //debugger();
      //canvas.drawPath(it.paintPath, paint);
      canvas.drawRect(it.paintRect, paint);
    });
  }

  /// 判断当前元素是否与指定的点相交
  bool hitTest(
      {@sceneCoordinate Offset? point,
      @sceneCoordinate Rect? rect,
      @sceneCoordinate Path? path}) {
    if (point == null && rect == null && path == null) {
      return false;
    }
    path ??= Path()..addRect(rect ?? Rect.fromLTWH(point!.dx, point.dy, 1, 1));
    return _paintProperty?.paintPath.intersects(path) ?? false;
  }

  //---

  /// 是否锁定了宽高比
  bool _isLockRatio = true;

  bool get isLockRatio => _isLockRatio;

  set isLockRatio(bool value) {
    //debugger();
    if (_isLockRatio != value) {
      _isLockRatio = value;
      onSelfPaintPropertyChanged(null, paintProperty, PropertyType.state);
    }
  }

  /// 当前选中的元素是否支持指定的控制点
  /// [BaseControl.CONTROL_TYPE_DELETE]
  /// [BaseControl.CONTROL_TYPE_ROTATE]
  /// [BaseControl.CONTROL_TYPE_SCALE]
  /// [BaseControl.CONTROL_TYPE_LOCK]
  bool isElementSupportControl(int type) {
    return true;
  }

  /// 元素属性改变
  /// [old] 旧的属性
  /// [value] 新的属性
  /// [propertyType] 属性类型
  void onSelfPaintPropertyChanged(
      PaintProperty? old, PaintProperty? value, int propertyType) {
    canvasDelegate?.dispatchCanvasElementPropertyChanged(
        this, old, value, propertyType);
  }

  /// 直接作用缩放
  /// [sx].[sy] 相对缩放
  /// [sxTo].[syTo] 绝对缩放
  @api
  void applyScale({double? sx, double? sy, double? sxTo, double? syTo}) {
    //debugger();
    paintProperty?.let((it) {
      paintProperty = it.clone()
        ..applyScale(sxBy: sx, syBy: sy, sxTo: sxTo, syTo: syTo);
    });
  }

  /// 应用矩阵, 通常在子元素缩放时需要使用方法
  /// [applyMatrixWithCenter]
  /// [applyMatrixWithAnchor]
  @api
  void applyMatrixWithCenter(Matrix4 matrix) {
    //debugger();
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyMatrixWithCenter(matrix);
    });
  }

  /// 应用矩阵
  /// [applyMatrixWithCenter]
  /// [applyMatrixWithAnchor]
  @api
  void applyMatrixWithAnchor(Matrix4 matrix) {
    //debugger();
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyMatrixWithAnchor(matrix);
    });
  }

  /// 旋转元素
  /// [angle] 弧度
  /// [anchor] 旋转锚点, 不指定时, 以元素中心点为锚点
  /// [applyMatrixWithAnchor]
  @api
  void rotateBy(
    double angle, {
    Offset? anchor,
  }) {
    paintProperty?.let((it) {
      anchor ??= it.paintRect.center;
      final matrix = Matrix4.identity()..rotateBy(angle, anchor: anchor);
      applyMatrixWithAnchor(matrix);
    });
  }

  //---

  CanvasDelegate? canvasDelegate;

  CanvasStyle? get canvasStyle => canvasDelegate?.canvasStyle;

  /// 附加到[CanvasDelegate]
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = canvasDelegate;
  }

  /// 从[CanvasDelegate]中移除
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    this.canvasDelegate = null;
  }

  //---

  /// 保存当前元素的状态
  ElementStateStack createStateStack() => ElementStateStack()..saveFrom(this);

  /// 当元素的状态恢复后
  void onRestoreStateStack(ElementStateStack stateStack) {}

  //---

  /// 单签元素是否包含指定的元素
  @api
  bool containsElement(ElementPainter? element) {
    return this == element;
  }

  /// 获取单个元素列表
  @api
  List<ElementPainter> getSingleElementList() {
    return [this];
  }

  /// 仅获取所有[ElementGroupPainter]的元素
  @api
  List<ElementGroupPainter>? getGroupPainterList() {
    return null;
  }
}

/// 一组元素的绘制
class ElementGroupPainter extends ElementPainter {
  /// 子元素列表
  List<ElementPainter>? children = [];

  /// 重置子元素
  @api
  void resetChildren(List<ElementPainter>? children, bool resetGroupAngle) {
    this.children = children;
    updatePaintPropertyFromChildren(resetGroupAngle);
  }

  /// 更新绘制属性
  /// [resetGroupAngle] 是否要重置旋转角度
  @api
  void updatePaintPropertyFromChildren(bool resetGroupAngle) {
    if (isNullOrEmpty(children)) {
      paintProperty = null;
    } else if (children!.length == 1 && !resetGroupAngle) {
      paintProperty = children!.first.paintProperty?.clone();
    } else {
      PaintProperty parentProperty = PaintProperty();
      Rect? rect;
      for (final child in children!) {
        //final childBounds = child.paintProperty?.paintPath.getExactBounds();
        final childBounds = child.paintProperty?.paintRect;
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

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    children?.forEach((element) {
      //debugger();
      element.painting(canvas, paintMeta);
    });
    super.painting(canvas, paintMeta);
  }

  @override
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    super.attachToCanvasDelegate(canvasDelegate);
    children?.forEach((element) {
      element.attachToCanvasDelegate(canvasDelegate);
    });
  }

  @override
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    super.detachFromCanvasDelegate(canvasDelegate);
    children?.forEach((element) {
      element.detachFromCanvasDelegate(canvasDelegate);
    });
  }

  @override
  void applyScale({double? sx, double? sy, double? sxTo, double? syTo}) {
    super.applyScale(sx: sx, sy: sy, sxTo: sxTo, syTo: syTo);
    children?.forEach((element) {
      element.applyScale(sx: sx, sy: sy, sxTo: sxTo, syTo: syTo);
    });
  }

  @override
  void applyMatrixWithCenter(Matrix4 matrix) {
    super.applyMatrixWithCenter(matrix);
    children?.forEach((element) {
      element.applyMatrixWithCenter(matrix);
    });
  }

  @override
  void applyMatrixWithAnchor(Matrix4 matrix) {
    super.applyMatrixWithAnchor(matrix);
    children?.forEach((element) {
      element.applyMatrixWithAnchor(matrix);
    });
  }

  @override
  void rotateBy(double angle, {Offset? anchor}) {
    super.rotateBy(angle, anchor: anchor);
  }

  @override
  bool containsElement(ElementPainter? element) {
    return super.containsElement(element) ||
        children?.any((item) => item.containsElement(element)) == true;
  }

  @override
  List<ElementPainter> getSingleElementList() {
    final result = <ElementPainter>[];
    children?.forEach((element) {
      result.addAll(element.getSingleElementList());
    });
    return result;
  }

  @override
  List<ElementGroupPainter>? getGroupPainterList() {
    final result = <ElementGroupPainter>[];
    result.add(this);
    children?.forEach((element) {
      result.addAll(element.getGroupPainterList() ?? []);
    });
    return result;
  }
}

/// 绘制属性, 包含坐标/缩放/旋转/倾斜等信息
/// 先倾斜, 再缩放, 最后旋转
class PaintProperty with EquatableMixin {
  //region ---基础属性---

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

  //endregion ---基础属性---

  //region ---get属性---

  /// 锚点坐标, 这里是旋转后的矩形左上角坐标
  Offset get anchor => Offset(left, top);

  /// 元素最基础的矩形
  Rect get rect => Rect.fromLTWH(0, 0, width, height);

  /// 元素缩放/倾斜矩阵(不包含旋转和平移)
  Matrix4 get scaleMatrix => Matrix4.identity()
    ..skewBy(kx: skewX, ky: skewY)
    ..postScale(sx: flipX ? -scaleX : scaleX, sy: flipY ? -scaleY : scaleY);

  /// 元素缩放/倾斜后的矩形
  /// [scaleMatrix]
  Rect get scaleRect => scaleMatrix.mapRect(rect);

  /// [scaleRect]平移到目标位置的矩形
  Rect get paintScaleRect {
    //debugger();
    final rect = scaleRect;
    final currentCenter = rect.center;
    final targetCenter = paintRect.center;
    return rect.offset(Offset(targetCenter.dx - currentCenter.dx,
        targetCenter.dy - currentCenter.dy));
  }

  /// 元素绘制的矩阵, 包含全属性
  Matrix4 get paintMatrix => translateToAnchor(scaleMatrix..postRotate(angle));

  /*/// 仅包含旋转的矩阵
  Matrix4 get rotateMatrix =>
      translateToAnchor(Matrix4.identity()..rotateBy(angle));*/

  /// 全属性后的最大包裹矩形
  Rect get paintRect => paintMatrix.mapRect(rect);

  /// 元素全属性绘制路径, 用来判断是否相交
  /// 完全包裹的path路径
  Path get paintPath => Path().let((it) {
        //debugger();
        it.addRect(rect);
        return it.transformPath(paintMatrix);
      });

  //endregion ---get属性---

  //region ---操作方法---

  /// 将矩阵平移到锚点位置
  Matrix4 translateToAnchor(Matrix4 matrix) {
    final originRect = rect;

    //0/0矩阵作用矩阵后, 左上角所处的位置
    Offset anchor = originRect.topLeft;
    anchor = matrix.mapPoint(anchor);

    Offset center = originRect.center;
    center = matrix.mapPoint(center);
    //debugger();

    //目标需要到达的左上角位置
    matrix.postTranslateBy(x: left - anchor.dx, y: top - anchor.dy);
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

  /// 直接作用缩放
  /// [sxBy].[syBy] 相对缩放
  /// [sxTo].[syTo] 绝对缩放
  void applyScale({double? sxBy, double? syBy, double? sxTo, double? syTo}) {
    sxTo ??= scaleX * (sxBy ?? 1);
    syTo ??= scaleY * (syBy ?? 1);
    scaleX = sxTo.abs();
    scaleY = syTo.abs();
    flipX = sxTo < 0;
    flipY = syTo < 0;
  }

  /// 应用矩阵[matrix], 通常在缩放时需要使用方法
  /// 使用qr分解矩阵, 使用中心点位置作为锚点的偏移依据
  /// 需要保证操作之后的中心点位置不变
  /// 最后需要更新[left].[top]
  void applyMatrixWithCenter(Matrix4 matrix) {
    //debugger();
    Offset originCenter = paintRect.center;
    //中点的最终位置
    final targetCenter = matrix.mapPoint(originCenter);

    //应用矩阵
    final Matrix4 matrix_ = paintMatrix.postConcatIt(matrix);
    qrDecomposition(matrix_);

    //现在的中点位置
    final nowCenter = paintRect.center;
    //debugger();

    //更新left top
    left += targetCenter.dx - nowCenter.dx;
    top += targetCenter.dy - nowCenter.dy;

    //l.d(this);
  }

  /// 直接使用锚点作为更新锚点依据
  void applyMatrixWithAnchor(Matrix4 matrix) {
    Offset anchor = Offset(left, top);
    //锚点的最终位置
    final targetAnchor = matrix.mapPoint(anchor);

    //应用矩阵
    final Matrix4 matrix_ = paintMatrix.postConcatIt(matrix);
    //paintMatrix.postConcat(matrix);
    //final Matrix4 matrix_ = paintMatrix;
    qrDecomposition(matrix_);

    //debugger();

    //更新left top
    left = targetAnchor.dx;
    top = targetAnchor.dy;

    //l.d(this);
  }

  void qrDecomposition(Matrix4 matrix) {
    final qr = matrix.qrDecomposition();
    angle = qr[0];
    scaleX = qr[1].abs();
    scaleY = qr[2].abs();
    skewX = qr[3];
    skewY = qr[4];
    flipX = qr[1] < 0;
    flipY = qr[2] < 0;
  }

  /// 克隆属性
  PaintProperty clone() => PaintProperty()
    ..left = left
    ..top = top
    ..width = width
    ..height = height
    ..scaleX = scaleX
    ..scaleY = scaleY
    ..skewX = skewX
    ..skewY = skewY
    ..angle = angle
    ..flipX = flipX
    ..flipY = flipY;

  @override
  String toString() {
    return 'PaintProperty{left: $left, top: $top, width: $width, height: $height, scaleX: $scaleX, scaleY: $scaleY, skewX: $skewX, skewY: $skewY, angle: $angle, flipX: $flipX, flipY: $flipY}';
  }

  @override
  List<Object?> get props => [
        left,
        top,
        width,
        height,
        scaleX,
        scaleY,
        skewX,
        skewY,
        angle,
        flipX,
        flipY,
      ];

//endregion ---操作方法---
}

/// 元素状态栈, 用来撤销和重做
class ElementStateStack {
  /// 元素的属性保存
  final Map<ElementPainter, PaintProperty?> propertyMap = {};

  /// 保存信息
  @callPoint
  @mustCallSuper
  void saveFrom(ElementPainter element) {
    propertyMap[element] = element.paintProperty?.clone();
    if (element is ElementGroupPainter) {
      element.children?.forEach((element) {
        saveFrom(element);
      });
    }
  }

  /// 恢复信息
  @callPoint
  @mustCallSuper
  void restore() {
    propertyMap.forEach((element, paintProperty) {
      element.paintProperty = paintProperty;
      element.onRestoreStateStack(this);
    });
  }
}

/// 属性类型
abstract class PropertyType {
  /// 绘制的相关属性, 比如坐标/缩放/旋转/倾斜等信息
  static int paint = 0x01;

  /// 元素的状态改变, 比如锁定/可见性等信息
  static int state = 0x02;

  /// 元素的数据改变, 比如内容等信息
  static int data = 0x04;
}
