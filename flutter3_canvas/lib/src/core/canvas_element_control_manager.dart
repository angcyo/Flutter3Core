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
  bool get isPointerDownElement => _pointerDownElement != null;

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

  /// 当选中的元素发生变化时, 调用
  /// 此时需要更新控制点的位置
  /// 需要更新lock状态
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
      elementSelectComponent.resetChildren();
      canvasDelegate.canvasElementManager.removeElementList(list);
    }
  }

  /// 当前正在按下的元素, 用来标识
  /// 可以在按下元素时, 减少干扰元素的绘制
  ElementPainter? _pointerDownElement;

  /// 更新当前手势按下的元素
  @flagProperty
  void updatePointerDownElement(ElementPainter? element) {
    _pointerDownElement = element;
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
      paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
      paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
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
          if (!event.isMoveExceed(firstDownEvent?.localPosition)) {
            //未移动手指, 可能是点击选择元素
            updateSelectBounds(null, false);
            resetSelectElement(_downElementList?.lastOrNull?.ofList());
          } else {
            updateSelectBounds(
                null, isFirstMoveExceed() && _noCanvasEventHandle());
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
  void onSelfPaintPropertyChanged(
      PaintProperty? old, PaintProperty? value, int propertyType) {
    canvasElementControlManager.updateControlBounds();
    super.onSelfPaintPropertyChanged(old, value, propertyType);
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

  /// 更新选择框边界, 并且触发选择选择
  void updateSelectBounds(Rect? bounds, bool select) {
    if (select) {
      //需要选择元素
      selectBounds?.let((it) {
        final elements = canvasElementControlManager.canvasElementManager
            .findElement(rect: it);
        resetSelectElement(elements);
      });
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
        resetChildren();
        canvasElementControlManager.onSelfSelectElementChanged();
        canvasElementControlManager.canvasDelegate
            .dispatchCanvasElementSelectChanged(this, old, children);
      }
    } else {
      assert(() {
        l.i('选中新的元素: $elements');
        return true;
      }());
      resetChildren(elements);
      canvasElementControlManager.onSelfSelectElementChanged();
      canvasElementControlManager.canvasDelegate
          .dispatchCanvasElementSelectChanged(this, old, children);
    }
  }
}
