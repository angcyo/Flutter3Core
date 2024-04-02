part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 绘制元素数据
class ElementPainter extends IPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin {
  /// 元素的唯一标识
  String? elementUuid = uuid();

  /// 元素的名称
  String? elementName;

  //region ---PaintProperty---

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

  /// 获取元素[paintProperty]的边界
  @dp
  Rect? get elementsBounds {
    return paintProperty?.getBounds(canvasDelegate?.canvasElementManager
            .canvasElementControlManager.enableResetElementAngle ==
        true);
  }

  /// 更新当前元素的边界到指定位置
  /// 只修改[PaintProperty.left].[PaintProperty.top].[PaintProperty.scaleX].[PaintProperty.scaleY]
  @api
  void updateBoundsTo(@sceneCoordinate @dp Rect? bounds) {
    if (bounds == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    final property = paintProperty;
    if (property != null) {
      final oldBounds = property.getBounds(true);
      final sx = bounds.width / oldBounds.width;
      final sy = bounds.height / oldBounds.height;
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: oldBounds.topLeft);
      final translate = Matrix4.identity()
        ..translate(bounds.left - oldBounds.left, bounds.top - oldBounds.top);
      paintProperty = property.clone()
        ..applyScaleWithCenter(scaleMatrix)
        ..applyTranslate(translate);
    }
  }

  /// 更新当前元素的实际宽高到指定大小
  /// [keepVisibleBounds] 是否保持可见的边界宽高不变
  @api
  void updateWidthHeight({
    @dp double? newWidth,
    @dp double? newHeight,
    bool keepVisibleBounds = true,
  }) {
    if (newWidth == null && newHeight == null) {
      return;
    }
    paintProperty?.let((it) {
      final resetElementAngle = canvasDelegate?.canvasElementManager
              .canvasElementControlManager.enableResetElementAngle ??
          true;
      final oldBounds = it.getBounds(resetElementAngle);
      final oldWidth = oldBounds.width;
      final oldHeight = oldBounds.height;

      //更新宽高属性
      it.width = newWidth ?? it.width;
      it.height = newHeight ?? it.height;

      if (keepVisibleBounds && oldWidth > 0 && oldHeight > 0) {
        //保持可见边界不变
        final newBounds = it.getBounds(resetElementAngle);
        final sx = newBounds.width / oldWidth;
        final sy = newBounds.height / oldHeight;
        it.applyScale(sxBy: sx, syBy: sy);
      }
    });
  }

  //endregion ---PaintProperty---

  //region ---属性--

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

  /// 元素是否可见, 不可见的元素也不会绘制
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  set isVisible(bool value) {
    //debugger();
    if (_isVisible != value) {
      _isVisible = value;
      onSelfPaintPropertyChanged(null, paintProperty, PropertyType.state);
    }
  }

  /// 元素是否锁定了操作, 锁定后, 不可选中操作
  bool _isLockOperate = false;

  bool get isLockOperate => _isLockOperate;

  set isLockOperate(bool value) {
    //debugger();
    if (_isLockOperate != value) {
      _isLockOperate = value;
      onSelfPaintPropertyChanged(null, paintProperty, PropertyType.state);
    }
  }

  /// 画笔
  Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.toDpFromPx();

  /// 是否绘制调试信息
  bool debug = false;

  //endregion ---属性--

  //region ---paint---

