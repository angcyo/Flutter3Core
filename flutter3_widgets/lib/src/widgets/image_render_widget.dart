part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 图片渲染小部件
class ImageRenderWidget extends SingleChildRenderObjectWidget {
  final ImageRenderController controller;

  const ImageRenderWidget(this.controller, {super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      ImageRenderObject(controller);

  @override
  void updateRenderObject(
      BuildContext context, ImageRenderObject renderObject) {
    renderObject
      ..controller = controller
      ..markNeedsPaint();
  }
}

/// 核心渲染对象
class ImageRenderObject extends RenderProxyBox implements TickerProvider {
  ImageRenderController controller;

  ImageRenderObject(this.controller);

  ///
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
  }

  ///
  @override
  void detach() {
    _ticker?.dispose();
    _ticker = null;
    super.detach();
  }

  @override
  bool hitTestSelf(ui.Offset position) {
    return true;
  }

  /// 手势坐标点
  Offset? touchPointer;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    //l.d('${event.position} ${event.localPosition} ${event.delta}');
    if (event.isTouchEvent) {
      if (event.isPointerFinish) {
        if (touchPointer != null) {
          final imagePointer =
              controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
          if (controller._imageRect.contains(imagePointer)) {
            controller.onPointerUp?.call(imagePointer);
          }
        }
        touchPointer = null;
      } else {
        touchPointer = event.localPosition;
        final imagePointer =
            controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
        if (controller._imageRect.contains(imagePointer)) {
          controller.onPointerUpdate?.call(imagePointer);
        }
      }
      if (controller.renderCropOverlay) {
        controller._handleCropEvent(event);
      }
      markNeedsPaint();
    }
  }

  /// 开启绘制边界后 [paint.offset]就会变为0
  /// 但是放大镜组件就无法paint child了
  @override
  bool get isRepaintBoundary => false;

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (offset != Offset.zero) {
      assert(() {
        l.w("请使用[RepaintBoundary]包裹[ImageRenderWidget],否则手势计算不准确.");
        return true;
      }());
    }
    controller._initIfNeed(this);

    final canvas = context.canvas;

    //bg
    final rect = offset & size;
    if (controller.renderBgColor != null) {
      canvas.drawRect(rect, Paint()..color = controller.renderBgColor!);
    }

    //child
    super.paint(context, offset);

    //image
    final image = controller.image;
    if (image != null) {
      /*assert(() {
        canvas.drawRect(
            controller._imageOperateRect, Paint()..color = Colors.black26);
        if (touchPointer != null) {
          canvas.drawCircle(touchPointer!, 10, Paint()..color = Colors.black26);
        }

        canvas.drawRect(controller._imageRect, Paint()..color = Colors.black26);
        if (touchPointer != null) {
          final rawPointer =
              controller.operateMatrix.invertedMatrix().mapPoint(touchPointer!);
          canvas.drawCircle(rawPointer, 10, Paint()..color = Colors.black26);
        }
        return true;
      }());*/
      //debugger();
      canvas.withMatrix(
        controller.operateMatrix,
        () {
          canvas.drawImage(image, offset, Paint());
        },
      );

      if (controller.renderCropOverlay) {
        controller._paintCropOverlay(canvas, offset);
      }
    }
    //debugPaintBoxBounds(context, offset);
  }

  //region ---Ticker---

  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker =
        Ticker(onTick, debugLabel: 'created by ${describeIdentity(this)}');
    return _ticker!;
  }

//endregion ---Ticker---
}

/// 控制器
class ImageRenderController extends ChangeNotifier with NotifierMixin {
  /// 渲染的背景颜色
  Color? renderBgColor;

  /// 渲染的图片
  UiImage? image;

  /// 内边距
  EdgeInsets padding = const EdgeInsets.all(30);

  /// 在图片中手势移动的事件更新回调
  OffsetCallback? onPointerUpdate;

  /// 在图片中手势抬起的事件回调
  OffsetCallback? onPointerUp;

  //--

  /// 是否绘制剪切覆盖层, 并且会开启裁剪手势操作.
  bool renderCropOverlay;

  /// 剪切蒙层的颜色
  Color cropOverlayColor;

