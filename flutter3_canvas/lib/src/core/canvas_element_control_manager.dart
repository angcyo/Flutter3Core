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

  /// 是否激活元素的控制操作
  bool enableElementControl = true;

  /// 是否激活元素[PaintProperty]属性改变后, 重置旋转角度
  bool enableResetElementAngle = true;

  /// 绘制元素的信息
  PaintInfoType paintInfoType = PaintInfoType.none;

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

  /// 是否在元素上按下
  bool get isPointerDownElement =>
      _currentControlRef?.target?.controlType ==
          BaseControl.CONTROL_TYPE_TRANSLATE &&
      isControlElement;

  /// 是否正在控制元素中
  bool get isControlElement => _currentControlState == ControlState.start;

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
    if (enableElementControl &&
        elementSelectComponent.isSelectedElement &&
        !isPointerDownElement) {
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

  /// 事件处理入口
  /// [CanvasEventManager.handleEvent]
  @entryPoint
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (enableElementControl) {
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

  //---

  /// 当有元素绘制属性发生变化时调用
  /// 此时可能需要检查是否需要清空旋转的角度
  /// [CanvasDelegate.dispatchCanvasElementPropertyChanged]
  @property
  @implementation
  void onSelfElementPropertyChanged(ElementPainter element) {
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
    /*if (isSelectedElement) {
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
    }*/
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
      elementSelectComponent.resetChildren(null, enableResetElementAngle);
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
      if (controlType == BaseControl.CONTROL_TYPE_ROTATE) {
        updatePaintInfoType(PaintInfoType.rotate);
      }
    } else {
      if (controlType == BaseControl.CONTROL_TYPE_ROTATE) {
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
    if (isSelectedElement) {
      updatePaintInfoType(PaintInfoType.size);
    } else {
      updatePaintInfoType(PaintInfoType.none);
    }
  }
}

/// 选择元素组件, 滑动选择元素
class ElementSelectComponent extends ElementGroupPainter
    with
        CanvasComponentMixin,
        IHandleEventMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin {
  final CanvasElementControlManager canvasElementControlManager;

  /// 限制最小缩放比例
  double? minScale = 0.1;

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
    if (isSelectedElement) {
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
  bool interceptPointerEvent(PointerEvent event) {
    //debugger();
    return super.interceptPointerEvent(event);
  }

  @sceneCoordinate
  Offset _downScenePoint = Offset.zero;

  /// 按下时, 选中的元素列表
  List<ElementPainter>? _downElementList;

  @override
  bool onPointerEvent(PointerEvent event) {
    //debugger();
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
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
            updateSelectBounds(null, false);
            resetSelectElement(_downElementList?.lastOrNull?.ofList());
          }
          _downElementList = null;
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
    return super.onPointerEvent(event);
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
  void updatePaintPropertyFromChildren(bool resetGroupAngle) {
    super.updatePaintPropertyFromChildren(resetGroupAngle);
  }

  @override
  List<ElementGroupPainter>? getGroupPainterList() {
    final result = <ElementGroupPainter>[];
    children?.forEach((element) {
      result.addAll(element.getGroupPainterList() ?? []);
    });
    return result;
  }

  @property
  void updateChildPaintPropertyFromChildren([bool resetGroupAngle = false]) {
    getGroupPainterList()?.forEach((element) {
      element.updatePaintPropertyFromChildren(resetGroupAngle);
    });
  }

  /// 缩放选中的元素
  @api
  void applyScaleMatrix({double sx = 1, double sy = 1, Offset? anchor}) {
    double angle = paintProperty?.angle ?? 0; //弧度
    anchor ??= paintProperty?.anchor ?? Offset.zero;

    //自身使用直接缩放
    paintProperty?.let((it) {
      final tsx = it.scaleX * sx;
      final tsy = it.scaleY * sy;

      minScale?.let((min) {
        double minSx = tsx < min ? min / it.scaleX : sx;
        double minSy = tsy < min ? min / it.scaleY : sy;

        if (tsx < min || tsy < min) {
          //最终的缩放比例小于限制的最小值
          if (sx.equalTo(sy)) {
            //等比缩放
            if (tsx < min) {
              sx = minSx;
            } else {
              sx = minSy;
            }
            sy = sx;
          } else {
            //不等比缩放
            sx = minSx;
            sy = minSy;
          }
        }
      });

      paintProperty = it.clone()..applyScale(sxBy: sx, syBy: sy);
    });

    //子元素使用矩阵缩放
    final matrix = Matrix4.identity();

    if (angle % (2 * pi) == 0) {
      //未旋转
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchor);

      matrix.postConcat(scaleMatrix);
    } else {
      final rotateMatrix = Matrix4.identity()
        ..rotateBy(angle, anchor: paintProperty?.paintRect.center);
      final rotateInvertMatrix = rotateMatrix.invertedMatrix();
      Offset anchorInvert = rotateInvertMatrix.mapPoint(anchor);

      final scaleMatrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchorInvert);

      matrix.setFrom(rotateInvertMatrix);
      matrix.postConcat(scaleMatrix);
      matrix.postConcat(rotateMatrix);
    }

    children?.forEach((element) {
      element.applyMatrixWithCenter(matrix);
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
  List<ElementPainter>? _getSelectBoundsElementList() {
    return selectBounds?.let((it) {
      final elements = canvasElementControlManager.canvasElementManager
          .findElement(rect: it);
      return elements;
    });
  }

  /// 更新选择框边界, 并且触发选择选择
  void updateSelectBounds(Rect? bounds, bool select) {
    if (select) {
      //需要选择元素
      resetSelectElement(_getSelectBoundsElementList());
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
