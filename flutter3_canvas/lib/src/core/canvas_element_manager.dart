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
        element.paint(canvas, paintMeta);
      }
      elementSelectComponent.paintSelectBounds(canvas, paintMeta);
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

  /// 查找元素
/*ElementPainter? findElement(Offset offset) {
    for (var element in elements) {
      if (element.contains(offset)) {
        return element;
      }
    }
    return null;
  }*/

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

  /// 绘制选中元素的边界
  @entryPoint
  void paintSelectBounds(Canvas canvas, PaintMeta paintMeta) {
    if (selectBounds != null) {
      paintMeta.withPaintMatrix(canvas, () {
        boundsPaint
          ..color =
              canvasElementManager.canvasDelegate.canvasStyle.canvasAccentColor
          ..strokeWidth = 1 / (paintMeta.canvasMatrix?.scaleX ?? 1)
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
  bool handleMultiPointerDetectorPointerEvent(PointerEvent event) {
    return super.handleMultiPointerDetectorPointerEvent(event);
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
        if (event.isPointerDown) {
          _downScenePoint = canvasElementManager.canvasDelegate.canvasViewBox
              .toScenePoint(event.localPosition);
          updateSelectBounds(Rect.fromLTRB(_downScenePoint.dx,
              _downScenePoint.dy, _downScenePoint.dx, _downScenePoint.dy));
        } else if (event.isPointerMove) {
          final scenePoint = canvasElementManager.canvasDelegate.canvasViewBox
              .toScenePoint(event.localPosition);
          updateSelectBounds(Rect.fromPoints(_downScenePoint, scenePoint));
          //l.d(' selectBounds:$selectBounds');
        } else if (event.isPointerUp) {
          //选择结束
          updateSelectBounds(null);
        }
        return true;
      } else if (event.isPointerDown) {
        //多个手指按下
        //debugger();
        if (!isFirstMoveExceed()) {
          //时, 第一个手指未移动, 则取消滑动选择元素
          ignoreHandle = true;
          updateSelectBounds(null);
        }
      }
    }
    return super.onPointerEvent(event);
  }

  /// 更新选择边界
  void updateSelectBounds(Rect? bounds) {
    selectBounds = bounds;
    canvasElementManager.canvasDelegate.refresh();
    canvasElementManager.canvasDelegate
        .dispatchCanvasSelectBoundsChangedAction(bounds);
  }
}