  ///[onPaintingSelfBefore]
  ///[onPaintingSelf]
  @entryPoint
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPaintingSelfBefore(canvas, paintMeta);
      onPaintingSelf(canvas, paintMeta);
    });
  }

  /// [onPaintingSelf]绘制之前调用, 用来重新设置画笔样式等
  @property
  void onPaintingSelfBefore(Canvas canvas, PaintMeta paintMeta) {
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.toDpFromPx();
  }

  /// 重写此方法, 实现在画布内绘制自己
  /// [painting]
  /// [paintPropertyRect]
  /// [paintPropertyBounds]
  @overridePoint
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //paint.color = Colors.black;
    //paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
    if (paintMeta.host is CanvasDelegate) {
      //debugger();
      if (debug ||
          canvasDelegate?.canvasElementManager.isElementSelected(this) ==
              true) {
        //debugger();
        //绘制元素旋转的矩形边界
        paintPropertyRect(canvas, paintMeta, paint);

        /*assert(() {
          //绘制元素包裹的边界矩形
          paintPropertyBounds(canvas, paintMeta, paint);
          return true;
        }());*/
      }
    }
  }

  /// 绘制元素的旋转矩形, 用来提示元素的矩形+旋转信息
  /// [onPaintingSelf]
  @property
  void paintPropertyRect(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      paint.withSavePaint(() {
        paint.color = canvasStyle?.canvasAccentColor ?? paint.color;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1 / paintMeta.canvasScale;

        //debugger();
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

        /*paint.color = Colors.redAccent;
      canvas.drawRect(rect, paint);

      canvas.drawRect(it.paintBounds, paint);*/
      });
    });
  }

  /// 绘制元素的包裹框边界, 全属性后的包裹框
  /// [onPaintingSelf]
  @property
  void paintPropertyBounds(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      //debugger();
      paint.withSavePaint(() {
        paint.color = Colors.redAccent;
        //canvas.drawPath(it.paintPath, paint);
        canvas.drawRect(it.paintBounds, paint);
      });
    });
  }

  /// 判断当前元素是否与指定的点相交
  /// [inflate] 未命中时, 是否膨胀
  /// [isVisibleInCanvasBox]
  bool hitTest({
    @sceneCoordinate Offset? point,
    @sceneCoordinate Rect? rect,
    @sceneCoordinate Path? path,
    bool inflate = true,
  }) {
    if (point == null && rect == null && path == null) {
      return false;
    }
    path ??= Path()..addRect(rect ?? Rect.fromLTWH(point!.dx, point.dy, 1, 1));
    bool hit = _paintProperty?.paintPath.intersects(path) ?? false;
    if (!hit && inflate) {
      //没有命中时, 膨胀一下, 再判断一次
      final bounds = _paintProperty?.paintPath.getExactBounds();
      if (bounds != null) {
        //debugger();
        hit = bounds.inflateValue(10).toPath().intersects(path);
      }
    }
    return hit;
  }

  /// 当前元素在画布中是否可见, 不可见的元素不会在画布中绘制
  /// [hitTest]
  bool isVisibleInCanvasBox(CanvasViewBox viewBox) =>
      isVisible && hitTest(rect: viewBox.canvasVisibleBounds);

  //---

  /// 当前选中的元素是否支持指定的控制点
  /// [BaseControl.sControlTypeDelete]
  /// [BaseControl.sControlTypeRotate]
  /// [BaseControl.sControlTypeScale]
  /// [BaseControl.sControlTypeLock]
  bool isElementSupportControl(int type) {
    if (type == BaseControl.sControlTypeLock) {
      final bounds = elementsBounds;
      if (bounds?.width == 0 || bounds?.height == 0) {
        return false;
      }
    } else if (type == BaseControl.sControlTypeWidth) {
      return (elementsBounds?.width ?? 0).notEqualTo(0);
    } else if (type == BaseControl.sControlTypeHeight) {
      return (elementsBounds?.height ?? 0).notEqualTo(0);
    }
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

  //endregion ---paint---

  //region ---apply paintProperty--

  /// 平移元素
  @api
  void translateElement(Matrix4 matrix) {
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyTranslate(matrix);
    });
  }

  /// 旋转元素
  @api
  void rotateElement(Matrix4 matrix) {
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyRotate(matrix);
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
      //debugger();
      anchor ??= it.paintCenter;
      final matrix = Matrix4.identity()..rotateBy(angle, anchor: anchor);
      rotateElement(matrix);
    });
  }

  /// 翻转元素, 互斥操作
  /// 这种方式翻转元素, 有可能会跑到边界外, 所以需要重新计算边界
  /// [flipX] 是否要水平翻转
  /// [flipY] 是否要垂直翻转
  @api
  void flipElement({bool? flipX, bool? flipY}) {
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyFlip(flipX: flipX, flipY: flipY);
    });
  }

  /// 使用缩放的方式翻转元素
  /// 这种方法的翻转不会跑到边界外
  @api
  void flipElementWithScale({bool? flipX, bool? flipY, Offset? anchor}) {
    final scaleMatrix = Matrix4.identity()
      ..scaleBy(
          sx: flipX == true ? -1 : 1,
          sy: flipY == true ? -1 : 1,
          anchor: anchor ?? paintProperty?.paintCenter);
    scaleElementWithCenter(scaleMatrix);
  }

  /// 作用一个缩放矩阵
  /// [onlyScaleSelfElement]
  /// [scaleElementWithCenter]
  @api
  void scaleElement({double sx = 1, double sy = 1, Offset? anchor}) {
    if (anchor == null) {
      onlyScaleSelfElement(sx: sx, sy: sy);
    } else {
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchor);
      scaleElementWithCenter(scaleMatrix);
    }
  }

  /// 应用矩阵, 通常在子元素缩放时需要使用方法
  @api
  void scaleElementWithCenter(Matrix4 matrix) {
    //debugger();
    paintProperty?.let((it) {
      paintProperty = it.clone()..applyScaleWithCenter(matrix);
    });
  }

  /// 直接作用缩放, 通常在外边框缩放时使用方法
  /// [sx].[sy] 相对缩放
  /// [sxTo].[syTo] 绝对缩放
  @protected
  void onlyScaleSelfElement({
    double? sx,
    double? sy,
    double? sxTo,
    double? syTo,
  }) {
    //debugger();
    paintProperty?.let((it) {
      paintProperty = it.clone()
        ..applyScale(sxBy: sx, syBy: sy, sxTo: sxTo, syTo: syTo);
    });
  }

  //endregion ---apply paintProperty--

  //region ---canvas---

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
  /// 使用[ElementStateStack.restore]恢复状态
  ElementStateStack createStateStack() => ElementStateStack()..saveFrom(this);

  /// 当元素的状态恢复后
  /// [ElementStateStack.restore]
  void onRestoreStateStack(ElementStateStack stateStack) {}

  //endregion ---canvas---

  //region ---api---

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

  //endregion ---api---

  //region ---output---

  /// 元素操作后对应的图片数据, 支持所有元素, 包含组合元素
  /// [ImageEx.toBase64]
  /// [ElementPainter]
  /// [ElementGroupPainter]
  @output
  UiImage? get elementOutputImage {
    final bounds = elementsBounds;
    if (bounds == null) {
      return null;
    }
    final image = drawImageSync(bounds.size, (canvas) {
      canvas.drawInRect(Offset.zero & bounds.size, bounds, () {
        painting(canvas, PaintMeta(host: rasterizeElementHost));
      });
    });
    /*assert(() {
      image.toBase64().get((value, error) {
        final base64 = value;
        debugger();
      });
      return true;
    }());*/
    return image;
  }

  /// 获取元素用于输出的边界[Path]
  @output
  Path? get elementOutputBoundsPath => paintProperty?.paintPath;

  /// 获取元素的输出[Path]
  /// [VectorPathEx.toSvgPathString]
  @output
  Path? get elementOutputPath {
    if (this is PathElementPainter) {
      return (this as PathElementPainter).operatePath;
    }
    return null;
  }

  /// 获取元素的所有输出[Path]
  @output
  List<Path> get elementOutputPathList {
    final result = <Path>[];
    if (this is ElementGroupPainter) {
      (this as ElementGroupPainter).children?.forEach((element) {
        result.addAll(element.elementOutputPathList);
      });
    } else if (this is PathElementPainter) {
      (this as PathElementPainter).operatePath?.let((it) => result.add(it));
    }
    return result;
  }

  /// 元素操作后对应的路径数据
  /// [getElementOutputPath]
  /// [getElementOutputPathList]
  Path? getElementOutputPath(Path? inputPath) {
    if (inputPath == null) {
      return null;
    }
    return inputPath.transformPath(paintProperty?.operateMatrix);
  }

  /// [getElementOutputPath]
  /// [getElementOutputPathList]
  List<Path>? getElementOutputPathList(List<Path>? inputPathList) {
    if (isNil(inputPathList)) {
      return null;
    }
    return inputPathList?.transformPath(paintProperty?.operateMatrix);
  }

  //endregion ---output---

  //region ---callback---

  /// 当前元素被组合到
  /// [CanvasElementManager.groupElement]
  @property
  void onSelfGroupFrom(ElementGroupPainter group) {}

  /// 当前元素被解组
  /// [CanvasElementManager.ungroupElement]
  @property
  void onSelfUngroupFrom(ElementGroupPainter group) {}

  //endregion ---callback---

  @override
  String toStringShort() =>
      '${classHash()} 边界:${paintProperty?.getBounds(canvasDelegate?.canvasElementManager.canvasElementControlManager.enableResetElementAngle == true)}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('paintProperty', paintProperty));
    properties.add(FlagProperty('isLockRatio',
        value: isLockRatio, ifTrue: 'isLockRatio', ifFalse: 'notLockRatio'));
    properties.add(FlagProperty('isVisible',
        value: isVisible, ifTrue: 'isVisible', ifFalse: 'notVisible'));

    final canvasViewBox = canvasDelegate?.canvasViewBox;
    if (canvasViewBox != null) {
      properties.add(
          DiagnosticsProperty('是否在画布中', isVisibleInCanvasBox(canvasViewBox)));
    }
  }
}