  /// 剪切线的大小
  double cropLineSize;

  /// 线宽
  double cropLineWidth;

  /// 线的颜色
  Color cropLineColor;

  ImageRenderController({
    this.image,
    this.renderBgColor,
    this.renderCropOverlay = false,
    this.cropOverlayColor = Colors.black26,
    this.cropLineSize = 20,
    this.cropLineWidth = 3,
    this.cropLineColor = Colors.white,
  });

  //region --控制操作--

  /// 重置图片
  /// [reset] 是否重置矩阵
  void resetImage(
    UiImage? image, {
    bool refresh = false,
    bool reset = true,
  }) {
    this.image = image;
    if (reset) {
      baseMatrix = null;
      _cropBounds = null;
    }
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  //endregion --控制操作--

  //region --绘制操作--

  /// 图片矩形
  Rect get _imageRect => Rect.fromLTWH(0.0, 0.0, image?.width.toDouble() ?? 1.0,
      image?.height.toDouble() ?? 1.0);

  /// 图片操作之后的矩形
  Rect get _imageOperateRect => operateMatrix.mapRect(_imageRect);

  /// 用来刷新界面使用
  ImageRenderObject? _renderObject;

  @autoInjectMark
  @initialize
  void _initIfNeed(ImageRenderObject renderObject) {
    //debugger();
    _renderObject = renderObject;
    if (baseMatrix == null) {
      final Size size = (renderObject.size -
          Offset(padding.horizontal, padding.vertical)) as Size;
      final rect = _imageRect;
      //默认居中显示图片
      final translate = Matrix4.identity();
      final scale = Matrix4.identity();
      final dst = applyAlignRect(size, rect.size,
          fit: BoxFit.contain, alignment: Alignment.center);
      translate.translate(dst.left + padding.left, dst.top + padding.top);
      scale.scale(dst.width / rect.size.width, dst.height / rect.size.height);
      baseMatrix = translate * scale;
    }
    if (renderCropOverlay) {
      if (_cropBounds == null) {
        resetCropBounds();
      }
    }
  }

  /// 基础矩阵
  /// [_initIfNeed]
  @autoInjectMark
  Matrix4? baseMatrix;

  /// 图片仅渲染时的矩阵
  Matrix4 get renderMatrix {
    final rotate = createRotateMatrix(
      cropRotate.hd,
      anchor: _imageRect.center,
    );
    final flip = createFlipMatrix(
      flipX: cropFlipX,
      flipY: cropFlipY,
      anchor: _imageRect.center,
    );
    return rotate * flip;
  }

  /// 操作后的矩阵, 包含了基础矩阵, 和操作属性的矩阵
  Matrix4 get operateMatrix {
    final base = baseMatrix ?? Matrix4.identity();
    return base * renderMatrix;
  }

  //endregion --绘制操作--

  //region --crop---

  @configProperty
  CropType cropType = CropType.rect;

  /// 剪切框的比例 w/h
  /// -1: 使用图片比例
  /// 0: 任意比例
  /// 1: 1:1
  /// 1.777 16:9
  @configProperty
  double cropScale = -1;

  /// 是否水平翻转
  @configProperty
  bool cropFlipX = false;

  /// 是否垂直翻转
  @configProperty
  bool cropFlipY = false;

  /// 旋转角度, 角度单位
  @configProperty
  double cropRotate = 0;

  /// 剪切框的位置, 需要反向映射[operateMatrix]才能是在图片中的位置
  Rect? _cropBounds;

  /// 最小剪切矩形范围
  Rect get _minCropBounds => Rect.fromLTWH(
        _imageOperateRect.left,
        _imageOperateRect.top,
        cropLineSize * 2,
        cropLineSize * 2,
      );

  /// 重置剪切框的位置和大小, 通常在重置图片之后操作
  @api
  void resetCropBounds({bool refresh = false}) {
    if (_renderObject == null) {
      return;
    }

    final rect = _imageOperateRect;
    if (cropScale <= 0) {
      //图片比例/任意比例
      _cropBounds = rect;
    } else {
      final double width;
      final double height;
      if (rect.width <= rect.height) {
        width = rect.width;
        height = width / cropScale;
      } else {
        height = rect.height;
        width = height * cropScale;
      }
      final alignRect = applyAlignRect(rect.size, Size(width, height));
      _cropBounds = Rect.fromLTWH(
          rect.left + alignRect.left, rect.top + alignRect.top, width, height);
    }
    _initCropCorner();
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  /// 更新剪切框, 通常在操作剪切框缩放之后调用
  @api
  void updateCropBounds(Rect rect, {bool refresh = true}) {
    _cropBounds = rect;
    _initCropCorner();
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  /// 更新剪切框的比例
  @api
  void updateCropScale(double scale, {bool refresh = true}) {
    cropScale = scale;
    resetCropBounds(refresh: refresh);
  }

  /// 更新剪切框的类型
  @api
  void updateCropType(CropType type, {bool refresh = true}) {
    cropType = type;
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  /// 更新翻转属性
  @api
  void updateFlip({bool? flipX, bool? flipY, bool refresh = true}) {
    cropFlipX = flipX ?? cropFlipX;
    cropFlipY = flipY ?? cropFlipY;
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  /// 切换翻转属性
  @api
  void toggleFlipX({bool refresh = true}) {
    cropFlipX = !cropFlipX;
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  /// 切换翻转属性
  @api
  void toggleFlipY({bool refresh = true}) {
    cropFlipY = !cropFlipY;
    if (refresh) {
      _renderObject?.markNeedsPaint();
    }
  }

  AnimationController? _lastAnimate;

  /// 更新旋转角度
  /// [rotate] 目标要旋转到的角度
  @api
  void updateRotate(
    double rotate, {
    bool refresh = true,
    bool animate = true,
  }) {
    if (animate) {
      if (_lastAnimate != null) {
        assert(() {
          l.d('动画正在进行..., 忽略操作');
          return true;
        }());
        return;
      }
    }
    final oldCropRotate = cropRotate;
    final newCropRotate = rotate % 360;
    cropRotate = newCropRotate;
    resetCropBounds(refresh: refresh);
    if ((refresh || animate) && _renderObject != null) {
      if (animate) {
        _lastAnimate = animation(_renderObject!, (value, isCompleted) {
          cropRotate = oldCropRotate + (rotate - oldCropRotate) * value;
          _renderObject?.markNeedsPaint();
          if (isCompleted) {
            _lastAnimate = null;
          }
        });
      }
      _renderObject?.markNeedsPaint();
    }
  }

  /// 获取剪切的图片
  Future<UiImage?> cropImage() async {
    if (_cropBounds != null) {
      final base = baseMatrix ?? Matrix4.identity();
      final bounds = base.invertedMatrix().mapRect(_cropBounds!);
      final cropPath = Path();
      if (cropType == CropType.oval) {
        cropPath.addOval(bounds);
      } else {
        cropPath.addRect(bounds);
      }
      return image?.crop(bounds, cropPath, matrix: renderMatrix);
    }
    return null;
  }

  /// 按下时的触角信息
  CropCornerRect? _downCornerRect;

  Offset? _downPosition;

  /// 按下时的剪切框信息
  Rect? _downCropRect;

  /// 处理手势
  @callPoint
  void _handleCropEvent(PointerEvent event) {
    if (event.isPointerDown) {
      _downCornerRect = cropCornerList.findFirst((e) {
        if (e.rect.inflate(10).contains(event.localPosition)) {
          return true;
        }
        return false;
      });
      if (_downCornerRect != null) {
        //在缩放触点上按下, 则进行缩放操作
        _downPosition = event.localPosition;
        _downCropRect = _cropBounds;
      } else if (_cropBounds?.contains(event.localPosition) == true) {
        //在剪切框内按下, 则进行平移操作
        _downPosition = event.localPosition;
        _downCropRect = _cropBounds;
      }
    } else if (event.isPointerMove) {
      if (_downCornerRect != null) {
        //debugger();
        //开始计算缩放后的剪切框
        final movePosition = event.localPosition;
        double sx;
        double sy;
        final equalRatio = cropScale != 0;
        if (!equalRatio) {
          //任意比例
          sx = (movePosition.dx - _downCornerRect!.keepAnchor.dx) /
              (_downPosition!.dx - _downCornerRect!.keepAnchor.dx);
          sy = (movePosition.dy - _downCornerRect!.keepAnchor.dy) /
              (_downPosition!.dy - _downCornerRect!.keepAnchor.dy);
          if (_downCornerRect!.alignment == Alignment.centerLeft ||
              _downCornerRect!.alignment == Alignment.centerRight) {
            sy = 1;
          } else if (_downCornerRect!.alignment == Alignment.topCenter ||
              _downCornerRect!.alignment == Alignment.bottomCenter) {
            sx = 1;
          }
        } else {
          //等比
          final oldC = distance(_downPosition!, _downCornerRect!.keepAnchor);
          final newC = distance(movePosition, _downCornerRect!.keepAnchor);
          sx = sy = newC / oldC;
        }
        //l.d('sx:$sx sy:$sy');
        final pair = Limit.limitRectScale(
          _downCropRect!,
          sx,
          sy,
          equalRatio: equalRatio,
          minRect: _minCropBounds,
          maxRect: _imageOperateRect,
        );
        sx = pair.sx;
        sy = pair.sy;
        final scale = Matrix4.identity()..scale(sx, sy);
        final rect = _downCropRect!.applyMatrix(
          scale,
          anchor: _downCornerRect!.keepAnchor - _downCropRect!.lt,
          limitContainerRect: _imageOperateRect,
        );
        if (rect != _downCropRect!) {
          updateCropBounds(rect, refresh: true);
        }
      } else if (_downPosition != null) {
        //平移操作
        final movePosition = event.localPosition;
        final tx = movePosition.dx - _downPosition!.dx;
        final ty = movePosition.dy - _downPosition!.dy;

        final rect = Limit.limitRectTranslate(
          _downCropRect!,
          tx,
          ty,
          _imageOperateRect,
        );
        updateCropBounds(rect, refresh: true);
      }
    } else if (event.isPointerFinish) {
      _downPosition = null;
      _downCropRect = null;
      _downCornerRect = null;
    }
  }

  /// 绘制裁剪覆盖层
  @callPoint
  void _paintCropOverlay(Canvas canvas, UiOffset offset) {
    if (_renderObject != null && _cropBounds != null) {
      //绘制覆盖层
      final parentPath = Path()
        ..addRect(Rect.fromLTWH(
          offset.dx,
          offset.dy,
          _renderObject!.size.width,
          _renderObject!.size.height,
        ));
      final cropPath = Path();
      if (cropType == CropType.oval) {
        cropPath.addOval(_cropBounds!);
      } else {
        cropPath.addRect(_cropBounds!);
      }
      final overlayPath = parentPath.op(cropPath, PathOperation.difference);
      //canvas.drawRect(_cropBounds! + offset, Paint()..color = Colors.redAccent);
      canvas.drawPath(overlayPath, Paint()..color = cropOverlayColor);

      //绘制网格线
      final gridSize = cropLineWidth / 2;
      final gridColor = cropLineColor.withOpacity(0.8);
      final gridPaint = Paint()..color = gridColor;
      final lR = Rect.fromLTWH(
        _cropBounds!.left - gridSize,
        _cropBounds!.top - gridSize,
        gridSize,
        _cropBounds!.height + gridSize * 2,
      );
      canvas.drawRect(lR, gridPaint);
      final tR = Rect.fromLTWH(
        _cropBounds!.left - gridSize,
        _cropBounds!.top - gridSize,
        _cropBounds!.width + gridSize * 2,
        gridSize,
      );
      canvas.drawRect(tR, gridPaint);
      final rR = Rect.fromLTWH(
        _cropBounds!.right,
        _cropBounds!.top - gridSize,
        gridSize,
        _cropBounds!.height + gridSize * 2,
      );
      canvas.drawRect(rR, gridPaint);
      final bR = Rect.fromLTWH(
        _cropBounds!.left - gridSize,
        _cropBounds!.bottom,
        _cropBounds!.width + gridSize * 2,
        gridSize,
      );
      canvas.drawRect(bR, gridPaint);
      //
      for (var i = 1; i < 3; i++) {
        final top = lR.top + lR.height * i / 3;
        canvas.drawLine(Offset(lR.left, top), Offset(rR.left, top), gridPaint);
      }
      //
      for (var i = 1; i < 3; i++) {
        final left = tR.left + tR.width * i / 3;
        canvas.drawLine(Offset(left, lR.top), Offset(left, bR.top), gridPaint);
      }

      //绘制剪切线
      for (final corner in cropCornerList) {
        canvas.drawRect(corner.rect, Paint()..color = cropLineColor);
      }
    }
  }

  final List<CropCornerRect> cropCornerList = [];

  /// 剪切线
  void _initCropCorner() {
    cropCornerList.clear();
    if (_cropBounds != null) {
      final left = _cropBounds!.left;
      final top = _cropBounds!.top;
      final right = _cropBounds!.right;
      final bottom = _cropBounds!.bottom;
      final cx = _cropBounds!.center.dx;
      final cy = _cropBounds!.center.dy;

      //
      cropCornerList.add(CropCornerRect(
          _cropBounds!.rb,
          Alignment.topLeft,
          Rect.fromLTWH(
            left - cropLineWidth,
            top - cropLineWidth,
            cropLineWidth,
            cropLineSize,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.rb,
          Alignment.topLeft,
          Rect.fromLTWH(
            left,
            top - cropLineWidth,
            cropLineSize - cropLineWidth,
            cropLineWidth,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.bottomCenter,
          Alignment.topCenter,
          Rect.fromLTWH(
            cx - cropLineSize / 2,
            top - cropLineWidth,
            cropLineSize,
            cropLineWidth,
          )));

      //
      cropCornerList.add(CropCornerRect(
          _cropBounds!.bottomLeft,
          Alignment.topRight,
          Rect.fromLTWH(
            right - cropLineSize + cropLineWidth,
            top - cropLineWidth,
            cropLineSize,
            cropLineWidth,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.bottomLeft,
          Alignment.topRight,
          Rect.fromLTWH(
            right,
            top - cropLineWidth,
            cropLineWidth,
            cropLineSize,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.centerLeft,
          Alignment.centerRight,
          Rect.fromLTWH(
            right,
            cy - cropLineSize / 2,
            cropLineWidth,
            cropLineSize,
          )));

      //
      cropCornerList.add(CropCornerRect(
          _cropBounds!.lt,
          Alignment.bottomRight,
          Rect.fromLTWH(
            right,
            bottom - cropLineSize + cropLineWidth,
            cropLineWidth,
            cropLineSize,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.lt,
          Alignment.bottomRight,
          Rect.fromLTWH(
            right - cropLineSize + cropLineWidth,
            bottom,
            cropLineSize,
            cropLineWidth,
          )));

      //
      cropCornerList.add(CropCornerRect(
          _cropBounds!.topCenter,
          Alignment.bottomCenter,
          Rect.fromLTWH(
            cx - cropLineSize / 2,
            bottom,
            cropLineSize,
            cropLineWidth,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.rt,
          Alignment.bottomLeft,
          Rect.fromLTWH(
            left - cropLineWidth,
            bottom,
            cropLineSize,
            cropLineWidth,
          )));
      cropCornerList.add(CropCornerRect(
          _cropBounds!.rt,
          Alignment.bottomLeft,
          Rect.fromLTWH(
            left - cropLineWidth,
            bottom - cropLineSize + cropLineWidth,
            cropLineWidth,
            cropLineSize,
          )));

      //
      cropCornerList.add(CropCornerRect(
          _cropBounds!.centerRight,
          Alignment.centerLeft,
          Rect.fromLTWH(
            left - cropLineWidth,
            cy - cropLineSize / 2,
            cropLineWidth,
            cropLineSize,
          )));
    }
  }

//endregion --crop---
}

enum CropType {
  rect,
  oval,
}

class CropCornerRect {
  /// 操作当前锚点时,需要保持矩形上的什么位置不变
  Offset keepAnchor;

  /// 锚点的方向位置
  Alignment alignment;

  /// 锚点的位置
  Rect rect;

  CropCornerRect(this.keepAnchor, this.alignment, this.rect);
}
