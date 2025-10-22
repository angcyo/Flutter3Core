part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 绘制元素数据
/// 基础绘制类
///
/// - [painting]
///   - [onPaintingSelfBefore]
///   - [onPaintingSelf]
///
class IElementPainter extends IPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin
    implements IPainterEventHandler {
  /// 画布代理
  CanvasDelegate? canvasDelegate;

  CanvasStyle? get canvasStyle => canvasDelegate?.canvasStyle;

  CanvasViewBox? get canvasViewBox => canvasDelegate?.canvasViewBox;

  /// 是否抑制[CanvasViewBox]的缩放, 用来控制[paintStrokeWidth]不受画布的缩放而缩放
  /// 画布缩放时[paintStrokeWidth]会反向缩放
  /// 通常在绘制描边矢量图形时, 需要开启
  @configProperty
  bool? paintStrokeWidthSuppressCanvasScale;

  /// 画笔默认的宽度
  /// 会在[onPaintingSelfBefore]中使用
  @dp
  @configProperty
  double paintStrokeWidth = 1.toDpFromPx();

  /// 画笔的一些属性, 会在[onPaintingSelfBefore]中使用
  ///
  /// 这几个属性也需要加入回退栈
  /// [onSaveStateStackData]
  /// [onRestoreStateStackData]
  /// [copyElement]
  ///
  /// [updatePainterPaintProperty]
  @configProperty
  PaintingStyle paintStyle = PaintingStyle.stroke;

  /// 会在[onPaintingSelfBefore]中使用
  @configProperty
  Color paintColor = Colors.black;

  /// 画笔, 在[onPaintingSelfBefore]中设置画笔属性
  @configProperty
  Paint paint = Paint()
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// 选中/鼠标悬浮后的边框绘制颜色
  ///  - [paintPropertyRect]
  ///  - [paintPropertyBounds]
  ///  - [paintPropertyPaintPath]
  @configProperty
  Color? _boundsColor;

  Color? get boundsColor {
    return _boundsColor ?? canvasStyle?.canvasAccentColor;
  }

  set boundsColor(Color? color) {
    _boundsColor = color;
  }

  //region component

  /// 元素上覆盖的触摸点处理组件
  PainterTouchSpotHandler? painterTouchSpotHandler;

  //endregion component

  //region core

  /// 附加到[CanvasDelegate]
  @mustCallSuper
  void attachToCanvasDelegate(CanvasDelegate canvasDelegate) {
    if (this.canvasDelegate == canvasDelegate) {
      return;
    }

    final old = this.canvasDelegate;
    if (old != null && old != canvasDelegate) {
      detachFromCanvasDelegate(old);
    }
    this.canvasDelegate = canvasDelegate;
    canvasDelegate.dispatchElementAttachToCanvasDelegate(this);
  }

  /// 从[CanvasDelegate]中移除
  @mustCallSuper
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    if (this.canvasDelegate == canvasDelegate) {
      this.canvasDelegate = null;
      canvasDelegate.dispatchElementDetachFromCanvasDelegate(this);
    }
  }

  //--

  ///[onPaintingSelfBefore]
  ///[onPaintingSelf]
  ///
  /// [CanvasElementManager.paintElement]驱动
  ///
  @entryPoint
  @viewCoordinate
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      onPaintingSelfBefore(canvas, paintMeta);
      onPaintingSelf(canvas, paintMeta);
    });
    painterTouchSpotHandler?.painting(canvas, paintMeta);
  }

  /// [painting]驱动
  /// [onPaintingSelf]绘制之前调用, 用来重新设置画笔样式等
  /// [updatePainterPaintProperty]
  @property
  @sceneCoordinate
  void onPaintingSelfBefore(Canvas canvas, PaintMeta paintMeta) {
    paint
      ..strokeWidth = paintStrokeWidth
      ..color = paintColor
      ..style = paintStyle;
    //抑制画布缩放
    if (paintStrokeWidthSuppressCanvasScale == true) {
      if (paint.style == PaintingStyle.stroke) {
        paint.strokeWidth = paint.strokeWidth / paintMeta.canvasScale;
      }
    }
    if (paintMeta.host == elementOutputHost ||
        paintMeta.host == rasterizeElementHost) {
      //导出元素时, 使用1dp的宽度
      paint.strokeWidth = 1 / paintMeta.canvasScale;
    }
  }

  /// 重写此方法, 实现在画布内绘制自己.
  ///
  /// 作用了画布矩阵, 自身的矩阵需要自身控制.
  ///
  /// [painting]驱动
  /// [paintPropertyRect]
  /// [paintPropertyBounds]
  @overridePoint
  @sceneCoordinate
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {}

  //--

  @override
  bool isEnablePointerEvent() => true;

  /// 响应手势事件
  /// [CanvasEventManager.handleElementPointerEvent]驱动
  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    bool handle = false;
    //debugger();
    //--
    if (painterTouchSpotHandler != null) {
      final localPosition = event.localPosition;
      final offset = canvasDelegate?.canvasViewBox.toScenePoint(localPosition);
      if (offset != null) {
        if (painterTouchSpotHandler!.handlePointerEvent(
          event,
          offset,
          onUpdateCursor: (cursor) {
            if (cursor == null) {
              canvasDelegate?.removeTagCursorStyle("cursor_touchSpot");
            } else {
              canvasDelegate?.addCursorStyle("cursor_touchSpot", cursor);
            }
          },
        )) {
          handle = true;
          canvasDelegate?.canvasEventManager.requestInterceptPointerEvent(
            this,
            event,
          );
        }
        if (event.isPointerFinish) {
          canvasDelegate?.canvasEventManager.cancelInterceptPointerEvent(this);
        }
      }
    }
    return handle;
  }

  /// 处理键盘事件
  /// [CanvasRenderBox.onHandleKeyEventMixin]驱动
  @overridePoint
  bool handleKeyEvent(KeyEvent event) => false;

  //endregion core

  //region api

  /// 刷新画布
  @api
  @mustCallSuper
  void refresh() {
    if (canvasDelegate == null) {
      assert(() {
        l.w("无效的操作[${classHash()}]可能未[attachToCanvasDelegate].");
        return true;
      }());
    } else {
      canvasDelegate?.refresh();
    }
  }

  //endregion api
}

/// 单元素绘制
///
/// - [paintBounds]
/// - [elementsBounds]
/// - [forceVisibleInCanvasBox]
///
/// - [isVisibleInCanvasBox]
///
/// - [ElementPainter]
/// - [ElementGroupPainter]
class ElementPainter extends IElementPainter {
  //region ---属性--

  /// 是否绘制调试信息
  @configProperty
  bool debug = false;

  /// 是否处理鼠标悬停样式
  @configProperty
  bool mouseHoverStyle = true;

  /// 是否强制可见在画布中
  /// [isVisibleInCanvasBox]
  @configProperty
  bool? forceVisibleInCanvasBox;

  //--画笔属性--

  /// 入栈时的保存key值
  /// [onSaveStateStackData]
  /// [onRestoreStateStackData]
  /// [copyElement]
  @configProperty
  String keyPaintStyle = "keyPaintStyle";
  @configProperty
  String keyPaintColor = "keyPaintColor";
  @configProperty
  String keyPaintStrokeWidth = "keyPaintStrokeWidth";

  //--

  /// 元素绘制的状态信息
  PaintState _paintState = PaintState();

  PaintState get paintState => _paintState;

  /// --
  String? get elementUuid => paintState.elementUuid;

  set elementUuid(String? uuid) {
    paintState.elementUuid = uuid;
  }

  String? get elementName => paintState.elementName;

  set elementName(String? name) {
    paintState.elementName = name;
  }

  /*set paintState(PaintState value) {
    //debugger();
    final old = _paintState;
    _paintState = value;
    if (old != value) {
      dispatchSelfPaintPropertyChanged(
        old,
        value,
        PainterPropertyType.state,
        null,
      );
    }
  }*/

  /// 更新[_paintState], 并触发通知
  /// [updatePaintState]
  /// [updatePaintProperty]
  @api
  void updatePaintState(
    PaintState value, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    //debugger();
    final old = _paintState;
    _paintState = value;
    if (old != value) {
      dispatchSelfPaintPropertyChanged(
        old,
        value,
        PainterPropertyType.state,
        fromObj,
        fromUndoType,
      );
    }
  }

  //--get/set

  /// 是否锁定了宽高比
  bool get isLockRatio => paintState.isLockRatio;

  set isLockRatio(bool value) {
    paintState.isLockRatio = value;
    dispatchSelfPaintPropertyChanged(
      paintState,
      paintState,
      PainterPropertyType.state,
      this,
      null,
    );
  }

  /// 元素是否可见, 不可见的元素也不会绘制
  bool get isVisible => paintState.isVisible;

  /// 更新元素的可见性
  ///
  /// - 支持[ElementPainter]
  /// - 支持[ElementGroupPainter]
  @overridePoint
  void updateVisible(bool value, {Object? fromObj}) {
    final old = paintState.isVisible;
    if (old != value) {
      paintState.isVisible = value;
      dispatchSelfPaintPropertyChanged(
        paintState,
        paintState,
        PainterPropertyType.state,
        fromObj ?? this,
        null,
      );
      if (!value) {
        //不可见元素操作
        canvasDelegate?.canvasElementManager.clearSelectedElementIf(this);
      }
    }
  }

  /// 元素是否锁定了操作, 锁定后, 不可选中操作
  bool get isLockOperate => paintState.isLockOperate;

