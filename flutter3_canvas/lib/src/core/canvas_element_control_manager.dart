part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///

/// 绘制元素的类型
enum PaintInfoType {
  /// 啥也不绘制
  none,

  /// 默认绘制元素的宽高信息
  /// 选中元素时, 绘制元素的宽高信息
  size,

  /// 绘制元素的位置信息
  /// 拖拽元素时, 绘制元素的位置信息
  location,

  /// 绘制元素的旋转信息
  /// 旋转元素时, 绘制元素的旋转信息
  rotate,
}

/// 元素控制操作管理
class CanvasElementControlManager with Diagnosticable, PointerDispatchMixin {
  final CanvasElementManager canvasElementManager;

  /// 是否激活元素的控制操作, 关闭之后, 将无法通过手势交互控制元素
  bool enableElementControl = true;

  /// 是否激活元素[PaintProperty]属性改变后, 重置旋转角度
  bool enableResetElementAngle = true;

  /// 是否激活点击元素外, 取消选中元素
  bool enableOutsideCancelSelectElement = true;

  /// 绘制元素的信息
  PaintInfoType paintInfoType = PaintInfoType.none;

  /// 控制限制器
  late ControlLimit controlLimit = ControlLimit(this);

  /// 选择元素操作的组件
  late ElementSelectComponent elementSelectComponent =
      ElementSelectComponent(this);

  /// 删除控制
  late DeleteControl deleteControl = DeleteControl(this);

  /// 旋转控制
  late RotateControl rotateControl = RotateControl(this);

  /// 缩放控制
  late ScaleControl scaleControl = ScaleControl(this);

  /// 锁定控制
  late LockControl lockControl = LockControl(this);

  /// 平移控制
  late TranslateControl translateControl = TranslateControl(this);

  CanvasDelegate get canvasDelegate => canvasElementManager.canvasDelegate;

  /// 是否选中了元素
  bool get isSelectedElement => elementSelectComponent.isSelectedElement;

  /// 选中元素的数量
  int get selectedElementCount => elementSelectComponent.children?.length ?? 0;

  /// 是否选中了一组元素
  bool get isSelectedGroupElement =>
      elementSelectComponent.children?.let((it) =>
          it.length > 1 ||
          (it.length == 1 && it.first is ElementGroupPainter)) ==
      true;

  /// 是否只选中了[ElementGroupPainter]元素
  bool get isSelectedGroupPainter =>
      elementSelectComponent.children
          ?.let((it) => it.length == 1 && it.first is ElementGroupPainter) ==
      true;

  /// 是否在元素上按下
  /// 按下时, 不绘制控制点
  /// [paint]
  bool get isPointerDownElement =>
      _currentControlRef?.target?.controlType ==
          BaseControl.sControlTypeTranslate &&
      isControlElement;

  /// 是否正在控制元素中
  bool get isControlElement => _currentControlState == ControlState.start;

  /// 获取选中元素的边界
  Rect? get selectBounds => isSelectedElement
      ? elementSelectComponent.paintProperty?.getBounds(enableResetElementAngle)
      : null;

  CanvasElementControlManager(this.canvasElementManager) {
    addHandleEventClient(elementSelectComponent);
    addHandleEventClient(deleteControl);
    addHandleEventClient(rotateControl);
    addHandleEventClient(scaleControl);
    addHandleEventClient(lockControl);
    addHandleEventClient(translateControl);
  }

  @entryPoint
  void paint(Canvas canvas, PaintMeta paintMeta) {
    //---选择框绘制
    elementSelectComponent.painting(canvas, paintMeta);
    //---控制点绘制
    if (isSelectedElement) {
      //绘制元素的控制信息
      if (paintInfoType == PaintInfoType.size) {
        _paintControlSizeInfo(
            canvas, paintMeta, elementSelectComponent.paintProperty);
      } else if (paintInfoType == PaintInfoType.rotate) {
        _paintControlRotateInfo(
            canvas, paintMeta, elementSelectComponent.paintProperty);
      } else if (paintInfoType == PaintInfoType.location) {
        _paintControlLocationInfo(
            canvas, paintMeta, elementSelectComponent.paintProperty);
      }
      //绘制控制点
      if (enableElementControl && !isPointerDownElement) {
        if (elementSelectComponent
            .isElementSupportControl(deleteControl.controlType)) {
          deleteControl.paintControl(canvas, paintMeta);
        }
        if (elementSelectComponent
            .isElementSupportControl(rotateControl.controlType)) {
          rotateControl.paintControl(canvas, paintMeta);
        }
        if (elementSelectComponent
            .isElementSupportControl(scaleControl.controlType)) {
          scaleControl.paintControl(canvas, paintMeta);
        }
        if (elementSelectComponent
            .isElementSupportControl(lockControl.controlType)) {
          lockControl.paintControl(canvas, paintMeta);
        }
      }
    }
  }