/// 一组元素的绘制
class ElementGroupPainter extends ElementPainter {
  /// 子元素列表
  List<ElementPainter>? children = [];

  //region ---core--

  /// 重置子元素
  @api
  void resetChildren(List<ElementPainter>? children, bool resetGroupAngle) {
    this.children = children;
    updatePaintPropertyFromChildren(resetGroupAngle);
  }

  /// 使用子元素的属性, 更新自身的绘制属性
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
        final childBounds =
            child.paintProperty?.getBounds(true); //resetGroupAngle
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

  //endregion ---core--

  //region ---apply--

  @override
  void translateElement(Matrix4 matrix) {
    super.translateElement(matrix);
    children?.forEach((element) {
      element.translateElement(matrix);
    });
  }

  @override
  void rotateElement(Matrix4 matrix) {
    super.rotateElement(matrix);
    children?.forEach((element) {
      element.rotateElement(matrix);
    });
  }

  @override
  void flipElement({bool? flipX, bool? flipY}) {
    super.flipElement(flipX: flipX, flipY: flipY);
    children?.forEach((element) {
      element.flipElement(flipX: flipX, flipY: flipY);
    });
    //这种方式翻转元素, 有可能会跑到边界外, 所以需要重新计算边界
    updatePaintPropertyFromChildren(true);
  }