  /// 更新元素锁定操作
  @overridePoint
  void updateLockOperate(bool value, {Object? fromObj}) {
    final old = paintState.isLockOperate;
    if (old != value) {
      paintState.isLockOperate = value;
      dispatchSelfPaintPropertyChanged(
        paintState,
        paintState,
        PainterPropertyType.state,
        fromObj ?? this,
        null,
      );
      if (value) {
        //锁定元素操作
        canvasDelegate?.canvasElementManager.clearSelectedElementIf(this);
      }
    }
  }

  /// 更新元素的名称和uuid
  /// [paintState]
  void updatePainterName(
    String? elementName, {
    String? elementUuid,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    //debugger();
    paintState.elementName = elementName;
    paintState.elementUuid = elementUuid ?? paintState.elementUuid;
    dispatchSelfPaintPropertyChanged(
      paintState,
      paintState,
      PainterPropertyType.state,
      fromObj,
      fromUndoType,
    );
  }

  //endregion ---属性--

  //region ---paintProperty---

  /// 元素绘制的属性信息
  /// 为空表示未初始化
  PaintProperty? _paintProperty;

  PaintProperty? get paintProperty => _paintProperty;

  /*set paintProperty(PaintProperty? value) {
    //debugger();
    final old = _paintProperty;
    _paintProperty = value;
    if (old != value) {
      dispatchSelfPaintPropertyChanged(
          old, value, PainterPropertyType.paint, null);
    }
  }*/

  /// 初始化元素的位置坐标
  /// [paintProperty]
  @api
  void initPaintProperty({
    @dp @sceneCoordinate Rect? rect,
    @dp @sceneCoordinate double? width,
    @dp @sceneCoordinate double? height,
  }) {
    if (rect != null || width != null || height != null) {
      updatePaintProperty(
        PaintProperty()
          ..left = rect?.left ?? 0
          ..top = rect?.top ?? 0
          ..width = rect?.width ?? width ?? screenWidth
          ..height = rect?.height ?? height ?? screenHeight,
      );
    } else {
      updatePaintProperty(null);
    }
  }

  /// 更新[_paintProperty], 并触发通知
  /// [notify] 是否要触发通知
  ///
  /// [updatePaintState]
  @api
  void updatePaintProperty(
    PaintProperty? value, {
    bool? notify,
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    final old = _paintProperty;
    _paintProperty = value;
    if (fromUndoType == UndoType.undo || fromUndoType == UndoType.redo) {
      //撤销重做时, 不触发通知
      notify ??= false;
    }
    if (notify == true || (notify != false && old != value)) {
      dispatchSelfPaintPropertyChanged(
        old,
        value,
        PainterPropertyType.paint,
        fromObj,
        fromUndoType,
        debugLabel: debugLabel,
      );
    }
  }

  /// 通过[Rect]设置元素的绘制属性
  /// [paintProperty]
  void setPaintPropertyFromRect(
    @dp Rect? rect, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    if (rect == null) {
      updatePaintProperty(null, fromObj: fromObj, fromUndoType: fromUndoType);
    } else {
      final property = PaintProperty();
      property.initWith(rect: rect);
      updatePaintProperty(
        property,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    }
  }

  /// 获取元素[paintProperty]的边界
  /// - [PaintProperty.paintBounds]
  /// - [PaintProperty.paintPath]
  @dp
  @sceneCoordinate
  Rect? get elementsBounds {
    return paintProperty?.getBounds(
      canvasDelegate
              ?.canvasElementManager
              .canvasElementControlManager
              .enableResetElementAngle ==
          true,
    );
  }

  /// 更新当前元素的边界到指定位置
  /// 只修改[PaintProperty.left].[PaintProperty.top]
  /// [PaintProperty.scaleX].[PaintProperty.scaleY]
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
      /*paintProperty = property.copyWith()
        ..applyScaleWithCenter(scaleMatrix)
        ..applyTranslate(translate);*/
      scaleElementWithCenter(matrix: scaleMatrix);
      translateElement(translate);
    }
  }

  /// 更新元素的可视大小到指定的大小
  /// [keepAspectRatio] 是否保持宽高比
  @api
  void updateSizeTo({
    @sceneCoordinate @dp Size? size,
    @sceneCoordinate @dp double? width,
    @sceneCoordinate @dp double? height,
    bool keepAspectRatio = false,
    Alignment anchorAlignment = Alignment.topLeft,
  }) {
    width ??= size?.width;
    height ??= size?.height;
    if (width == null && height == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    final property = paintProperty;
    if (property != null) {
      final oldBounds = property.getBounds(true);
      double sx = width == null ? 1.0 : width / oldBounds.width;
      double sy = height == null ? 1.0 : height / oldBounds.height;

      if (width == null) {
        if (keepAspectRatio) {
          sx = sy;
        }
      }
      if (height == null) {
        if (keepAspectRatio) {
          sy = sx;
        }
      }
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(
          sx: sx,
          sy: sy,
          anchor: oldBounds.alignmentOffset(anchorAlignment),
        );
      /*paintProperty = property.copyWith()..applyScaleWithCenter(scaleMatrix);*/
      scaleElementWithCenter(matrix: scaleMatrix);
    }
  }

  /// 更新元素的左上角到指定的位置
  /// 只修改[PaintProperty.left].[PaintProperty.top]
  @api
  void updateLocationTo({
    @sceneCoordinate @dp Offset? location,
    @sceneCoordinate @dp double? x,
    @sceneCoordinate @dp double? y,
  }) {
    x ??= location?.dx;
    y ??= location?.dy;
    if (x == null && y == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    final property = paintProperty;
    if (property != null) {
      final oldBounds = property.getBounds(true);
      final translate = Matrix4.identity()
        ..translate(
          x != null ? x - oldBounds.lt.dx : 0,
          y != null ? y - oldBounds.lt.dy : 0,
        );
      //paintProperty = property.copyWith()..applyTranslate(translate);
      translateElement(translate);
    }
  }

  /// 更新元素的中心点到指定的位置
  /// 只修改[PaintProperty.left].[PaintProperty.top]
  @api
  void updateCenterTo(
    @sceneCoordinate @dp Offset? center, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    if (center == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    final property = paintProperty;
    if (property != null) {
      final oldBounds = property.getBounds(true);
      final translate = Matrix4.identity()
        ..translate(
          center.dx - oldBounds.center.dx,
          center.dy - oldBounds.center.dy,
        );
      updatePaintProperty(
        property.copyWith()..applyTranslate(translate),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
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
      final resetElementAngle =
          canvasDelegate
              ?.canvasElementManager
              .canvasElementControlManager
              .enableResetElementAngle ??
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

  //endregion ---paintProperty---

  //region ---group---

  /// 是否在选中的元素内, 也就是是否被选中
  /// 元素是否被选中, 元素是否在元素列表中
  bool get isInElementSelectComponent =>
      canvasDelegate
          ?.canvasElementManager
          .canvasElementControlManager
          .elementSelectComponent
          .children
          ?.contains(this) ==
      true;

  /// 父元素
  /// 当自身属性改变后会通知父元素[dispatchSelfPaintPropertyChanged]
  ElementGroupPainter? get parentGroupPainter =>
      canvasDelegate?.canvasElementManager.findElementGroupPainter(this);

  /// 当当前元素被组合到指定的父元素中时触发
  /// [ElementGroupPainter.resetChildren]
  @overridePoint
  void onSelfElementGroupTo(ElementGroupPainter parent) {}

  /// 当前元素从父元素中移除时触发
  @overridePoint
  void onSelfElementUnGroupFrom(ElementGroupPainter parent) {}

  //endregion ---group---

  //region ---paint---

  /// 元素绘制缓存, 当缓存存在时, 应该直接绘制缓存
  /// 否则应该将元素绘制到缓存中, 并绘制缓存数据到画布上
  Picture? painterCachePicture;

  /// 使缓存无效
  /// [refresh] 是否通知界面刷新
  @api
  void invalidate({bool refresh = true}) {
    painterCachePicture?.dispose();
    painterCachePicture = null;
    paintingSelfOnPicture(refresh: refresh);
  }

  /// 元素绘制缓存, 当缓存存在时, 应该直接绘制缓存
  /// 调用此方法, 将数据绘制在缓存上
  ///
  /// [update] 是否更新缓存, 否则缓存不存在时才绘制
  /// [refresh] 更新缓存后, 是否通知界面刷新
  ///
  @callPoint
  void paintingSelfOnPicture({
    CanvasAction? action,
    bool update = false,
    bool refresh = false,
  }) {
    if (update || painterCachePicture == null) {
      painterCachePicture?.dispose();
      try {
        painterCachePicture = drawPicture((canvas) {
          onPaintingSelfOnPicture(canvas);
          action?.call(canvas);
        });
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
      if (refresh) {
        this.refresh();
      }
    }
  }

  /// 重写此方法, 在缓存上绘制元素, 并在[onPaintingSelf]中自动绘制到画布上.
  /// 需要主动调用一次[paintingSelfOnPicture]方法触发
  /// [painterCachePicture]
  /// [paintingSelfOnPicture]
  ///
  /// 抛出异常, 则不进行赋值
  @overridePoint
  void onPaintingSelfOnPicture(Canvas canvas) {
    //no op
  }

  //--

  /// 主动更新画笔[paint]的属性, 但是不更新属性值
  /// [painting]
  /// [onPaintingSelfBefore]
  @overridePoint
  void updatePainterPaintProperty({
    //--
    PaintingStyle? style,
    Color? color,
    double? strokeWidth,
    //--
    Object? fromObj,
    UndoType? fromUndoType,
    bool notify = true,
  }) {
    bool isSet = false;
    if (style != null) {
      paint.style = style;
      isSet = true;
    }
    if (color != null) {
      paint.color = color;
      isSet = true;
    }
    if (strokeWidth != null) {
      paint.strokeWidth = strokeWidth;
      isSet = true;
    }
    //
    if (isSet && notify) {
      dispatchSelfPaintPropertyChanged(
        paint,
        paint,
        PainterPropertyType.mode,
        fromObj,
        fromUndoType,
      );
    }
  }

  ///[onPaintingSelfBefore]
  ///[onPaintingSelf]
  ///
  /// [CanvasElementManager.paintElement]驱动
  ///
  @entryPoint
  @viewCoordinate
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    paintMeta.withPaintMatrix(canvas, () {
      //--
      onPaintingSelfBefore(canvas, paintMeta);
      final updateTempColor = paintState.isHover || paintState.color != null;
      if (updateTempColor) {
        //--临时颜色/悬停绘制颜色支持
        updatePainterPaintProperty(
          fromObj: this,
          notify: false,
          color: paintState.color ?? boundsColor,
        );
      }
      //--
      onPaintingSelf(canvas, paintMeta);
      if (updateTempColor) {
        //恢复临时颜色
        updatePainterPaintProperty(
          fromObj: this,
          notify: false,
          color: paintColor,
        );
      }
    });
    //--
    painterTouchSpotHandler?.painting(canvas, paintMeta);
  }

  /// 重写此方法, 实现在画布内绘制自己
  /// [painting]驱动
  ///
  ///  - [paintPropertyRect]
  ///  - [paintPropertyBounds]
  ///  - [paintPropertyPaintPath]
  @sceneCoordinate
  @overridePoint
  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //paint.color = Colors.black;
    //paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
    if (paintMeta.host is CanvasDelegate) {
      //debugger();

      //绘制缓存
      if (painterCachePicture != null) {
        //lTime.tick();
        canvas.drawPicture(painterCachePicture!);
        //l.w("[ElementPainter.onPaintingSelf]一帧耗时->${lTime.time()}");
      }

      if (debug ||
          canvasDelegate?.canvasElementManager.isElementSelected(this) ==
              true) {
        //debugger();
        //绘制元素旋转的矩形边界
        paintPropertyRect(canvas, paintMeta, paint);

        /*assert(() {
          //绘制元素包裹的边界矩形
          paintPropertyBounds(canvas, paintMeta, paint);
          paintPropertyPaintPath(canvas, paintMeta, paint);
          return true;
        }());*/
      }
      if (paintState.isHover && this is ImageElementPainter) {
        paintPropertyPaintPath(canvas, paintMeta, paint);
      }
    }
  }

  /// 绘制元素的旋转矩形, 用来提示元素的矩形+旋转信息
  /// [onPaintingSelf]
  ///
  ///  - [paintPropertyRect]
  ///  - [paintPropertyBounds]
  ///  - [paintPropertyPaintPath]
  @property
  @sceneCoordinate
  void paintPropertyRect(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      paint.withSavePaint(() {
        debugger(when: debugLabel != null);
        paint
          //边框的颜色
          ..color = boundsColor ?? paint.color
          //样式
          ..style = PaintingStyle.stroke
          //抵消画布缩放带来的宽度变细/变粗
          ..strokeWidth = 1 / paintMeta.canvasScale;

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
  ///
  ///  - [paintPropertyRect]
  ///  - [paintPropertyBounds]
  ///  - [paintPropertyPaintPath]
  @property
  void paintPropertyBounds(
    Canvas canvas,
    PaintMeta paintMeta,
    Paint paint, {
    Color? color,
  }) {
    paintProperty?.let((it) {
      //debugger();
      paint.withSavePaint(() {
        paint.color = color ?? boundsColor ?? paint.color;
        //canvas.drawPath(it.paintPath, paint);
        canvas.drawRect(it.paintBounds, paint);
      });
    });
  }

  /// 绘制元素全贴合的路径边框
  /// [paintPropertyBounds]
  /// [onPaintingSelf]
  ///
  ///  - [paintPropertyRect]
  ///  - [paintPropertyBounds]
  ///  - [paintPropertyPaintPath]
  @property
  @sceneCoordinate
  void paintPropertyPaintPath(Canvas canvas, PaintMeta paintMeta, Paint paint) {
    paintProperty?.let((it) {
      //debugger();
      paint.withSavePaint(() {
        //paint.color = Colors.purpleAccent;
        //debugger();
        paint
          //边框的颜色
          ..color = boundsColor ?? paint.color
          //样式
          ..style = PaintingStyle.stroke
          //抵消画布缩放带来的宽度变细/变粗
          ..strokeWidth = 1 / paintMeta.canvasScale;
        canvas.drawPath(it.paintPath, paint);
      });
    });
  }

  /// 在操作属性的矩阵下, 绘制一个[TextPainter]对象
  /// [onPaintingSelf]
  @CallFrom("onPaintingSelf")
  @property
  @sceneCoordinate
  void paintItTextPainter(
    Canvas canvas,
    PaintMeta paintMeta,
    BaseTextPainter? textPainter,
  ) {
    final painter = textPainter;
    if (painter != null) {
      canvas.withMatrix(paintProperty?.operateMatrix, () {
        //painter.paint(canvas, Offset.zero);
        //debugger();
        painter.painterText(canvas, Offset.zero);
      });
    }
  }

  /// 在操作属性的矩阵下, 绘制一个[UiImage]对象
  /// [convertToMmSize] 是否将图片的大小(默认dp)转换成mm大小
  /// [onPaintingSelf]
  @CallFrom("onPaintingSelf")
  @property
  @sceneCoordinate
  void paintItUiImage(
    Canvas canvas,
    PaintMeta paintMeta,
    UiImage? image, {
    bool convertToMmSize = false,
  }) {
    if (image != null) {
      final scale = Matrix4.identity();
      if (convertToMmSize) {
        //因为图片的宽高是mm单位存档的, 所以需要转换成dp单位并绘制
        final sx = image.width.toDpFromMm() / image.width;
        final sy = image.height.toDpFromMm() / image.height;
        scale.scale(sx, sy);
      }
      canvas.withMatrix(
        paintProperty?.operateMatrix.let((it) => it * scale),
        () {
          canvas.drawImage(image, Offset.zero, paint);
        },
      );
    }
  }

  /// 在操作属性的矩阵下, 绘制一个[Path]对象
  /// [onPaintingSelf]
  @CallFrom("onPaintingSelf")
  @property
  @sceneCoordinate
  void paintItUiPath(Canvas canvas, PaintMeta paintMeta, UiPath? path) {
    if (path != null) {
      if (paintProperty?.rect.isEmpty == true &&
          paint.style == PaintingStyle.fill) {
        //在没有宽度或高度时, 比如线. 此时必须要设置style为stroke, 否则绘制出来的线看不到
        paint.style = PaintingStyle.stroke;
      }
      //debugger(when: paintMeta.host == elementOutputHost);
      Path? drawPath = path.transformPath(paintProperty?.operateMatrix);
      /*if (paintMeta.host == elementOutputHost &&
          paint.style == PaintingStyle.stroke) {
        //描边输出的时候, 缩放1个dp单位, 防止看不到
        final bound = elementsBounds;
        if (bound != null) {
          final sx = (bound.width - 1) / bound.width;
          final sy = (bound.height - 1) / bound.height;
          final scaleStrokeMatrix =
              createScaleMatrix(sx: sx, sy: sy, anchor: bound.lt);
          //debugger(when: paintMeta.host == elementOutputHost);
          drawPath = drawPath.transformPath(scaleStrokeMatrix);
        }
      }*/
      canvas.drawPath(drawPath, paint);
    }
  }

  //---

  /// 判断当前元素是否与指定的点相交
  ///
  /// - [point] 是否与点相交
  /// - [rect] 是否与矩形相交
  /// - [path] 是否与路径相交
  ///
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
    final property = _paintProperty;
    if (property == null || !isVisible) {
      final elementBounds = elementsBounds;
      if (elementBounds != null) {
        //没有绘制属性, 但是有元素边界, 可能是自定义的元素
        path ??= Path()
          ..addRect(rect ?? Rect.fromLTWH(point!.dx, point.dy, 1, 1));
        bool hit = elementBounds.toPath().intersects(path);
        if (!hit && inflate) {
          hit = elementBounds.inflateValue(10).toPath().intersects(path);
        }
        return hit;
      }
      return false;
    }
    path ??= Path()..addRect(rect ?? Rect.fromLTWH(point!.dx, point.dy, 1, 1));
    bool hit = property.paintPath.intersects(path);
    if (!hit && inflate) {
      //没有命中时, 膨胀一下, 再判断一次
      @dp
      final elementBounds = elementsBounds;
      if (elementBounds != null) {
        //元素被缩放到很小
        final isLittleElement =
            elementBounds.width <= 10 && elementBounds.height <= 10;

        //元素是线条元素
        final isLineElement =
            (property.width == 0 && property.height != 0) ||
            (property.width != 0 && property.height == 0);

        //绘制时是线条
        final isPainterLine =
            (elementBounds.width == 0 && elementBounds.height != 0) ||
            (elementBounds.width != 0 && elementBounds.height == 0);

        if (isLittleElement || isLineElement || isPainterLine) {
          final bounds = property.paintPath.getExactBounds();
          //debugger();
          hit = bounds.inflateValue(10).toPath().intersects(path);
        }
      }
    }
    return hit;
  }

  /// 当前元素在画布中是否可见, 不可见的元素不会在画布中绘制
  ///
  /// - [forceVisibleInCanvasBox]
  ///
  /// [hitTest]
  bool isVisibleInCanvasBox(CanvasViewBox viewBox) =>
      forceVisibleInCanvasBox == true ||
      (viewBox.canvasSceneVisibleBounds.isValid &&
          paintState.isVisible &&
          hitTest(rect: viewBox.canvasSceneVisibleBounds));

  //---

  /// 当前选中的元素是否支持指定的控制点
  /// [ControlTypeEnum]
  bool isElementSupportControl(ControlTypeEnum type) {
    if (type == ControlTypeEnum.lock) {
      final bounds = elementsBounds;
      if (bounds?.width == 0 || bounds?.height == 0) {
        return false;
      }
    } else if (type == ControlTypeEnum.width) {
      return (elementsBounds?.width ?? 0).notEqualTo(0);
    } else if (type == ControlTypeEnum.height) {
      return (elementsBounds?.height ?? 0).notEqualTo(0);
    }
    return true;
  }

  /// 派发元素属性改变
  /// [old] 旧的属性
  /// [value] 新的属性
  /// [propertyType] 改变的属性类型
  /// [fromObj] 触发改变事件的对象
  ///
  /// [PaintProperty]
  /// [PaintState]
  /// [ElementPainter.paintState]
  /// [ElementPainter.paintProperty]
  ///
  /// - [ElementSelectComponent.dispatchSelfPaintPropertyChanged]
  /// - [ElementGroupPainter.onChildPaintPropertyChanged]
  /// - [CanvasElementControlManager.onHandleElementPropertyChanged]
  ///
  void dispatchSelfPaintPropertyChanged(
    dynamic old,
    dynamic value,
    PainterPropertyType propertyType,
    Object? fromObj,
    UndoType? fromUndoType, {
    String? debugLabel,
  }) {
    /*assert(() {
      l.w("[${classHash()}]...dispatchSelfPaintPropertyChanged");
      return true;
    }());*/
    debugger(when: debugLabel != null);
    if (propertyType == PainterPropertyType.paint) {
      painterTouchSpotHandler?.parentMatrix = paintProperty?.operateMatrix;
    }
    parentGroupPainter?.onChildPaintPropertyChanged(
      this,
      old,
      value,
      propertyType,
      fromObj,
      fromUndoType,
      debugLabel: debugLabel,
    );
    canvasDelegate?.dispatchCanvasElementPropertyChanged(
      this,
      old,
      value,
      propertyType,
      fromObj,
      fromUndoType,
      debugLabel: debugLabel,
    );
  }

  /// 派发元素数据改变, 通常意味着这个元素要产生新的数据了
  ///
  /// - 此时可以重置元素id/索引等信息
  ///
  /// [rotateElement]
  /// [translateElement]
  /// [flipElement]
  /// [scaleElementWithCenter]
  /// [onlyScaleSelfElement]
  void dispatchSelfElementRawChanged(
    ElementDataType elementDataType, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {}

  //endregion ---paint---

  //region ---apply paintProperty--

  /// 平移元素, by(增量)的方式
  /// [translateElement]
  /// [translateElementBy]
  /// [translateElementTo]
  @api
  void translateElement(
    Matrix4 matrix, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    paintProperty?.let((it) {
      updatePaintProperty(
        it.copyWith()..applyTranslate(matrix),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    });
    dispatchSelfElementRawChanged(
      ElementDataType.size,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  /// 平移元素, 将元素平移一定的距离[tx].[ty]
  /// [translateElement]
  /// [translateElementBy]
  /// [translateElementTo]
  @api
  void translateElementBy({
    double? tx,
    double? ty,
    Offset? offset,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    tx ??= offset?.dx;
    ty ??= offset?.dy;
    if (tx == null && ty == 0) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    translateElement(
      createTranslateMatrix(tx: tx ?? 0.0, ty: ty ?? 0.0),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  /// 平移元素, 将元素平移到指定位置[x].[y]
  /// [translateElement]
  /// [translateElementBy]
  /// [translateElementTo]
  @api
  void translateElementTo({double? x, double? y}) {
    if (x == null && y == 0) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    paintProperty?.let((it) {
      final bounds = it.paintBounds;
      x ??= bounds.left;
      y ??= bounds.top;
      translateElement(
        createTranslateMatrix(tx: x! - bounds.left, ty: y! - bounds.top),
      );
    });
  }

  /// 旋转元素, [ElementGroupPainter]]需要重写处理
  /// [refTargetRadians] 参考的需要旋转到的目标角度, 用来决定存储值时的正负数 单位: 弧度
  @api
  @overridePoint
  void rotateElement(
    Matrix4 matrix, {
    double? refTargetRadians,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    paintProperty?.let((it) {
      updatePaintProperty(
        it.copyWith()..applyRotate(matrix, refTargetRadians: refTargetRadians),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
      dispatchSelfElementRawChanged(
        ElementDataType.size,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    });
  }

  /// 旋转元素, [ElementGroupPainter]需要重写处理
  /// [radians] 弧度
  /// [anchor] 旋转锚点, 不指定时, 默认使用[paintBounds]中心
  @api
  @overridePoint
  void rotateElementTo(
    double radians, {
    Offset? anchor,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    paintProperty?.let((it) {
      updatePaintProperty(
        it.copyWith()..rotateTo(radians: radians, anchor: anchor),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
      dispatchSelfElementRawChanged(
        ElementDataType.size,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    });
  }

  /// 旋转元素, 以元素中心点为锚点
  /// [radians] 弧度
  /// [refTargetRadians] 参考的需要旋转到的目标角度, 用来决定存储值时的正负数 单位: 弧度
  /// [anchor] 旋转锚点, 不指定时, 以元素中心点为锚点
  /// [applyMatrixWithAnchor]
  /// [rotateElement]
  @api
  @indirectProperty
  void rotateBy(
    double radians, {
    Offset? anchor,
    double? refTargetRadians,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    paintProperty?.let((it) {
      //debugger();
      anchor ??= it.paintCenter;
      final matrix = Matrix4.identity()..rotateBy(radians, anchor: anchor);
      rotateElement(
        matrix,
        refTargetRadians: refTargetRadians,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    });
  }

  /// 旋转元素到指定角度, 以元素中心点为锚点
  /// [radians] 弧度
  @api
  @indirectProperty
  void rotateTo(double radians, {Offset? anchor}) {
    paintProperty?.let((it) {
      //debugger();
      anchor ??= it.paintCenter;
      rotateElementTo(radians, anchor: anchor);
    });
  }

  /// 翻转元素, 互斥操作
  /// 这种方式翻转元素, 有可能会跑到边界外, 所以需要重新计算边界
  /// [flipX] 是否要水平翻转
  /// [flipY] 是否要垂直翻转
  /// [CanvasElementControlManager.flipElement]
  @api
  void flipElement({
    bool? flipX,
    bool? flipY,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    paintProperty?.let((it) {
      updatePaintProperty(
        it.copyWith()..applyFlip(flipX: flipX, flipY: flipY),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    });
    dispatchSelfElementRawChanged(
      ElementDataType.size,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  /// 使用缩放的方式翻转元素
  /// 这种方法的翻转不会跑到边界外
  /// [CanvasElementControlManager.flipElementWithScale]
  @api
  void flipElementWithScale({
    bool? flipX,
    bool? flipY,
    Offset? anchor,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    final scaleMatrix = Matrix4.identity()
      ..scaleBy(
        sx: flipX == true ? -1 : 1,
        sy: flipY == true ? -1 : 1,
        anchor: anchor ?? paintProperty?.paintCenter,
      );
    scaleElementWithCenter(
      matrix: scaleMatrix,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  /// 作用一个缩放矩阵
  /// [onlyScaleSelfElement]
  /// [scaleElementWithCenter]
  @api
  void scaleElement({
    double? sx,
    double? sy,
    //--
    Offset? anchor,
    Alignment? anchorAlignment,
    //--
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    if (sx == null && sy == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    anchor ??= anchorAlignment != null
        ? paintProperty?.getAnchor(anchorAlignment)
        : null;

    //test
    //anchor = paintProperty?.getAnchor(Alignment.center);

    if (anchor == null) {
      onlyScaleSelfElement(
        sx: sx ?? (isLockRatio ? sy : null),
        sy: sy ?? (isLockRatio ? sx : null),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
    } else {
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(
          sx: sx ?? (isLockRatio ? sy : null),
          sy: sy ?? (isLockRatio ? sx : null),
          anchor: anchor,
        );
      scaleElementWithCenter(
        matrix: scaleMatrix,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
    }
  }

  /// 应用矩阵, 通常在子元素缩放时需要使用方法
  /// - 保持中心点不变
  @api
  void scaleElementWithCenter({
    double? sx,
    double? sy,
    Matrix4? matrix,
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    if (matrix == null && sx == null && sy == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    matrix ??= Matrix4.identity()
      ..scaleBy(
        sx: sx ?? (isLockRatio ? sy : null),
        sy: sy ?? (isLockRatio ? sx : null),
      );
    //debugger();
    final paintProperty = this.paintProperty;
    if (paintProperty != null) {
      updatePaintProperty(
        paintProperty.copyWith()..applyScaleWithCenter(matrix),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
      dispatchSelfElementRawChanged(
        ElementDataType.size,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    }
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
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    //debugger();
    paintProperty?.let((it) {
      updatePaintProperty(
        it.copyWith()..applyScale(sxBy: sx, syBy: sy, sxTo: sxTo, syTo: syTo),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
    });
    dispatchSelfElementRawChanged(
      ElementDataType.size,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  //endregion ---apply paintProperty--

  //region ---canvas---

  /// 响应事件, 手势不在元素内, 也会响应事件.
  ///
  /// - 处理悬停时的高亮颜色
  ///
  /// - [CanvasStyle.enableElementControl] 使能响应事件
  /// - [CanvasStyle.enableElementEvent] 使能响应事件
  ///
  /// [CanvasEventManager.handlePointerEvent] 驱动 ↓
  /// [CanvasElementManager.handleElementPointerEvent] 驱动
  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    bool handle = super.handlePointerEvent(event);
    final canvasDelegate = this.canvasDelegate;
    if (canvasDelegate == null) {
      return handle;
    }
    if (event.isPointerHover || event.isPointerDown) {
      final localPosition = event.localPosition;
      final offset = canvasDelegate.canvasViewBox.toScenePoint(localPosition);
      if (event.isPointerHover && mouseHoverStyle) {
        //悬停样式处理
        final selectComponent =
            canvasDelegate.canvasElementManager.selectComponent;
        final cursor = isMacOS
            ? SystemMouseCursors.click
            : SystemMouseCursors.move;
        if (selectComponent.isSelectedElement &&
            selectComponent.hitTest(point: offset)) {
          //在选择组件上悬停
          //debugger();
          canvasDelegate.addCursorStyle("cursor_element", cursor);
          return true;
        } else {
          canvasDelegate.removeCursorStyle("cursor_element", cursor);
        }
      }

      //命中检查
      final isHit = hitTest(point: offset);

      if (event.isPointerDown && isHit) {
        paintState.pointerDownPoint = localPosition;
        //取消所有元素悬停状态
        canvasDelegate.canvasElementManager.visitElementPainter(
          (element) {
            element.onHoverChanged(event, false);
          },
          before: false,
          after: false,
        );
        return true;
      } else if (mouseHoverStyle) {
        final oldHover = paintState.isHover;
        if (oldHover != isHit) {
          if (isHit) {
            //取消其他元素的悬停状态
            canvasDelegate.canvasElementManager.visitElementPainter(
              (element) {
                element.onHoverChanged(event, false);
              },
              before: false,
              after: false,
            );
            handle = onHoverChanged(event, isHit);
          } else {
            handle = onHoverChanged(event, isHit);
          }
        }
      }
    }
    //处理点击元素事件
    if (event.isPointerFinish) {
      if (event.isPointerUp &&
          paintState.isPointerDown &&
          !event.isMoveExceed(paintState.pointerDownPoint)) {
        final localPosition = event.localPosition;
        final offset = canvasDelegate.canvasViewBox.toScenePoint(localPosition);
        handle = onSelfHandlePointerClick(event, offset);
      }
      paintState.pointerDownPoint = null;
    }
    return handle;
  }

  /// 当点击元素时触发
  @overridePoint
  bool onSelfHandlePointerClick(
    @viewCoordinate PointerEvent event,
    @sceneCoordinate Offset point,
  ) {
    return false;
  }

  /// 鼠标悬停状态改变
  /// 如果在[ElementGroupPainter]中悬停, 则所有子元素都应该属于悬停状态
  /// 如果在[ElementSelectComponent]中悬停, 则需要特殊处理
  /// [paintState]
  /// [painting]
  ///
  /// [ElementPainter.handlePointerEvent]驱动
  @overridePoint
  bool onHoverChanged(@viewCoordinate PointerEvent event, bool hover) {
    if (paintState.isHover != hover) {
      paintState.hoverPoint = event.localPosition;
      refresh();
    }
    return hover;
  }

  //endregion ---canvas---

  //region ---创建/恢复回退栈---

  /// 保存当前元素的状态
  /// 使用[ElementStateStack.restore]恢复状态
  /// [otherStateElementList]额外要存储的元素列表
  /// [otherStateExcludeElementList].[otherStateElementList]在存储时, 需要排除的元素列表
  ///
  ElementStateStack createStateStack({
    List<ElementPainter>? otherStateElementList,
    List<ElementPainter>? otherStateExcludeElementList,
  }) => ElementStateStack()
    ..saveFrom(
      this,
      otherStateElementList:
          otherStateElementList ?? childList?.parentPainterList,
      otherStateExcludeElementList: otherStateExcludeElementList ?? childList,
    );

  /// 保存元素的额外数据到回退栈中
  /// [dataMap] 用来存储额外数据
  /// [onSaveStateStackData]
  /// [onRestoreStateStackData]
  @mustCallSuper
  void onSaveStateStackData(
    ElementStateStack stateStack,
    Map<String, dynamic> dataMap,
  ) {
    dataMap[keyPaintStyle] = paintStyle;
    dataMap[keyPaintColor] = paintColor;
    dataMap[keyPaintStrokeWidth] = paintStrokeWidth;
  }

  /// 恢复元素的额外数据
  /// [dataMap] 额外的数据, 用来恢复
  /// [onSaveStateStackData]
  /// [onRestoreStateStackData]
  @mustCallSuper
  void onRestoreStateStackData(
    ElementStateStack stateStack,
    Map<String, dynamic>? dataMap,
  ) {
    if (dataMap != null) {
      paintStyle = dataMap[keyPaintStyle];
      paintColor = dataMap[keyPaintColor];
      paintStrokeWidth = dataMap[keyPaintStrokeWidth];
    }
  }

  /// 当元素的状态恢复后, 收尾的回调
  /// [ElementStateStack.restore]
  @mustCallSuper
  void onRestoreStateStack(ElementStateStack stateStack) {
    updatePainterPaintProperty(
      fromObj: stateStack,
      fromUndoType: UndoType.redo,
    );
  }

  //endregion ---创建回退栈---

  //region ---api---

  /// 单签元素是否包含指定的元素
  @api
  bool containsElement(ElementPainter? element) {
    return this == element;
  }

  /// 获取单个元素列表
  @api
  List<ElementPainter> getSingleElementList({
    bool includeGroupPainter = false,
  }) {
    return [this];
  }

  /// 仅获取所有[ElementGroupPainter]的元素
  @api
  List<ElementGroupPainter>? getGroupPainterList() {
    return null;
  }

  /// 复制元素
  /// [template] 模板元素, 用来创建新元素, 默认是[ElementPainter]
  /// [parent] 父元素, 如果有
  @api
  ElementPainter copyElement({
    ElementPainter? template,
    ElementGroupPainter? parent,
    bool resetUuid = true,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    final newPainter = template ?? ElementPainter();

    //--
    newPainter
      ..debug = debug
      ..forceVisibleInCanvasBox = forceVisibleInCanvasBox
      ..paintStrokeWidthSuppressCanvasScale =
          paintStrokeWidthSuppressCanvasScale
      ..keyPaintStyle = keyPaintStyle
      ..keyPaintColor = keyPaintColor
      ..keyPaintStrokeWidth = keyPaintStrokeWidth
      ..paintStyle = paintStyle
      ..paintColor = paintColor
      ..paintStrokeWidth = paintStrokeWidth;

    //--
    newPainter.updatePaintState(
      paintState.copyWith(),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    newPainter.updatePaintProperty(
      paintProperty?.copyWith(),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    if (resetUuid) {
      newPainter.paintState.elementUuid = $uuid;
    }
    return newPainter;
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
        painting(canvas, const PaintMeta(host: elementOutputHost));
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
  ///
  /// - [elementOutputBoundsPath]
  /// - [elementOutputPath]
  ///
  /// - [CanvasElementPainterIterableEx.getAllElementOutputPathList]
  @dp
  @output
  Path? get elementOutputBoundsPath => paintProperty?.paintPath;

  /// 是否是路径元素
  /// [elementOutputPathList]
  @output
  bool get isPathElement => elementOutputPathList.isNotEmpty;

  /// 获取元素的transform后输出[Path], 当前仅支持[PathElementPainter]元素
  /// 重写此方法以便支持更多类型的元素
  ///
  /// 此属性的数据, 同时也是矢量布尔运算的数据.
  /// 如果所有对象都具有此属性, 则说明可以进行布尔运算.
  ///
  /// [VectorPathEx.toSvgPathString]
  ///
  /// - [elementOutputBoundsPath]
  /// - [elementOutputPath]
  @dp
  @output
  @overridePoint
  Path? get elementOutputPath {
    if (this is PathElementPainter) {
      return (this as PathElementPainter).operatePath;
    }
    return null;
  }

  /// 获取元素的transform后所有输出[Path], 支持[ElementGroupPainter]
  /// 其他元素可能需要重写[elementOutputPath]方法
  @dp
  @output
  List<Path> get elementOutputPathList {
    final result = <Path>[];
    if (this is ElementGroupPainter) {
      (this as ElementGroupPainter).children?.forEach((element) {
        result.addAll(element.elementOutputPathList);
      });
    } else {
      elementOutputPath?.let((it) => result.add(it));
    }
    return result;
  }

  /// 输入一个0,0位置原始的路径[inputPath], 输出一个经过元素操作后的新路径
  /// 元素操作后对应的路径数据
  /// [transformElementOperatePath]
  /// [transformElementOperatePathList]
  Path? transformElementOperatePath(Path? inputPath) {
    if (inputPath == null) {
      return null;
    }
    return inputPath.transformPath(paintProperty?.operateMatrix);
  }

  /// [transformElementOperatePath]
  /// [transformElementOperatePathList]
  List<Path>? transformElementOperatePathList(List<Path>? inputPathList) {
    if (isNil(inputPathList)) {
      return null;
    }
    return inputPathList?.transformPath(paintProperty?.operateMatrix);
  }

  //endregion ---output---

  @override
  String toStringShort() =>
      '${classHash()} 边界:${paintProperty?.getBounds(canvasDelegate?.canvasElementManager.canvasElementControlManager.enableResetElementAngle == true)}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty('debug', debug));
    properties.add(DiagnosticsProperty('debugLabel', debugLabel));
    properties.add(DiagnosticsProperty('uuid', paintState.elementUuid));
    properties.add(DiagnosticsProperty('name', paintState.elementName));
    properties.add(DiagnosticsProperty('paintProperty', paintProperty));
    properties.add(DiagnosticsProperty('paintState', paintState));
    properties.add(DiagnosticsProperty('bounds', elementsBounds));

    final canvasViewBox = canvasDelegate?.canvasViewBox;
    if (canvasViewBox != null) {
      properties.add(
        DiagnosticsProperty('是否在画布中', isVisibleInCanvasBox(canvasViewBox)),
      );
    }
  }
}

/// 一组元素的绘制
/// [ElementPainter]
/// [ElementGroupPainter]
class ElementGroupPainter extends ElementPainter {
  /// 创建一个组合元素, 如果元素数量大于1, 则创建一个组合元素, 否则返回第一个元素
  static ElementPainter? createGroupIfNeed(List<ElementPainter>? elements) {
    if (elements != null && elements.length > 1) {
      return ElementGroupPainter()..resetChildren(elements);
    }
    return elements?.firstOrNull;
  }

  /// 子元素列表
  List<ElementPainter>? children = [];

  /// 是否为空
  bool get isEmpty => children?.isEmpty ?? true;

  /// 是否绘制子元素, 在[ElementSelectComponent]组件中, 可以关闭子元素绘制.
  /// 如果要实现选中元素在顶层绘制, 那就不能设置为false
  bool paintChildren = true;

  ElementGroupPainter() {
    paintState.elementName = 'Group';
  }

  /// 创建一个组合元素, 并且重置组合元素角度
  ElementGroupPainter.from(List<ElementPainter>? children) {
    ElementGroupPainter painter = ElementGroupPainter();
    painter.resetChildren(children);
  }

  /// 仅是[ElementGroupPainter], 而非其他对象
  ElementGroupPainter? get onlyElementGroupPainter =>
      this is ElementSelectComponent ? null : this;

  @override
  void updateLockOperate(bool value, {Object? fromObj}) {
    super.updateLockOperate(value, fromObj: fromObj ?? this);
    children?.forEach((element) {
      element.updateLockOperate(value, fromObj: fromObj ?? this);
    });
  }

  @override
  void updateVisible(bool value, {Object? fromObj}) {
    super.updateVisible(value, fromObj: fromObj ?? this);
    children?.forEach((element) {
      element.updateVisible(value, fromObj: fromObj ?? this);
    });
  }

  @override
  bool onHoverChanged(PointerEvent event, bool hover) {
    children?.forEach((element) {
      element.onHoverChanged(event, hover);
    });
    return super.onHoverChanged(event, hover);
  }

  //region ---core--

  /// 重置子元素
  /// [CanvasElementManager.groupElement]
  /// [CanvasElementManager.ungroupElement]
  @api
  void resetChildren(
    List<ElementPainter>? children, {
    @autoInjectMark bool? resetGroupAngle,
  }) {
    //可能需要先解父元素
    this.children?.forEach((element) {
      if (children?.contains(element) != true) {
        element.onSelfElementUnGroupFrom(this);
      }
    });
    this.children = children;
    //重新追加父元素
    children?.forEach((element) {
      if (element.parentGroupPainter == this) {
        //已经是子元素了
      } else {
        if (element.parentGroupPainter != null) {
          element.onSelfElementUnGroupFrom(element.parentGroupPainter!);
        }
        element.onSelfElementGroupTo(this);
      }
    });
    updatePaintPropertyFromChildren(resetGroupAngle: resetGroupAngle);
  }

  /// 使用子元素的属性, 更新自身的绘制属性
  /// [resetGroupAngle] 是否要重置旋转角度
  @api
  void updatePaintPropertyFromChildren({
    @autoInjectMark bool? resetGroupAngle,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    resetGroupAngle ??=
        canvasDelegate?.canvasStyle.enableResetElementAngle ?? true;
    if (isNullOrEmpty(children)) {
      //paintProperty = null;
      updatePaintProperty(null, fromObj: fromObj, fromUndoType: fromUndoType);
    } else if (children!.length == 1 && !resetGroupAngle) {
      updatePaintProperty(
        children!.first.paintProperty?.copyWith(),
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    } else {
      PaintProperty parentProperty = PaintProperty();
      Rect? rect;
      for (final child in children!) {
        //final childBounds = child.paintProperty?.paintPath.getExactBounds();
        final childBounds =
            child.paintProperty?.getBounds(true) ??
            child.elementsBounds; //resetGroupAngle
        if (childBounds != null) {
          if (rect == null) {
            rect = childBounds;
          } else {
            rect = rect.expandToInclude(childBounds);
          }
        }
      }
      parentProperty.initWith(rect: rect);
      updatePaintProperty(
        parentProperty,
        fromObj: fromObj,
        fromUndoType: fromUndoType,
      );
    }
  }

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    if (paintChildren || paintMeta.paintChildren) {
      children?.forEach((element) {
        //debugger();
        element.painting(canvas, paintMeta);
      });
    }
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
  List<ElementPainter> getSingleElementList({
    bool includeGroupPainter = false,
  }) {
    final result = <ElementPainter>[];
    if (includeGroupPainter) {
      result.add(this);
    }
    children?.forEach((element) {
      result.addAll(
        element.getSingleElementList(includeGroupPainter: includeGroupPainter),
      );
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

  @override
  ElementPainter copyElement({
    ElementPainter? template,
    ElementGroupPainter? parent,
    bool resetUuid = true,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    final newPainter = ElementGroupPainter();
    newPainter.updatePaintState(
      paintState.copyWith(),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    newPainter.updatePaintProperty(
      paintProperty?.copyWith(),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );

    if (resetUuid) {
      newPainter.paintState.elementUuid = $uuid;
    }

    final newChildren = <ElementPainter>[];
    children?.forEach((element) {
      newChildren.add(
        element.copyElement(
          parent: newPainter,
          resetUuid: resetUuid,
          fromObj: fromObj ?? onlyElementGroupPainter,
          fromUndoType: fromUndoType,
        ),
      );
    });
    newPainter.resetChildren(newChildren);
    return newPainter;
  }

  /// 当有子元素[child]的属性发生变化时, 通知父元素
  /// [ElementPainter.dispatchSelfPaintPropertyChanged]
  void onChildPaintPropertyChanged(
    ElementPainter child,
    dynamic old,
    dynamic value,
    PainterPropertyType propertyType,
    Object? fromObj,
    UndoType? fromUndoType, {
    String? debugLabel,
  }) {
    debugger(when: debugLabel != null);
    /*assert(() {
      l.w("[${classHash()}]...updatePaintPropertyFromChildren");
      return true;
    }());*/
    if (fromObj is BaseControl ||
        fromObj is ElementStateStack ||
        this == fromObj) {
      //no op
    } else {
      //debugger();
      if (propertyType == PainterPropertyType.paint) {
        //组内元素属性改变, 但是不同通过父元素改变的
        //有可能是独立选择了组内某个元素单独修改的属性, 而未修改父元素的属性
        updatePaintPropertyFromChildren();
      } else if (propertyType == PainterPropertyType.state) {
        //debugger();
        if (isVisible /*自身可见, 但是child有不可见的元素*/ ) {
          final visibleList = children?.filterVisibleList;
          if (visibleList?.length != children?.length) {
            children = visibleList;
            updatePaintPropertyFromChildren();
          }
        }
      }
    }
  }

  /// 从组内删除元素
  /// @return 是否删除成功
  bool removeElement(ElementPainter? element) {
    final result = children?.remove(element) ?? false;
    if (result) {
      updatePaintPropertyFromChildren(fromObj: this);
    }
    return result;
  }

  /// 从组内删除一组元素
  /// @return 删除掉的元素列表
  List<ElementPainter>? removeElementList(List<ElementPainter>? elementList) {
    final result = children?.removeAll(elementList);
    if (result?.isNotEmpty == true) {
      updatePaintPropertyFromChildren(fromObj: this);
    }
    return result;
  }

  //endregion ---core--

  //region ---apply--

  @override
  void translateElement(
    Matrix4 matrix, {
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    super.translateElement(
      matrix,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    children?.forEach((element) {
      element.translateElement(
        matrix,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
      );
    });
  }

  @override
  void rotateElement(
    Matrix4 matrix, {
    double? refTargetRadians,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    super.rotateElement(
      matrix,
      refTargetRadians: refTargetRadians,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    children?.forEach((element) {
      element.rotateElement(
        matrix,
        refTargetRadians: refTargetRadians,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
      );
    });
  }

  /// 不推荐在[ElementSelectComponent]对象上使用此方法
  /// 推荐使用[rotateElement]
  @override
  void rotateElementTo(
    double radians, {
    Offset? anchor,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    final childRadians = radians - (paintProperty?.angle ?? 0);
    super.rotateElementTo(
      radians,
      anchor: anchor,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    children?.forEach((element) {
      final matrix = Matrix4.identity()..rotateBy(childRadians, anchor: anchor);
      element.rotateElement(
        matrix,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
      );
    });
  }

  @override
  void flipElement({
    bool? flipX,
    bool? flipY,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    super.flipElement(
      flipX: flipX,
      flipY: flipY,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
    children?.forEach((element) {
      element.flipElement(
        flipX: flipX,
        flipY: flipY,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
      );
    });
    //这种方式翻转元素, 有可能会跑到边界外, 所以需要重新计算边界
    updatePaintPropertyFromChildren(
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  /// 缩放选中的元素, 在[ElementGroupPainter]中需要分开处理自身和[children]
  /// [anchor] 缩放的锚点, 不指定则使用[PaintProperty]的锚点
  /// [ScaleControl]
  @override
  void scaleElement({
    double? sx,
    double? sy,
    Offset? anchor,
    Alignment? anchorAlignment,
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    double angle = paintProperty?.angle ?? 0; //弧度
    anchor ??=
        (anchorAlignment != null
            ? paintProperty?.getAnchor(anchorAlignment)
            : paintProperty?.anchor) ??
        Offset.zero;

    //自身使用直接缩放
    updatePaintProperty(
      paintProperty?.copyWith()?..applyScale(sxBy: sx, syBy: sy),
      fromObj: fromObj,
      fromUndoType: fromUndoType,
      debugLabel: debugLabel,
    );

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
      element.scaleElementWithCenter(
        matrix: matrix,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
    });
  }

  @override
  void scaleElementWithCenter({
    double? sx,
    double? sy,
    Matrix4? matrix,
    Object? fromObj,
    UndoType? fromUndoType,
    String? debugLabel,
  }) {
    super.scaleElementWithCenter(
      sx: sx,
      sy: sy,
      matrix: matrix,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
      debugLabel: debugLabel,
    );
    children?.forEach((element) {
      element.scaleElementWithCenter(
        sx: sx,
        sy: sy,
        matrix: matrix,
        fromObj: fromObj ?? onlyElementGroupPainter,
        fromUndoType: fromUndoType,
        debugLabel: debugLabel,
      );
    });
  }

  /// 群组旋转元素
  /// 最终调用[rotateElement]
  @override
  void rotateBy(
    double angle, {
    Offset? anchor,
    double? refTargetRadians,
    Object? fromObj,
    UndoType? fromUndoType,
  }) {
    super.rotateBy(
      angle,
      anchor: anchor,
      refTargetRadians: refTargetRadians,
      fromObj: fromObj,
      fromUndoType: fromUndoType,
    );
  }

  //endregion ---apply--

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty('children', children));
  }
}

/// 元素绘制时的一些状态存储信息
/// [PainterPropertyType.state]
class PaintState with EquatableMixin {
  /// 元素的唯一标识
  String? elementUuid = $uuid;

  /// 元素的名称
  String? elementName;

  /// 是否锁定了宽高比
  bool isLockRatio = true;

  /// 元素是否可见, 不可见的元素也不会绘制
  bool isVisible = true;

  /// 元素是否锁定了操作, 锁定后, 不可选中操作
  bool isLockOperate = false;

  //--

  /// 如果是群组, 是否折叠了
  bool isFold = true;

  //--

  /// 元素是否被鼠标悬停
  bool get isHover => hoverPoint != null;

  /// 元素悬停时, 鼠标的坐标
  /// - [onHoverChanged]
  @viewCoordinate
  Offset? hoverPoint;

  /// 元素是否被按下
  bool get isPointerDown => pointerDownPoint != null;

  /// 元素按下时时, 鼠标的坐标
  @viewCoordinate
  Offset? pointerDownPoint;

  /// 元素临时绘制的颜色
  /// [ElementPainter.painting]
  Color? color;

  @override
  String toString() {
    return 'PaintState{elementUuid: $elementUuid, elementName: $elementName, '
        'isLockRatio: $isLockRatio, isVisible: $isVisible, isLockOperate: $isLockOperate, '
        'isFold: $isFold, isHover: $isHover, isPointerDown: $isPointerDown, color: $color}';
  }

  @override
  List<Object?> get props => [
    elementUuid,
    elementName,
    isLockRatio,
    isVisible,
    isLockOperate,
    isFold,
  ];

  /// copyWith
  PaintState copyWith({
    String? elementUuid,
    String? elementName,
    bool? isLockRatio,
    bool? isVisible,
    bool? isLockOperate,
    bool? isFold,
    Offset? hoverPoint,
    Offset? pointerDownPoint,
    Color? color,
  }) {
    return PaintState()
      ..elementUuid = elementUuid ?? this.elementUuid
      ..elementName = elementName ?? this.elementName
      ..isLockRatio = isLockRatio ?? this.isLockRatio
      ..isVisible = isVisible ?? this.isVisible
      ..isLockOperate = isLockOperate ?? this.isLockOperate
      ..isFold = isFold ?? this.isFold
      ..hoverPoint = hoverPoint ?? this.hoverPoint
      ..pointerDownPoint = pointerDownPoint ?? this.pointerDownPoint
      ..color = color ?? this.color;
  }
}

/// 绘制属性, 包含坐标/缩放/旋转/倾斜等信息
/// 先倾斜, 再缩放, 最后旋转
/// [PainterPropertyType.paint]
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
  @dp
  Rect get rect => Rect.fromLTWH(0, 0, width, height);

  /// 倾斜矩阵, 锚点无关的矩阵
  Matrix4 get skewMatrix => Matrix4.skew(skewX, skewY);

  /// 缩放矩阵, 锚点默认在0,0位置
  Matrix4 get scaleMatrix => Matrix4.identity()..scale(scaleX, scaleY, 1);

  /// 镜像矩阵, 锚点需要在中心位置
  Matrix4 get flipMatrix =>
      createFlipMatrix(flipX: flipX, flipY: flipY, anchor: rect.center);

  /// 旋转矩阵, 锚点需要在中心位置
  Matrix4 get rotateMatrix => createRotateMatrix(angle, anchor: rect.center);

  /// 平移矩阵, 平移到指定的目标位置
  Matrix4 get translateMatrix {
    Offset center = Offset(left + width / 2, top + height / 2);
    final rotateMatrix = createRotateMatrix(angle, anchor: anchor);
    //计算出元素最终的中心点
    center = rotateMatrix.mapPoint(center);
    return Matrix4.identity()
      ..translate(center.dx - width / 2, center.dy - height / 2, 0);
  }

  /// 所有属性的矩阵, 矩阵的乘法, 前乘, 后乘.
  /// final m' = m1 * m2; //前面的矩阵会影响后面矩阵的值.
  ///  - m1 中的缩放值, 会影响 m2 中的平移值
  ///  - m2 中的缩放值, 不会影响 m1 中的平移值
  /// `*` 操作等同于 [Matrix4.multiplied]
  ///
  /// ```
  /// final t = Matrix4.identity()..translate(100.0, 100.0);
  /// final s = Matrix4.identity()..scale(3.0, 2.0);
  /// final r1 = t * s;
  /// final r2 = s * t;
  /// final r3 = t.multiplied(s); //r3 == r1
  /// ```
  Matrix4 get operateMatrix {
    final matrix =
        translateMatrix * rotateMatrix * scaleMatrix * flipMatrix * skewMatrix;
    /*final matrix2 = createMatrix4(
      scaleX: scaleX,
      scaleY: scaleY,
      skewX: skewX,
      skewY: skewY,
      translateX: left,
      translateY: top,
    );
    debugger(when: matrix != matrix2);*/
    return matrix;
  }

  //---

  /// 元素最终的中心点
  Offset get paintCenter => paintBounds.center;

  /// 根据对齐方式, 获取锚点位置
  Offset getAnchor(Alignment alignment) {
    final offset = alignment.withinRect(rect);
    return operateMatrix.mapPoint(offset);
  }

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
    final matrix = createRotateMatrix(angle, anchor: anchor);
    return matrix.mapRect(rect);
  }

  /// 全属性后的边界, 是旋转后的[rect]的外边界
  /// 更贴切的边界是[paintPath]的边界[PathEx.getExactBounds]
  ///
  /// - [getBounds]
  /// - [paintBounds]
  /// - [paintPath]
  @dp
  @sceneCoordinate
  Rect get paintBounds => operateMatrix.mapRect(rect);

  /// 元素全属性绘制路径, 用来判断是否相交
  /// 完全包裹的path路径
  @dp
  Path get paintPath => Path().let((it) {
    //debugger();
    it.addRect(rect);
    return it.transformPath(operateMatrix);
  });

  //endregion ---get属性---

  //region ---操作方法---

  /// 获取元素的边界
  /// [resetElementAngle] 是否要获取重置角度后的元素边界
  /// [ElementPainter.elementsBounds]
  ///
  /// - [paintBounds]
  /// - [paintScaleRotateBounds]
  @dp
  @sceneCoordinate
  Rect getBounds(bool resetElementAngle) {
    return resetElementAngle ? paintBounds : paintScaleRotateBounds;
  }

  /// 将[matrix]矩阵对应的中心点, 平移到元素的中心点
  /// [matrix] 全量属性
  Matrix4 translateToSelfCenter(Matrix4 matrix) {
    Offset target = paintCenter;
    Offset center = rect.center;
    center = matrix.mapPoint(center);
    matrix.postTranslateBy(x: target.dx - center.dx, y: target.dy - center.dy);
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

  /// 平移到指定位置, 将当前的锚点位置平移到新的位置
  /// [anchorAlignment] 需要对齐的锚点
  /// 如果要将中心点平移到指定位置, 可以使用[Alignment.center]
  /// [applyTranslate]
  @api
  void translateTo(Offset anchor, {Alignment? anchorAlignment}) {
    final oldAnchor = anchorAlignment?.withinRect(paintBounds) ?? this.anchor;
    final offset = anchor - oldAnchor;
    applyTranslate(createTranslateMatrix(offset: offset));
  }

  /// 平移操作
  @api
  void applyTranslate(Matrix4 matrix) {
    final anchor = this.anchor;
    final targetAnchor = matrix.mapPoint(anchor);
    left = targetAnchor.dx;
    top = targetAnchor.dy;
  }

  /// 旋转到指定角度
  /// [angle] 角度
  /// [radians] 弧度
  /// [anchor] 旋转锚点, 不指定时, 默认使用[paintBounds]中心
  /// [anchorAlignment] 锚点在[paintBounds]中的对齐位置
  /// [applyRotate]
  @api
  void rotateTo({
    double? angle,
    double? radians,
    Offset? anchor,
    Alignment? anchorAlignment,
  }) {
    radians ??= angle?.hd;
    if (radians == null) {
      return;
    }
    //debugger();
    anchor ??= anchorAlignment?.withinRect(paintBounds) ?? paintBounds.center;
    applyRotate(createRotateMatrix(radians - this.angle, anchor: anchor));
  }

  /// 旋转操作
  /// [refTargetRadians] 参考的需要旋转到的目标角度, 用来决定存储值时的正负数 单位: 弧度
  @api
  void applyRotate(Matrix4 matrix, {double? refTargetRadians}) {
    //debugger();
    // 锚点也需要翻转
    applyTranslate(matrix);
    angle = angle + matrix.rotation;
    angle = angle.sanitizeRadians;
    if (refTargetRadians != null) {
      if (refTargetRadians < 0 && angle > 0) {
        angle -= 2 * pi;
      } else if (refTargetRadians > 0 && angle < 0) {
        angle += 2 * pi;
      }
    }
    //debugger();
    /*if (angle < -pi) {
      angle = angle + pi;
    } else if (angle > pi) {
      angle = angle - pi;
    }*/
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

  /// updateFrom
  void updateFrom(PaintProperty? other) {
    if (other == null) {
      return;
    }
    left = other.left;
    top = other.top;
    width = other.width;
    height = other.height;
    scaleX = other.scaleX;
    scaleY = other.scaleY;
    skewX = other.skewX;
    skewY = other.skewY;
    angle = other.angle;
    flipX = other.flipX;
    flipY = other.flipY;
  }

  /// copyWith
  PaintProperty copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
    double? scaleX,
    double? scaleY,
    double? skewX,
    double? skewY,
    double? angle,
    bool? flipX,
    bool? flipY,
  }) {
    return PaintProperty()
      ..left = left ?? this.left
      ..top = top ?? this.top
      ..width = width ?? this.width
      ..height = height ?? this.height
      ..scaleX = scaleX ?? this.scaleX
      ..scaleY = scaleY ?? this.scaleY
      ..skewX = skewX ?? this.skewX
      ..skewY = skewY ?? this.skewY
      ..angle = angle ?? this.angle
      ..flipX = flipX ?? this.flipX
      ..flipY = flipY ?? this.flipY;
  }

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

typedef ElementStateStackAction = void Function(ElementStateStack stack);

/// 元素状态栈, 用来撤销和重做
class ElementStateStack {
  /// 是否保存了状态, 目前只有标识作用, 没有逻辑作用
  @flagProperty
  bool isSaveState = false;

  /// 操作的元素, 回退栈操作的顶层元素
  ElementPainter? fromElement;

  /// 元素的属性保存
  final Map<ElementPainter, PaintProperty?> elementPropertyMap = {};

  /// 元素的扩展信息保存
  final Map<ElementPainter, Map<String, dynamic>> elementDataMap = {};

  /// 元素的状态保存, 暂时不存储
  @implementation
  final Map<ElementPainter, PaintState?> elementStateMap = {};

  /// 保存元素对应的children
  final Map<ElementGroupPainter, List<ElementPainter>?> elementChildrenMap = {};

  //--

  /// 当状态栈保存时, 额外执行的方法
  @configProperty
  final List<ElementStateStackAction> saveCallList = [];

  /// 当状态栈恢复时, 额外执行的方法
  @configProperty
  final List<ElementStateStackAction> restoreCallList = [];

  @api
  void onSaveCall(ElementStateStackAction action) {
    saveCallList.add(action);
  }

  @api
  void onRestoreCall(ElementStateStackAction action) {
    restoreCallList.add(action);
  }

  //--

  /// 保存信息, 多用于回退栈
  /// [element] 当前的元素,
  /// [otherStateElementList] 额外要保存的元素数据集合, 会自动排除[otherStateExcludeElementList]中的元素
  /// [saveGroupChild] 是否要保存[ElementGroupPainter.children]
  ///
  /// [dispose]
  @callPoint
  @mustCallSuper
  void saveFrom(
    ElementPainter? element, {
    List<ElementPainter>? otherStateElementList,
    List<ElementPainter>? otherStateExcludeElementList,
    bool? saveGroupChild,
  }) {
    //debugger();
    isSaveState = true;
    fromElement = element;

    if (element != null) {
      saveElement(element, saveGroupChild: saveGroupChild);
    }

    if (otherStateElementList != null) {
      //debugger();
      for (final e in otherStateElementList) {
        saveElement(
          e,
          excludeElements: otherStateExcludeElementList,
          saveGroupChild: saveGroupChild,
        );
      }
    }

    //--
    for (final call in saveCallList) {
      call(this);
    }
    /*assert(() {
      l.i("[${classHash()}][${element.runtimeType}]save elementPropertyMap:${elementPropertyMap.length}");
      return true;
    }());*/
  }

  /// [excludeElements] 需要排除的元素列表
  @overridePoint
  void saveElement(
    ElementPainter element, {
    List<ElementPainter>? excludeElements,
    bool? saveGroupChild,
  }) {
    //base
    elementPropertyMap[element] = element.paintProperty?.copyWith();
    //stateMap[element] = element.paintState.copyWith();

    //data
    final dataMap = <String, dynamic>{};
    element.onSaveStateStackData(this, dataMap);
    elementDataMap[element] = dataMap;

    //group child
    if (element is ElementGroupPainter) {
      if (saveGroupChild == true) {
        elementChildrenMap[element] = element.children?.clone();
      }
      element.children?.forEach((sub) {
        if (excludeElements?.contains(sub) != true) {
          saveElement(
            sub,
            excludeElements: excludeElements,
            saveGroupChild: saveGroupChild,
          );
        }
      });
    }
  }

  /// 恢复信息
  /// [mute] 是否静默恢复, 静默恢复只会恢复一些基础属性, 并且不会触发任何回调
  @callPoint
  @mustCallSuper
  void restore({bool? mute}) {
    /*stateMap.forEach((element, paintState) {
      element.paintState = paintState ?? element.paintState;
    });*/
    //debugger();
    /*assert(() {
      l.i("[${classHash()}][${fromElement?.runtimeType}]restore elementPropertyMap:${elementPropertyMap.length}");
      return true;
    }());*/

    //恢复children
    elementChildrenMap.forEach((group, children) {
      group.children?.reset(children);
    });

    //恢复paintProperty
    elementPropertyMap.forEach((element, paintProperty) {
      //debugger();
      //base
      //element.paintProperty = paintProperty;
      element.updatePaintProperty(
        paintProperty,
        fromObj: this,
        notify: mute != true,
      );
      //final paintState = elementStateMap[element];
      //element.paintState = paintState;

      //data
      final dataMap = elementDataMap[element];
      element.onRestoreStateStackData(this, dataMap);

      //end
      if (mute != true) {
        element.onRestoreStateStack(this);
      }
    });

    //--
    if (mute != true) {
      for (final call in restoreCallList) {
        call(this);
      }
    }
  }

  /// 释放资源
  @api
  @callPoint
  void dispose() {
    //debugger();
    assert(() {
      l.w("[${classHash()}][${fromElement?.classHash()}]clear.");
      return true;
    }());
    elementPropertyMap.clear();
    elementDataMap.clear();
    elementStateMap.clear();
    elementChildrenMap.clear();
    fromElement = null;
  }
}

/// 属性类型, 支持组合
/// [PaintProperty]
/// [PaintState]
enum PainterPropertyType {
  /// 绘制的相关属性, 比如坐标/缩放/旋转/倾斜等信息
  /// 支持回退的属性
  /// 对应[PaintProperty]
  /// [ElementPainter.paintProperty]
  @supportUndo
  paint,

  /// 元素的状态改变, 比如锁定/可见性/uuid/名称等信息
  /// 对应[PaintState]
  /// [ElementPainter.paintState]
  state,

  /// 元素的数据改变, 比如内容等信息
  @supportUndo
  data,

  /// 元素的数据模式改变, 图片变成了文本等
  /// 颜色改变等
  mode,
}

/// 元素真实数据内容改变
/// 改变后, 通常意味着是一个新的数据
enum ElementDataType {
  /// 大小尺寸改变了
  size,

  /// 数据本身内容改变了
  data,
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
