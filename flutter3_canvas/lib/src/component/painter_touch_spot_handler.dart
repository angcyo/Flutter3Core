part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// 元素可交互的触点处理类
/// - 所有触点事件分发
/// - 所有触点绘制入口
class PainterTouchSpotHandler extends IPainter {
  /// 所在容器的矩阵
  @configProperty
  Matrix4? parentMatrix;

  /// 触点列表
  @configProperty
  final List<TouchSpot> touchSpotList = [];

  //region core

  @override
  void applyPaintTransform(IPainter child, Matrix4 transform) {
    if (this.parent == null && parentMatrix != null) {
      debugger(when: debugLabel != null);
      transform.multiply(parentMatrix!);
    }
    super.applyPaintTransform(child, transform);
  }

  /// 绘制入口
  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    PaintMeta meta = paintMeta;
    //debugger();
    if (parentMatrix != null) {
      meta = paintMeta.copyWith(
        originMatrix: Matrix4.identity(),
        canvasMatrix: paintMeta.paintMatrix * parentMatrix!,
      );
    }
    meta.withPaintMatrix(canvas, () {
      for (final element in touchSpotList) {
        element.painting(canvas, meta);
      }
    });
  }

  /// 正在触摸的触点
  TouchSpot? _touchSpot;

  /// 手势入口
  @overridePoint
  bool handlePointerEvent(
    @viewCoordinate PointerEvent event,
    @sceneCoordinate Offset position, {
    void Function(MouseCursor? cursor)? onUpdateCursor,
  }) {
    //debugger();
    bool handle = false;
    //l.d("test->$position");
    if (event.isPointerHover) {
      final touchSpot = findTouchSpot(position, filterHandlerEvent: false);
      cancelTouchSpotHover(event, ignoreTouchSpot: touchSpot);
      if (touchSpot != null) {
        final (h, cursor) = touchSpot.handlePointerHover(event, true);
        onUpdateCursor?.call(cursor);
      } else {
        onUpdateCursor?.call(null);
      }
    } else if (event.isPointerDown) {
      final touchSpot = findTouchSpot(position, filterHandlerEvent: true);
      handle = touchSpot != null;
      _touchSpot = touchSpot;
    }
    //--
    if (_touchSpot != null) {
      _touchSpot!.handlePointerEvent(event);
      handle = true;
    }
    //--
    if (event.isPointerFinish) {
      _touchSpot = null;
    }
    return handle;
  }

  //endregion core

  //region api

  /// 使用画布坐标系[position]点, 查找能命中的触点
  @api
  TouchSpot? findTouchSpot(
    @sceneCoordinate Offset position, {
    bool filterHandlerEvent = false,
  }) {
    for (final element in touchSpotList.reversed) {
      if (filterHandlerEvent && !element.isEnablePointerEvent()) {
        continue;
      }
      final location = element.bounds;
      if (location != null) {
        final bounds = (parentMatrix?.mapRect(location) ?? location);
        if (bounds.contains(position)) {
          return element;
        }
      }
    }
    return null;
  }

  /// 添加一个触点到列表中
  @api
  void addTouchSpot(TouchSpot touchSpot) {
    touchSpotList.add(touchSpot);
    adoptChild(touchSpot);
  }

  /// 重置所有触点
  @api
  void resetTouchSpot([Iterable<TouchSpot>? elements]) {
    if (elements != null) {
      final removeList = touchSpotList.where((element) {
        return !elements.contains(element);
      });
      for (final e in removeList) {
        dropChild(e);
      }
    }

    touchSpotList.resetAll(elements);
    for (final e in touchSpotList) {
      adoptChild(e);
    }
  }

  /// 取消所有触点的悬停状态
  @api
  void cancelTouchSpotHover(
    @viewCoordinate PointerEvent event, {
    TouchSpot? ignoreTouchSpot,
  }) {
    for (final element in touchSpotList) {
      if (element == ignoreTouchSpot) {
        continue;
      }
      element.handlePointerHover(event, false);
    }
  }

  //endregion api
}