  /// 事件处理入口
  /// [CanvasEventManager.handleEvent]
  /// [CanvasElementManager.handleElementEvent]
  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    //debugger();
    if (enableElementControl) {
      if (event.isPointerDown) {
        ignoreHandlePointer(
            event,
            !canvasDelegate.canvasViewBox.canvasBounds
                .contains(event.localPosition));
      }
      //在画布内点击才响应
      handleDispatchEvent(event);
    }
  }

  /// 当有元素被删除时, 调用
  /// 同时需要检查被删除的元素是否是选中的元素, 如果是, 则需要更新选择框
  @flagProperty
  void onCanvasElementDeleted(List<ElementPainter> elements) {
    final list = elementSelectComponent.children?.clone(true);
    if (list != null) {
      final op = list.removeAll(elements);
      if (op.isNotEmpty) {
        //有选中的元素被删除了
        elementSelectComponent.resetSelectElement(list);
      }
    }
  }

  /// 绘制选中元素的控制信息
  /// [_paintControlSizeInfo]
  /// [_paintControlRotateInfo]
  /// [_paintControlLocationInfo]
  void _paintControlInfo(
    Canvas canvas,
    PaintMeta paintMeta,
    PaintProperty paintProperty,
    String text,
  ) {
    final canvasViewBox = canvasDelegate.canvasViewBox;
    @sceneCoordinate
    final paintScaleRect = paintProperty.paintScaleRect;
    @sceneCoordinate
    final paintRectBounds = paintProperty.paintScaleRotateBounds;
    //debugger();
    final angle = paintProperty.angle.sanitizeRadians;
    @sceneCoordinate
    final angleAnchor = paintProperty.paintCenter;

    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
              color: canvasDelegate.canvasStyle.paintInfoTextColor,
              fontSize: canvasDelegate.canvasStyle.paintInfoTextFontSize,
            )),
        textDirection: TextDirection.ltr)
      ..layout();

    @viewCoordinate
    final elementBounds = canvasViewBox.toViewRect(paintScaleRect);
    @viewCoordinate
    final angleCenter = canvasViewBox.toViewPoint(angleAnchor);

    final paintInfoTextPadding =
        canvasDelegate.canvasStyle.paintInfoTextPadding;
    final boundsWidth = textPainter.width + paintInfoTextPadding.horizontal;
    final boundsHeight = textPainter.height + paintInfoTextPadding.vertical;

    final textBounds = Rect.fromLTWH(
        elementBounds.center.dx - boundsWidth / 2,
        elementBounds.top -
            canvasDelegate.canvasStyle.paintInfoOffset -
            boundsHeight,
        boundsWidth,
        boundsHeight);

    canvas.withRotateRadians(angle, () {
      canvas.drawRRect(
        textBounds.toRRect(canvasDelegate.canvasStyle.paintInfoBgRadiusSize),
        Paint()
          ..color = canvasDelegate.canvasStyle.paintInfoBgColor
          ..style = PaintingStyle.fill,
      );

      final flip = angle > pi / 2 && angle < 3 * pi / 2;
      canvas.withScale(flip ? -1 : 1, flip ? -1 : 1, () {
        textPainter.paint(canvas, textBounds.lt + paintInfoTextPadding.topLeft);
      }, anchor: textBounds.center);
    }, anchor: angleCenter);
  }

  /// 绘制选中元素的大小信息
  void _paintControlSizeInfo(
      Canvas canvas, PaintMeta paintMeta, PaintProperty? paintProperty) {
    paintProperty?.let((it) {
      @sceneCoordinate
      final paintRectBounds = it.getBounds(enableResetElementAngle);
      final Size size = paintRectBounds.size;

      final axisUnit = canvasDelegate.canvasPaintManager.axisManager.axisUnit;
      final withString = axisUnit.format(
        axisUnit.toUnit(size.width.toPixelFromDp()),
        removeZero: false,
        ensureInt: false,
      );
      final heightString = axisUnit.format(
        axisUnit.toUnit(size.height.toPixelFromDp()),
        removeZero: false,
        ensureInt: false,
      );
      final text = 'w:$withString\nh:$heightString';
      _paintControlInfo(canvas, paintMeta, paintProperty, text);
    });
  }

  /// 绘制选中元素的旋转信息
  void _paintControlRotateInfo(
      Canvas canvas, PaintMeta paintMeta, PaintProperty? paintProperty) {
    paintProperty?.let((it) {
      final text = '${it.angle.jd.sanitizeDegrees.toDigits()}°';
      _paintControlInfo(canvas, paintMeta, paintProperty, text);
    });
  }

  /// 绘制选中元素的位置信息
  void _paintControlLocationInfo(
      Canvas canvas, PaintMeta paintMeta, PaintProperty? paintProperty) {
    paintProperty?.let((it) {
      @sceneCoordinate
      final paintRectBounds = it.getBounds(enableResetElementAngle);
      final Offset location = paintRectBounds.lt;

      final axisUnit = canvasDelegate.canvasPaintManager.axisManager.axisUnit;
      final xString = axisUnit.format(
        axisUnit.toUnit(location.dx.toPixelFromDp()),
        removeZero: false,
        ensureInt: false,
      );
      final yString = axisUnit.format(
        axisUnit.toUnit(location.dy.toPixelFromDp()),
        removeZero: false,
        ensureInt: false,
      );
      final text = 'x:$xString\ny:$yString';
      _paintControlInfo(canvas, paintMeta, paintProperty, text);
    });
  }

  //---

  /// 当有元素绘制属性发生变化时调用
  /// 此时可能需要检查是否需要清空旋转的角度
  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  ///
  /// [propertyType] 改变的属性类型
  @property
  @implementation
  void onSelfElementPropertyChanged(
    ElementPainter element,
    int propertyType,
  ) {
    if (enableResetElementAngle) {
      if (isControlElement) {}
    }
  }

  /// 当元素列表发生变化时, 调用
  /// 此时需要检查选中的元素与操作的元素是否有变化
  /// [CanvasDelegate.dispatchCanvasElementListChanged]
  @property
  void onSelfElementListChanged(
    List<ElementPainter> from,
    List<ElementPainter> to,
    List<ElementPainter> op,
    UndoType undoType,
  ) {
    if (isSelectedElement) {
      final list = elementSelectComponent.children;
      if (list != null) {
        //debugger();
        if (to.length > from.length) {
          //有元素被添加了
          if (undoType == UndoType.redo) {
            elementSelectComponent.resetSelectElement(null);
          }
        } else {
          //选中了的元素, 但是被删除了
          final removeList = <ElementPainter>[];
          for (var element in list) {
            if (!to.contains(element)) {
              removeList.add(element);
            }
          }

          if (removeList.isNotEmpty) {
            //有选中的元素被删除了
            elementSelectComponent
                .resetSelectElement(list.clone(true).removeAll(removeList));
          }
        }
      }
    }
  }

  /// 当选中的元素发生变化时, 调用
  /// 此时需要更新控制点的位置
  /// 需要更新lock状态
  /// [ElementSelectComponent.resetSelectElement]
  @property
  void onSelfSelectElementChanged() {
    updateControlBounds();
    lockControl.isLock = elementSelectComponent.isLockRatio;
    canvasDelegate.refresh();
  }

  /// 更新控制点的位置
  @property
  void updateControlBounds() {
    if (enableElementControl && isSelectedElement) {
      elementSelectComponent.paintProperty?.let((it) {
        deleteControl.updatePaintControlBounds(it);
        rotateControl.updatePaintControlBounds(it);
        scaleControl.updatePaintControlBounds(it);
        lockControl.updatePaintControlBounds(it);
      });
    } else {
      deleteControl.controlBounds = null;
      rotateControl.controlBounds = null;
      scaleControl.controlBounds = null;
      lockControl.controlBounds = null;
    }
  }

  /// 移除选中的所有元素, 并且清空选择
  @api
  void removeSelectedElement() {
    if (isSelectedElement) {
      final list = elementSelectComponent.children;
      //elementSelectComponent.resetChildren(null, enableResetElementAngle);
      elementSelectComponent.resetSelectElement(null);
      canvasDelegate.canvasElementManager.removeElementList(list);
    }
  }

  WeakReference<BaseControl>? _currentControlRef;
  WeakReference<ElementPainter>? _currentControlElementRef;
  ControlState? _currentControlState;

  /// 控制状态发生改变
  /// [control] 控制器
  /// [controlElement] 控制的元素
  /// [BaseControl.startControlTarget]
  /// [BaseControl.endControlTarget]
  @property
  void onSelfControlStateChanged({
    BaseControl? control,
    ElementPainter? controlElement,
    required ControlState state,
  }) {
    _currentControlRef = control?.toWeakRef();
    _currentControlElementRef = controlElement?.toWeakRef();
    _currentControlState = state;

    final controlType = control?.controlType;
    if (state == ControlState.start) {
      if (controlType == BaseControl.sControlTypeRotate) {
        updatePaintInfoType(PaintInfoType.rotate);
      } else if (controlType == BaseControl.sControlTypeTranslate) {
        //按下时, 就显示元素的位置信息
        updatePaintInfoType(PaintInfoType.location);
      }
    } else {
      if (controlType == BaseControl.sControlTypeRotate) {
        //旋转结束之后
        if (enableResetElementAngle) {
          elementSelectComponent.updateChildPaintPropertyFromChildren(true);
          elementSelectComponent.updatePaintPropertyFromChildren(true);
        }
      }
      resetPaintInfoType();
    }
    canvasDelegate.refresh();
  }

  /// 更新绘制元素的信息
  @flagProperty
  void updatePaintInfoType(PaintInfoType type) {
    paintInfoType = type;
    canvasDelegate.refresh();
  }

  /// 根据选中元素的状态, 重置绘制信息类型
  @flagProperty
  void resetPaintInfoType() {
    updatePaintInfoType(PaintInfoType.size);
  }

  //region ---api---

  /// 更新指定元素的锁定宽高比状态
  void updateElementLockState([ElementPainter? elementPainter]) {
    elementPainter ??= elementSelectComponent;

    final isLock = !elementPainter.isLockRatio;
    elementSelectComponent.isLockRatio = isLock;
    if (elementPainter is ElementSelectComponent) {
      lockControl.isLock = isLock;
      canvasDelegate.refresh();
    }
  }

  /// 按比例缩放元素
  @api
  @supportUndo
  void scaleElement(
    ElementPainter? elementPainter, {
    double? sx,
    double? sy,
    Offset? anchor,
    bool isLockRatio = false,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementPainter == null) {
      return;
    }
    sx ??= 1;
    sy ??= 1;
    final limit = controlLimit.limitScale(sx, sy, isLockRatio,
        elementPainter.paintProperty?.getBounds(enableResetElementAngle));
    sx = limit[0];
    sy = limit[1];
    if (undoType == UndoType.normal) {
      final undoStateStack = elementPainter.createStateStack();
      elementPainter.scaleElement(sx: sx, sy: sy, anchor: anchor);
      final redoStateStack = elementPainter.createStateStack();
      canvasDelegate.canvasUndoManager
          .addUntoState(undoStateStack, redoStateStack);
    } else {
      elementPainter.scaleElement(sx: sx, sy: sy, anchor: anchor);
    }
  }

  /// 按照指定的量平移元素
  @api
  @supportUndo
  void translateElement(
    ElementPainter? elementPainter, {
    double? dx,
    double? dy,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementPainter == null) {
      return;
    }
    dx ??= 0;
    dy ??= 0;
    final limit = controlLimit.limitTranslate(dx, dy,
        elementPainter.paintProperty?.getBounds(enableResetElementAngle));
    dx = limit[0];
    dy = limit[1];
    final matrix = Matrix4.identity()..translateBy(dx: dx, dy: dy);
    if (undoType == UndoType.normal) {
      final undoStateStack = elementPainter.createStateStack();
      elementPainter.translateElement(matrix);
      final redoStateStack = elementPainter.createStateStack();
      canvasDelegate.canvasUndoManager
          .addUntoState(undoStateStack, redoStateStack);
    } else {
      elementPainter.translateElement(matrix);
    }
  }

  /// 旋转元素
  /// [angle] 旋转的角度, 单位: 弧度
  @api
  @supportUndo
  void rotateElement(
    ElementPainter? elementPainter,
    double? angle, {
    Offset? anchor,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementPainter == null || angle == null) {
      return;
    }
    if (undoType == UndoType.normal) {
      final undoStateStack = elementPainter.createStateStack();
      elementPainter.rotateBy(angle, anchor: anchor);
      final redoStateStack = elementPainter.createStateStack();
      canvasDelegate.canvasUndoManager
          .addUntoState(undoStateStack, redoStateStack);
    } else {
      elementPainter.rotateBy(angle, anchor: anchor);
    }
    if (enableResetElementAngle) {
      elementSelectComponent.updateChildPaintPropertyFromChildren(true);
      elementSelectComponent.updatePaintPropertyFromChildren(true);
    }
  }

  /// 翻转元素
  /// 这种方式翻转元素, 有可能会跑到边界外, 所以需要重新计算边界
  /// [flipX] 水平翻转
  /// [flipY] 垂直翻转
  @api
  @supportUndo
  void flipElement(
    ElementPainter? elementPainter, {
    bool? flipX,
    bool? flipY,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementPainter == null) {
      return;
    }
    if (undoType == UndoType.normal) {
      final undoStateStack = elementPainter.createStateStack();
      elementPainter.flipElement(flipX: flipX, flipY: flipY);
      /*elementPainter.scaleElement(sx: flipX == true ? -1 : 1, sy: flipY == true ? -1 : 1, anchor:
      elementPainter.paintProperty?.paintCenter);*/
      final redoStateStack = elementPainter.createStateStack();
      canvasDelegate.canvasUndoManager
          .addUntoState(undoStateStack, redoStateStack);
    } else {
      elementPainter.flipElement(flipX: flipX, flipY: flipY);
    }
  }

  /// 翻转元素
  /// [flipX] 水平翻转
  /// [flipY] 垂直翻转
  @api
  @supportUndo
  void flipElementWithScale(
    ElementPainter? elementPainter, {
    bool? flipX,
    bool? flipY,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementPainter == null) {
      return;
    }
    final anchor = elementPainter.paintProperty?.paintCenter;
    if (undoType == UndoType.normal) {
      final undoStateStack = elementPainter.createStateStack();
      elementPainter.flipElementWithScale(
          flipX: flipX, flipY: flipY, anchor: anchor);
      final redoStateStack = elementPainter.createStateStack();
      canvasDelegate.canvasUndoManager
          .addUntoState(undoStateStack, redoStateStack);
    } else {
      elementPainter.flipElementWithScale(
          flipX: flipX, flipY: flipY, anchor: anchor);
    }
  }