  /// 缩放选中的元素, 在[ElementGroupPainter]中需要分开处理自身和[children]
  /// [anchor] 缩放的锚点, 不指定则使用[PaintProperty]的锚点
  /// [ScaleControl]
  @override
  void scaleElement({double sx = 1, double sy = 1, Offset? anchor}) {
    double angle = paintProperty?.angle ?? 0; //弧度
    anchor ??= paintProperty?.anchor ?? Offset.zero;

    //自身使用直接缩放
    paintProperty = paintProperty?.clone()?..applyScale(sxBy: sx, syBy: sy);

    //---children处理---

    //子元素使用矩阵缩放
    final matrix = Matrix4.identity();

    if (angle % (2 * pi) == 0) {
      //未旋转
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchor);

      matrix.postConcat(scaleMatrix);
    } else {
      final rotateMatrix = Matrix4.identity()
        ..rotateBy(angle, anchor: paintProperty?.scaleRect.center);
      final rotateInvertMatrix = rotateMatrix.invertedMatrix();
      Offset anchorInvert = rotateInvertMatrix.mapPoint(anchor);

      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchorInvert);

      matrix.setFrom(rotateInvertMatrix);
      matrix.postConcat(scaleMatrix);
      matrix.postConcat(rotateMatrix);
    }

    children?.forEach((element) {
      element.scaleElementWithCenter(matrix);
    });
  }

  @override
  void scaleElementWithCenter(Matrix4 matrix) {
    super.scaleElementWithCenter(matrix);
    children?.forEach((element) {
      element.scaleElementWithCenter(matrix);
    });
  }

  @override
  void rotateBy(double angle, {Offset? anchor}) {
    super.rotateBy(angle, anchor: anchor);
  }