/// 触点
/// - [PainterTouchSpotHandler]
class TouchSpot extends IPainter
    with
        IPainterEventHandlerMixin,
        IPainterHoverHandlerMixin,
        TranslateDetectorMixin,
        TouchSpotTranslateMixin {
  /// 触点的位置, 相对坐标系
  /// - 相对于父坐标位置的位置
  @dp
  @configProperty
  @relativeCoordinate
  Rect? bounds;

  /// 绘制回调
  @configProperty
  void Function(Canvas canvas, PaintMeta paintMeta)? onPainting;

  /// [bounds]更新的回调
  @configProperty
  void Function(TouchSpot touchSpot, Rect? bounds)? onDidBoundsUpdate;

  /// 坐标缩放比例
  @property
  double coordinateScaleX = 1;
  double coordinateScaleY = 1;

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    coordinateScaleX = paintMeta.canvasScaleX;
    coordinateScaleY = paintMeta.canvasScaleY;
    paintMeta.withPaintMatrix(canvas, () {
      onPainting?.call(canvas, paintMeta);
    });
  }

  @override
  bool isEnablePointerEvent() => true;

  /// 事件入口
  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    return super.handlePointerEvent(event);
  }

  /// 用来更新[bounds], 并触发回调
  @api
  void updateBounds(@dp @relativeCoordinate Rect? bounds) {
    if (bounds != this.bounds) {
      this.bounds = bounds;
      onDidBoundsUpdate?.call(this, bounds);
    }
  }

  //--

  /// 出否处于悬停状态
  @property
  bool isHover = false;

  @override
  (bool, MouseCursor?) handlePointerHover(
    @viewCoordinate PointerEvent event,
    bool hover,
  ) {
    isHover = hover;
    return (
      false,
      isHover
          ? isMacOS
                ? SystemMouseCursors.click
                : SystemMouseCursors.move
          : null,
    );
  }

  //--

  /// [CanvasDelegate]
  Matrix4? getCanvasMatrix() {
    IPainter? parent = this.parent;
    if (parent is ElementPainter) {
      return parent.canvasDelegate?.canvasViewBox.canvasMatrix;
    } else {
      while (true) {
        parent = parent?.parent;
        if (parent is ElementPainter) {
          return parent.canvasDelegate?.canvasViewBox.canvasMatrix;
        } else if (parent == null) {
          break;
        }
      }
    }

    return null;
  }
}

/// 用来支持移动触点的混入
mixin TouchSpotTranslateMixin
    on IPainterEventHandlerMixin, TranslateDetectorMixin {
  /// 按下时[TouchSpot.bounds]
  Rect? _downBounds;

  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    if (event.isPointerDown) {
      final that = this;
      if (that is TouchSpot) {
        //debugger();
        //l.d("coordinateScaleX->${that.coordinateScaleX}");
        translateDetectorSlopX = kTouchMoveSlop * that.coordinateScaleX;
        translateDetectorSlopY = kTouchMoveSlop * that.coordinateScaleY;
        _downBounds = that.bounds;
      } else {
        translateDetectorSlopX = kTouchMoveSlop;
        translateDetectorSlopY = kTouchMoveSlop;
      }
    }
    return addTranslateDetectorPointerEvent(event);
  }

  @override
  Offset getTranslateDetectorPointerEventPosition(PointerEvent event) {
    final position = super.getTranslateDetectorPointerEventPosition(event);
    final that = this;
    if (that is TouchSpot) {
      //debugger();
      final Matrix4 matrix =
          (that.getCanvasMatrix() ?? Matrix4.identity()) *
          that.getTransformTo();
      //l.i("matrix↓\n$matrix");
      return matrix.invertedMatrix().mapPoint(position);
    }
    return position;
  }

  @override
  bool handleTranslateDetectorPointerEvent(
    PointerEvent event,
    double ddx,
    double ddy,
    double mdx,
    double mdy,
  ) {
    final that = this;
    if (mdx != 0 && mdy != 0 && _downBounds != null && that is TouchSpot) {
      that.updateBounds(_downBounds?.translate(ddx, ddy));
      return true;
    }
    return false;
  }
}