//endregion ---api---
}

/// 选择元素组件, 滑动选择元素
class ElementSelectComponent extends ElementGroupPainter
    with
        CanvasComponentMixin,
        IHandleEventMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin {
  final CanvasElementControlManager canvasElementControlManager;

  /// 画笔
  final Paint boundsPaint = Paint();

  /// 选择框的边界, 场景坐标系
  @sceneCoordinate
  Rect? selectBounds;

  /// 是否选中了元素
  bool get isSelectedElement => !isNullOrEmpty(children);

  @override
  set paintProperty(PaintProperty? value) {
    /*if (super.paintProperty?.paintCenter != value?.paintCenter) {
      debugger();
    }
    assert(() {
      l.d('选择框中点:${value?.paintCenter}');
      return true;
    }());*/
    super.paintProperty = value;
  }

  ElementSelectComponent(this.canvasElementControlManager) {
    attachToCanvasDelegate(
        canvasElementControlManager.canvasElementManager.canvasDelegate);
  }

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    super.painting(canvas, paintMeta);

    //绘制选择框
    paintSelectBounds(canvas, paintMeta);
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    //绘制选中元素边界
    if (paintMeta.host is CanvasDelegate && isSelectedElement) {
      paint.color = canvasElementControlManager
          .canvasDelegate.canvasStyle.canvasAccentColor;
      paint.strokeWidth = 1 /*1.toDpFromPx()*/ / paintMeta.canvasScale;
      paintPropertyRect(canvas, paintMeta, paint);
      //paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
    }
  }

  /// 绘制手势正在选择时的框框
  @entryPoint
  void paintSelectBounds(Canvas canvas, PaintMeta paintMeta) {
    selectBounds?.let((bounds) {
      void paintBounds_() {
        boundsPaint
          ..color = canvasElementControlManager
              .canvasDelegate.canvasStyle.canvasAccentColor
          ..style = PaintingStyle.stroke;
        canvas.drawRect(selectBounds!, boundsPaint);
        boundsPaint
          ..color = canvasElementControlManager
              .canvasDelegate.canvasStyle.canvasAccentColor
              .withOpacity(0.1)
          ..style = PaintingStyle.fill;
        canvas.drawRect(selectBounds!, boundsPaint);
      }

      paintMeta.withPaintMatrix(canvas, () {
        boundsPaint.strokeWidth = 1 / paintMeta.canvasScale;
        paintBounds_();
      });
    });
  }

  @override
  bool interceptPointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {
    //debugger();
    return super.interceptPointerEvent(dispatch, event);
  }

  @sceneCoordinate
  Offset _downScenePoint = Offset.zero;

  /// 按下时, 选中的元素列表
  List<ElementPainter>? _downElementList;

  @override
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(dispatch, event)) {
        //debugger();
        final viewBox =
            canvasElementControlManager.canvasDelegate.canvasViewBox;
        if (event.isPointerDown) {
          _downScenePoint = viewBox.toScenePoint(event.localPosition);
          _downElementList = canvasElementControlManager.canvasElementManager
              .findElement(point: _downScenePoint);
          updateSelectBounds(
              Rect.fromLTRB(_downScenePoint.dx, _downScenePoint.dy,
                  _downScenePoint.dx, _downScenePoint.dy),
              false);
        } else if (event.isPointerMove) {
          final scenePoint = viewBox.toScenePoint(event.localPosition);
          updateSelectBounds(
              Rect.fromPoints(_downScenePoint, scenePoint), false);
          //l.d(' selectBounds:$selectBounds');
        } else if (event.isPointerUp) {
          //选择结束
          //debugger();
          if (event.isMoveExceed(firstDownEvent?.localPosition)) {
            //移动了手指, 可能是滑动选择元素
            final selectList = _getSelectBoundsElementList();
            if (isNullOrEmpty(selectList) && !_noCanvasEventHandle()) {
              //想要清除选择
              //有画布的相关操作, 则取消清除选择
              updateSelectBounds(null, false);
            } else {
              //虽然画布操作了, 但还是要选择元素
              updateSelectBounds(null, true);
            }
          } else {
            //未移动手指, 可能是点击选择元素
            if (_downElementList?.isEmpty == true) {
              //没有点击选中元素
              updateSelectBounds(null, false);
              if (canvasElementControlManager
                  .enableOutsideCancelSelectElement) {
                //点击元素外, 取消选择
                resetSelectElement(null);
              }
            } else {
              //点击选中元素
              updateSelectBounds(null, false);
              resetSelectElement(_downElementList?.lastOrNull?.ofList());
            }
          }
          _downElementList = null;
        } else if (event.isPointerCancel) {
          updateSelectBounds(null, false);
        }
        return true;
      } else if (event.isPointerDown) {
        //多个手指按下
        //debugger();
        if (!isFirstMoveExceed()) {
          //时, 第一个手指未移动, 则取消滑动选择元素
          ignoreEventHandle = true;
          updateSelectBounds(null, false);
        }
      }
    }
    return super.onPointerEvent(dispatch, event);
  }

  /// 没有进行画布的操作
  bool _noCanvasEventHandle() =>
      canvasElementControlManager.canvasDelegate.canvasEventManager.let((it) =>
          !it.canvasTranslateComponent.isFirstEventHandled &&
          !it.canvasScaleComponent.isFirstEventHandled &&
          !it.canvasFlingComponent.isFirstEventHandled);

  @override
  ElementStateStack createStateStack() {
    return super.createStateStack();
  }

  @override
  void onRestoreStateStack(ElementStateStack stateStack) {
    super.onRestoreStateStack(stateStack);
    /*canvasElementControlManager.canvasDelegate
        .dispatchCanvasElementSelectChanged(this, children, children);*/
  }

  @override
  void onSelfPaintPropertyChanged(
      PaintProperty? old, PaintProperty? value, int propertyType) {
    canvasElementControlManager.updateControlBounds();
    super.onSelfPaintPropertyChanged(old, value, propertyType);
  }

  @override
  void resetChildren(List<ElementPainter>? children, bool resetGroupAngle) {
    super.resetChildren(children, resetGroupAngle);
  }

  @override
  List<ElementGroupPainter>? getGroupPainterList() {
    final result = <ElementGroupPainter>[];
    children?.forEach((element) {
      result.addAll(element.getGroupPainterList() ?? []);
    });
    return result;
  }

  @override
  void updatePaintPropertyFromChildren(bool resetGroupAngle) {
    super.updatePaintPropertyFromChildren(resetGroupAngle);
  }

  /// 仅更新子元素的绘制属性, 不更新自身的
  /// [updatePaintPropertyFromChildren]
  /// [updateChildPaintPropertyFromChildren]
  @property
  void updateChildPaintPropertyFromChildren([bool resetGroupAngle = false]) {
    getGroupPainterList()?.forEach((element) {
      element.updatePaintPropertyFromChildren(resetGroupAngle);
    });
  }

  /// 直接操作缩放属性
  @override
  void onlyScaleSelfElement(
      {double? sx, double? sy, double? sxTo, double? syTo}) {
    super.onlyScaleSelfElement(sx: sx, sy: sy, sxTo: sxTo, syTo: syTo);
  }

  /// 组内缩放元素
  @override
  void scaleElement({double sx = 1, double sy = 1, Offset? anchor}) {
    super.scaleElement(sx: sx, sy: sy, anchor: anchor);
  }

  @override
  void flipElementWithScale({bool? flipX, bool? flipY, Offset? anchor}) {
    //super.flipElementWithScale(flipX: flipX, flipY: flipY, anchor: anchor);
    //这种方式下的翻转, 自身不用动
    anchor ??= paintProperty?.paintCenter;
    children?.forEach((element) {
      element.flipElementWithScale(flipX: flipX, flipY: flipY, anchor: anchor);
    });
  }

  @override
  bool get isLockRatio {
    if (children?.length == 1) {
      final first = children!.first;
      return first.isLockRatio;
    }
    return super.isLockRatio;
  }

  @override
  set isLockRatio(bool value) {
    super.isLockRatio = value;
    if (children?.length == 1) {
      final first = children!.first;
      first.isLockRatio = value;
    }
  }

  @override
  bool isElementSupportControl(int type) {
    if (children?.length == 1) {
      final first = children!.first;
      return first.isElementSupportControl(type);
    }
    return super.isElementSupportControl(type);
  }

  /// 获取选择框内的元素
  List<ElementPainter>? _getSelectBoundsElementList([Rect? bounds]) {
    return (bounds ?? selectBounds)?.let((it) {
      final elements = canvasElementControlManager.canvasElementManager
          .findElement(rect: it);
      return elements;
    });
  }

  /// 更新选择框边界, 并且触发选择选择
  /// [select] 是否要使用[bounds]进行元素的元素
  void updateSelectBounds(Rect? bounds, bool select) {
    if (select) {
      //需要选择元素
      resetSelectElement(_getSelectBoundsElementList(bounds));
      canvasElementControlManager.updatePaintInfoType(PaintInfoType.size);
    }
    selectBounds = bounds;
    canvasElementControlManager.canvasDelegate
        .dispatchCanvasSelectBoundsChanged(bounds);
  }

  /// 重置选中的元素
  /// [CanvasElementManager.addSelectElement]
  /// [CanvasElementManager.addSelectElementList]
  /// [CanvasElementManager.removeSelectElement]
  /// [CanvasElementManager.removeSelectElementList]
  /// [CanvasElementManager.resetSelectElement]
  @api
  void resetSelectElement(List<ElementPainter>? elements) {
    //debugger();
    List<ElementPainter>? old = children;
    if (isNullOrEmpty(elements)) {
      //取消元素选择
      if (!isNullOrEmpty(children)) {
        assert(() {
          l.i('取消之前选中的元素: $children');
          return true;
        }());
        resetChildren(
          null,
          canvasElementControlManager.enableResetElementAngle,
        );
        canvasElementControlManager.onSelfSelectElementChanged();
        canvasElementControlManager.canvasDelegate
            .dispatchCanvasElementSelectChanged(this, old, children);
      }
    } else {
      assert(() {
        l.i('选中新的元素: $elements');
        return true;
      }());
      resetChildren(
        elements,
        canvasElementControlManager.enableResetElementAngle,
      );
      canvasElementControlManager.onSelfSelectElementChanged();
      canvasElementControlManager.canvasDelegate
          .dispatchCanvasElementSelectChanged(this, old, children);
    }
  }
}