//endregion ---apply--
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

  /// 翻转不参与边界的计算, 只是绘制时的翻转

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

  /// 倾斜矩阵, 锚点无关的矩阵
  Matrix4 get skewMatrix => Matrix4.skew(skewX, skewY);

  /// 缩放矩阵, 锚点默认在0,0位置
  Matrix4 get scaleMatrix => Matrix4.identity()..scale(scaleX, scaleY, 1);

  /// 镜像矩阵, 锚点需要在中心位置
  Matrix4 get flipMatrix => createFlipMatrix(
        flipX: flipX,
        flipY: flipY,
        anchor: rect.center,
      );

  /// 旋转矩阵, 锚点需要在中心位置
  Matrix4 get rotateMatrix => createRotateMatrix(
        angle,
        anchor: rect.center,
      );

  /// 平移矩阵, 平移到指定的目标位置
  Matrix4 get translateMatrix {
    Offset center = Offset(left + width / 2, top + height / 2);
    final rotateMatrix = createRotateMatrix(
      angle,
      anchor: anchor,
    );
    //计算出元素最终的中心点
    center = rotateMatrix.mapPoint(center);
    return Matrix4.identity()
      ..translate(center.dx - width / 2, center.dy - height / 2, 0);
  }

  /// 所有属性的矩阵
  Matrix4 get operateMatrix =>
      translateMatrix * rotateMatrix * scaleMatrix * flipMatrix * skewMatrix;

  //---

  /// 元素最终的中心点
  Offset get paintCenter => paintBounds.center;

  /// 倾斜和缩放后的矩形大小, 未平移和旋转, 翻转不影响size
  Rect get scaleRect {
    final Matrix4 matrix = scaleMatrix * skewMatrix;
    return matrix.mapRect(rect);
  }

  /// 平移到目标位置的[scaleRect], 此矩形还未旋转
  Rect get paintScaleRect {
    //debugger();
    final Matrix4 matrix = translateToSelfCenter(scaleMatrix * skewMatrix);
    return matrix.mapRect(rect);
  }

  /// 将[paintScaleRect]旋转后的矩形边界
  Rect get paintScaleRotateBounds {
    final rect = paintScaleRect;
    final anchor = Offset(rect.width / 2, rect.height / 2);
    final matrix = createRotateMatrix(
      angle,
      anchor: anchor,
    );
    return matrix.mapRect(rect);
  }

  /// 全属性后的边界, 是旋转后的[rect]的外边界
  /// 更贴切的边界是[paintPath]的边界[PathEx.getExactBounds]
  Rect get paintBounds => operateMatrix.mapRect(rect);

  /// 元素全属性绘制路径, 用来判断是否相交
  /// 完全包裹的path路径
  /// ```
  /// Path().let((it) {
  ///    //debugger();
  ///    it.addRect(rect);
  ///    return it.transformPath(operateMatrix);
  /// });
  /// ```
  Path get paintPath => Path()
    ..addRect(rect)
    ..transformPath(operateMatrix);

  //endregion ---get属性---

  //region ---操作方法---

  /// 获取元素的边界
  /// [resetElementAngle] 是否要获取重置角度后的元素边界
  Rect getBounds(bool resetElementAngle) {
    return resetElementAngle ? paintBounds : paintScaleRotateBounds;
  }

  /// 将[matrix]矩阵对应的中心点, 平移到元素的中心点
  /// [matrix] 全量属性
  Matrix4 translateToSelfCenter(Matrix4 matrix) {
    Offset target = paintCenter;
    Offset center = rect.center;
    center = matrix.mapPoint(center);
    matrix.postTranslateBy(
      x: target.dx - center.dx,
      y: target.dy - center.dy,
    );
    return matrix;
  }

  /// 将矩阵平移到锚点位置
  /// [matrix] 输入的矩阵应该是一个全量属性矩阵
  /// [withCenter] false时, 有[flipX].[flipY]的情况下, 会有问题?
  /// [withCenter] true时, 单独旋转矩阵的情况下, 会有问题?
  Matrix4 translateToAnchor(Matrix4 matrix, {bool withCenter = false}) {
    //debugger();
    final originRect = rect;

    if (withCenter) {
      Offset center = originRect.center;
      final targetRotateMatrix = Matrix4.identity()
        ..rotateBy(angle, anchor: anchor);
      final target = targetRotateMatrix.mapPoint(center);

      center = matrix.mapPoint(center);

      //debugger();

      //目标需要到达中心点位置
      matrix.postTranslateBy(
        x: target.dx - center.dx,
        y: target.dy - center.dy,
      );
    } else {
      //0/0矩阵作用矩阵后, 左上角所处的位置
      Offset anchor = originRect.topLeft;
      anchor = matrix.mapPoint(anchor);

      Offset target = this.anchor;

      //debugger();

      //目标需要到达左上角位置
      matrix.postTranslateBy(
        x: target.dx - anchor.dx,
        y: target.dy - anchor.dy,
      );
    }
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

  /// 平移操作
  @api
  void applyTranslate(Matrix4 matrix) {
    final anchor = this.anchor;
    final targetAnchor = matrix.mapPoint(anchor);
    left = targetAnchor.dx;
    top = targetAnchor.dy;
  }

  /// 旋转操作
  @api
  void applyRotate(Matrix4 matrix) {
    //debugger();

    // 锚点也需要翻转
    applyTranslate(matrix);
    angle = (angle + matrix.rotation).sanitizeRadians;
  }

  /// 翻转操作, 互斥操作. 表示是否要在现有的基础上再次翻转
  @api
  void applyFlip({bool? flipX, bool? flipY}) {
    if (flipX == null && flipY == null) {
      return;
    }

    final anchor = paintCenter;

    flipX ??= false;
    flipY ??= false;

    if (flipX) {
      this.flipX = !this.flipX;
    }
    if (flipY) {
      this.flipY = !this.flipY;
    }

    //翻转完之后, 将中心点对齐
    final targetCenter = paintCenter;

    left += anchor.dx - targetCenter.dx;
    top += anchor.dy - targetCenter.dy;
  }

  /// 直接作用缩放
  /// [sxBy].[syBy] 相对缩放
  /// [sxTo].[syTo] 绝对缩放
  @api
  void applyScale({double? sxBy, double? syBy, double? sxTo, double? syTo}) {
    sxTo ??= scaleX * (sxBy ?? 1);
    syTo ??= scaleY * (syBy ?? 1);
    scaleX = sxTo.abs();
    scaleY = syTo.abs();
    flipX = sxTo < 0;
    flipY = syTo < 0;
  }

  /// 应用矩阵[matrix], 通常在缩放时需要使用方法
  /// 使用`qr分解`矩阵, 使用中心点位置作为锚点的偏移依据
  /// 需要保证操作之后的中心点位置不变
  /// 最后需要更新[left].[top]
  @api
  void applyScaleWithCenter(Matrix4 matrix) {
    //debugger();
    Offset originCenter = paintCenter;
    //中点的最终位置
    final targetCenter = matrix.mapPoint(originCenter);

    //应用矩阵
    final Matrix4 matrix_ = operateMatrix.postConcatIt(matrix);
    qrDecomposition(matrix_);

    //现在的中点位置
    final nowCenter = paintScaleRect.center;
    //debugger();

    //更新left top
    left += targetCenter.dx - nowCenter.dx;
    top += targetCenter.dy - nowCenter.dy;

    //l.d(this);
  }

  /// 使用`qr分解`矩阵, 直接使用锚点作为更新锚点依据
  /// 使用场景待定
  @api
  @implementation
  void applyScaleWithAnchor(Matrix4 matrix) {
    //debugger();
    Offset anchor = this.anchor;
    //锚点的最终位置
    final targetAnchor = matrix.mapPoint(anchor);

    //应用矩阵
    final Matrix4 matrix_ = operateMatrix.postConcatIt(matrix);
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
    angle = qr[0].sanitizeRadians;

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
    return 'PaintProperty{left: $left, top: $top, '
        'width: $width, height: $height, scaleX: $scaleX, scaleY: $scaleY, '
        'skewX: $skewX, skewY: $skewY, angle: $angle, flipX: $flipX, flipY: $flipY}';
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
  /// 操作的元素
  ElementPainter? element;

  /// 元素的属性保存
  final Map<ElementPainter, PaintProperty?> propertyMap = {};

  /// 保存信息
  @callPoint
  @mustCallSuper
  void saveFrom(ElementPainter element) {
    this.element = element;
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

/// 属性类型, 支持组合
abstract class PropertyType {
  /// 绘制的相关属性, 比如坐标/缩放/旋转/倾斜等信息
  static int paint = 0x01;

  /// 元素的状态改变, 比如锁定/可见性等信息
  static int state = 0x02;

  /// 元素的数据改变, 比如内容等信息
  static int data = 0x04;
}

/// 诊断
class ElementDiagnosticsNode with DiagnosticableTreeMixin, DiagnosticsMixin {
  final List<ElementPainter> elements;

  ElementDiagnosticsNode(this.elements);

  @override
  String toStringShort() => elements.isEmpty ? '空' : '共[${elements.length}]个元素';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    elements.forEachIndexed((index, element) {
      properties.add(DiagnosticsProperty('[$index]', element));
    });
  }
}
