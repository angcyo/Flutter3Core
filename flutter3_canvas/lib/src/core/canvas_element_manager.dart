part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 元素管理, 包含元素的绘制, 选择, 添加/删除等相关操作

class CanvasElementManager with Diagnosticable, PointerDispatchMixin {
  final CanvasDelegate canvasDelegate;

  /// 选择元素操作的组件
  late ElementSelectComponent elementSelectComponent =
      ElementSelectComponent(this);

  CanvasElementManager(this.canvasDelegate) {
    addHandleEventClient(elementSelectComponent);
  }

  /// 元素列表
  final List<ElementPainter> elements = [];

  //region ---entryPoint----

  /// 绘制元素入口
  /// [CanvasPaintManager.paint]
  @entryPoint
  void paintElements(Canvas canvas, PaintMeta paintMeta) {
    canvas.withClipRect(canvasDelegate.canvasViewBox.canvasBounds, () {
      for (var element in elements) {
        element.painting(canvas, paintMeta);
      }
      elementSelectComponent.painting(canvas, paintMeta);
    });
  }

  /// 事件处理入口
  /// [CanvasEventManager.handleEvent]
  @entryPoint
  void handleElementEvent(PointerEvent event, BoxHitTestEntry entry) {
    handleDispatchEvent(event);
  }

  //endregion ---entryPoint----

  /// 添加元素
  void addElement(ElementPainter element) {
    elements.add(element);
  }

  /// 删除元素
  void removeElement(ElementPainter element) {
    elements.remove(element);
  }

  /// 清空元素
  void clearElements() {
    elements.clear();
  }

  /// 查找元素, 按照元素的先添加先返回的顺序
  List<ElementPainter> findElement({Offset? point, Rect? rect, Path? path}) {
    final result = <ElementPainter>[];
    for (var element in elements) {
      if (element.hitTest(point: point, rect: rect, path: path)) {
        result.add(element);
      }
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('elements', elements));
  }
}

/// 选择元素组件, 滑动选择元素
class ElementSelectComponent extends ElementGroupPainter
    with
        CanvasComponentMixin,
        IHandleEventMixin,
        MultiPointerDetectorMixin,
        HandleEventMixin {
  final CanvasElementManager canvasElementManager;

  /// 画笔
  final Paint boundsPaint = Paint();

  /// 选择框的边界, 场景坐标系
  @sceneCoordinate
  Rect? selectBounds;

  ElementSelectComponent(this.canvasElementManager);

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
    paint.color =
        canvasElementManager.canvasDelegate.canvasStyle.canvasAccentColor;
    paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
    paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
  }

  /// 绘制选中元素的边界
  @entryPoint
  void paintSelectBounds(Canvas canvas, PaintMeta paintMeta) {
    if (selectBounds != null) {
      paintMeta.withPaintMatrix(canvas, () {
        boundsPaint
          ..color =
              canvasElementManager.canvasDelegate.canvasStyle.canvasAccentColor
          ..strokeWidth = 1 / paintMeta.canvasScale
          ..style = PaintingStyle.stroke;
        canvas.drawRect(selectBounds!, boundsPaint);
        boundsPaint
          ..color = canvasElementManager
              .canvasDelegate.canvasStyle.canvasAccentColor
              .withOpacity(0.1)
          ..style = PaintingStyle.fill;
        canvas.drawRect(selectBounds!, boundsPaint);
      });
    }
  }

  @override
  bool interceptPointerEvent(PointerEvent event) {
    //debugger();
    return super.interceptPointerEvent(event);
  }

  @sceneCoordinate
  Offset _downScenePoint = Offset.zero;

  @override
  bool onPointerEvent(PointerEvent event) {
    //debugger();
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        final viewBox = canvasElementManager.canvasDelegate.canvasViewBox;
        if (event.isPointerDown) {
          _downScenePoint = viewBox.toScenePoint(event.localPosition);
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
          updateSelectBounds(
              null, isFirstMoveExceed() && _noCanvasEventHandle());
        }
        return true;
      } else if (event.isPointerDown) {
        //多个手指按下
        //debugger();
        if (!isFirstMoveExceed()) {
          //时, 第一个手指未移动, 则取消滑动选择元素
          ignoreHandle = true;
          updateSelectBounds(null, false);
        }
      }
    }
    return super.onPointerEvent(event);
  }

  /// 没有进行画布的操作
  bool _noCanvasEventHandle() =>
      canvasElementManager.canvasDelegate.canvasEventManager.let((it) =>
          !it.canvasTranslateComponent.isFirstEventHandled &&
          !it.canvasScaleComponent.isFirstEventHandled &&
          !it.canvasFlingComponent.isFirstEventHandled);

  /// 更新选择框边界, 并且触发选择选择
  void updateSelectBounds(Rect? bounds, bool select) {
    if (select) {
      //需要选择元素
      selectBounds?.let((it) {
        final elements = canvasElementManager.findElement(rect: it);
        resetSelectElement(elements);
      });
    }
    selectBounds = bounds;
    canvasElementManager.canvasDelegate
        .dispatchCanvasSelectBoundsChanged(bounds);
  }

  /// 重置选中的元素
  void resetSelectElement(List<ElementPainter>? elements) {
    List<ElementPainter>? old = children;
    if (isNullOrEmpty(elements)) {
      //取消元素选择
      if (!isNullOrEmpty(children)) {
        l.i('取消选中元素: $children');
        resetChildren();
        canvasElementManager.canvasDelegate
            .dispatchCanvasElementSelectChanged(this, old, children);
      }
    } else {
      l.i('选中元素: $elements');
      resetChildren(elements);
      canvasElementManager.canvasDelegate
          .dispatchCanvasElementSelectChanged(this, old, children);
    }
  }
}
