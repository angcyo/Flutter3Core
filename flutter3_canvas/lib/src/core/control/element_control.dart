part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/05
///
/// 元素控制
class BaseControl with CanvasComponentMixin, IHandleEventMixin {
  /// 控制点: 删除
  static const CONTROL_TYPE_DELETE = 1;

  /// 控制点: 旋转
  static const CONTROL_TYPE_ROTATE = 2;

  /// 控制点: 缩放
  static const CONTROL_TYPE_SCALE = 3;

  /// 控制点: 锁定等比
  static const CONTROL_TYPE_LOCK = 4;

  /// 控制行为: 平移
  static const CONTROL_TYPE_TRANSLATE = 5;

  final CanvasElementControlManager canvasElementControlManager;

  /// 控制点的类型
  final int controlType;

  /// 控制点的位置, 视图坐标系
  @viewCoordinate
  Rect? controlBounds;

  /// 手势是否在控制点上按下, 每次按下时重置
  bool isPointerDownIn = false;

  /// 是否是首次处理事件, 每次按下时重置
  bool isFirstHandle = true;

  /// 控制点绘制的大小
  @dp
  double controlSize = 24;

  /// 距离目标的偏移量
  @dp
  double controlOffset = -4;

  /// 绘制控制点图片额外的内边距
  @dp
  double controlIcoPadding = 4;

  /// 控制点的图片信息, 用来绘制控制点图标
  PictureInfo? _pictureInfo;

  //---

  CanvasStyle get canvasStyle =>
      canvasElementControlManager.canvasDelegate.canvasStyle;

  CanvasViewBox get canvasViewBox =>
      canvasElementControlManager.canvasDelegate.canvasViewBox;

  BaseControl(this.canvasElementControlManager, this.controlType);

  @entryPoint
  void paintControl(Canvas canvas, PaintMeta paintMeta) {
    paintControlWith(canvas, paintMeta);
  }

  @override
  void dispatchPointerEvent(PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        if (event.isPointerDown) {
          isFirstHandle = true;
          isControlApply = false;
          isPointerDownIn = false;
        }
      }
    }
    super.dispatchPointerEvent(event);
  }

  /// 当前手势是否在控制点上
  bool isPointerInBounds(PointerEvent event) =>
      controlBounds?.contains(event.localPosition) ?? false;

  @override
  bool interceptPointerEvent(PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        if (event.isPointerDown) {
          isPointerDownIn = isPointerInBounds(event);
          if (isPointerDownIn) {
            downScenePoint = canvasViewBox.toScenePoint(event.localPosition);
            canvasElementControlManager.canvasDelegate.refresh();
            return true;
          }
        }
      }
    }
    return super.interceptPointerEvent(event);
  }

  @override
  bool onPointerEvent(PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        return onFirstPointerEvent(event);
      }
    }
    return super.onPointerEvent(event);
  }

  @override
  bool onFirstPointerEvent(PointerEvent event) {
    if (isPointerDownIn) {
      if (event.isPointerUp && isPointerInBounds(event)) {
        onFirstPointerTap(event);
      }
      if (event.isPointerFinish) {
        isPointerDownIn = false;
        canvasElementControlManager.resetPaintInfoType();
        //canvasElementControlManager.canvasDelegate.refresh();
      }
    }
    return super.onFirstPointerEvent(event);
  }

  /// 第一个手指的点击事件回调
  @property
  void onFirstPointerTap(PointerEvent event) {}

  /// 重写此方法, 更新控制点的位置
  @overridePoint
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {}

  /// 在指定位置绘制控制点
  @callPoint
  void paintControlWith(Canvas canvas, PaintMeta paintMeta) {
    controlBounds?.let((rect) {
      canvas.drawCircle(
        rect.center,
        controlSize / 2,
        Paint()
          ..color = isPointerDownIn
              ? canvasStyle.controlBgColor.withOpacity(0.6)
              : canvasStyle.controlBgColor,
      );
      canvas.drawPictureRect(
        _pictureInfo?.picture,
        dst: rect.deflate(controlIcoPadding),
        pictureSize: _pictureInfo?.size,
        tintColor: Colors.white,
      );
    });
  }

  /// 获取左上控制点边界
  @viewCoordinate
  Rect getLTControlBounds(PaintProperty selectComponentProperty) {
    @sceneCoordinate
    final bounds = selectComponentProperty.paintScaleRect;
    @viewCoordinate
    final anchor = canvasViewBox.toViewPoint(bounds.center);
    @viewCoordinate
    Offset center = canvasViewBox.toViewPoint(bounds.lt);

    center += Offset(-controlSize / 2, -controlSize / 2) +
        Offset(-controlOffset, -controlOffset);

    final rotateMatrix = Matrix4.identity()
      ..rotateBy(selectComponentProperty.angle, anchor: anchor);
    center = rotateMatrix.mapPoint(center);

    return Rect.fromCircle(center: center, radius: controlSize / 2);
  }

  /// 获取右上控制点边界
  @viewCoordinate
  Rect getRTControlBounds(PaintProperty selectComponentProperty) {
    @sceneCoordinate
    final bounds = selectComponentProperty.paintScaleRect;
    @viewCoordinate
    final anchor = canvasViewBox.toViewPoint(bounds.center);
    @viewCoordinate
    Offset center = canvasViewBox.toViewPoint(bounds.rt);

    center += Offset(controlSize / 2, -controlSize / 2) +
        Offset(controlOffset, -controlOffset);

    final rotateMatrix = Matrix4.identity()
      ..rotateBy(selectComponentProperty.angle, anchor: anchor);
    center = rotateMatrix.mapPoint(center);

    return Rect.fromCircle(center: center, radius: controlSize / 2);
  }

  /// 获取右下控制点边界
  @viewCoordinate
  Rect getRBControlBounds(PaintProperty selectComponentProperty) {
    @sceneCoordinate
    final bounds = selectComponentProperty.paintScaleRect;
    @viewCoordinate
    final anchor = canvasViewBox.toViewPoint(bounds.center);
    @viewCoordinate
    Offset center = canvasViewBox.toViewPoint(bounds.rb);

    center += Offset(controlSize / 2, controlSize / 2) +
        Offset(controlOffset, controlOffset);

    final rotateMatrix = Matrix4.identity()
      ..rotateBy(selectComponentProperty.angle, anchor: anchor);
    center = rotateMatrix.mapPoint(center);

    return Rect.fromCircle(center: center, radius: controlSize / 2);
  }

  /// 获取左下控制点边界
  @viewCoordinate
  Rect getLBControlBounds(PaintProperty selectComponentProperty) {
    @sceneCoordinate
    final bounds = selectComponentProperty.paintScaleRect;
    @viewCoordinate
    final anchor = canvasViewBox.toViewPoint(bounds.center);
    @viewCoordinate
    Offset center = canvasViewBox.toViewPoint(bounds.lb);

    center += Offset(-controlSize / 2, controlSize / 2) +
        Offset(-controlOffset, controlOffset);

    final rotateMatrix = Matrix4.identity()
      ..rotateBy(selectComponentProperty.angle, anchor: anchor);
    center = rotateMatrix.mapPoint(center);

    return Rect.fromCircle(center: center, radius: controlSize / 2);
  }

  /// 加载控制点图片
  void loadControlPicture(String svgName,
      [void Function(PictureInfo)? onLoaded]) {
    loadAssetSvgPicture(
      'packages/flutter3_canvas/assets_canvas/svg/$svgName',
      prefix: null,
    ).then((value) async {
      /*final size = value.size;
      final base64 = await value.picture
          .toImageSync(size.width.round(), size.height.round())
          .toBase64();
      debugger();*/
      _pictureInfo = value;
      onLoaded?.call(value);
    });
  }

  //---

  @sceneCoordinate
  Offset downScenePoint = Offset.zero;

  /// 需要操作的目标元素
  ElementPainter? _targetElement;

  /// 存档
  ElementStateStack? _elementStateStack;

  /// 是否应用了控制
  bool isControlApply = false;

  /// 初始化控制的目标元素
  /// 开始控制目标元素
  void startControlTarget(ElementPainter? element) {
    _targetElement = element;
    _elementStateStack = element?.createStateStack();
  }

  /// 从按下的位置状态开始, 作用矩阵[matrix]
  /// [PaintProperty.applyMatrixWithAnchor]
  void applyTargetMatrixWithAnchor(Matrix4 matrix) {
    isControlApply = true;
    _elementStateStack?.restore();
    _targetElement?.applyMatrixWithAnchor(matrix);
  }

  /// 缩放时使用此方法
  /// [PaintProperty.applyMatrixWithCenter]
  void applyTargetMatrixWithCenter(Matrix4 matrix) {
    isControlApply = true;
    _elementStateStack?.restore();
    _targetElement?.applyMatrixWithCenter(matrix);
  }

  /// 结束控制, 并入回退栈
  @supportUndo
  void endControlTarget() {
    if (isControlApply) {
      if (_targetElement != null) {
        final old = _elementStateStack;
        final stateStack = _targetElement?.createStateStack();
        canvasElementControlManager.canvasDelegate.canvasUndoManager.addRunRedo(
          () {
            old?.restore();
          },
          () {
            stateStack?.restore();
          },
          false,
        );
      }
    }
  }
}

/// 删除元素控制
class DeleteControl extends BaseControl {
  DeleteControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_DELETE) {
    loadControlPicture('canvas_delete_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    controlBounds = getLTControlBounds(selectComponentProperty);
  }

  @override
  void onFirstPointerTap(PointerEvent event) {
    canvasElementControlManager.removeSelectedElement();
  }
}

/// 旋转元素控制
class RotateControl extends BaseControl {
  RotateControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_ROTATE) {
    loadControlPicture('canvas_rotate_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    controlBounds = getRTControlBounds(selectComponentProperty);
  }
}

/// 缩放元素控制
class ScaleControl extends BaseControl {
  ScaleControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_SCALE) {
    loadControlPicture('canvas_scale_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    controlBounds = getRBControlBounds(selectComponentProperty);
  }
}

/// 锁定等比元素控制
class LockControl extends BaseControl {
  /// 是否锁定了宽高比
  bool _isLock = true;

  bool get isLock => _isLock;

  set isLock(bool value) {
    _isLock = value;
    if (value) {
      _pictureInfo = _lockPictureInfo;
    } else {
      _pictureInfo = _unlockPictureInfo;
    }
    canvasElementControlManager.canvasDelegate.refresh();
  }

  PictureInfo? _lockPictureInfo;
  PictureInfo? _unlockPictureInfo;

  LockControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_LOCK) {
    loadControlPicture('canvas_lock_point.svg', (value) {
      _lockPictureInfo = value;
      if (isLock) {
        _pictureInfo = value;
      }
    });
    loadControlPicture('canvas_unlock_point.svg', (value) {
      _unlockPictureInfo = value;
      if (!isLock) {
        _pictureInfo = value;
      }
    });
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    controlBounds = getLBControlBounds(selectComponentProperty);
  }

  @override
  void onFirstPointerTap(PointerEvent event) {
    isLock = !isLock;
    canvasElementControlManager.elementSelectComponent.isLockRatio = isLock;
    canvasElementControlManager.canvasDelegate.refresh();
  }
}

/// 平移元素控制
class TranslateControl extends BaseControl with DoubleTapDetectorMixin {
  TranslateControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_TRANSLATE);

  @override
  bool interceptPointerEvent(PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        if (event.isPointerDown) {
          downScenePoint = canvasViewBox.toScenePoint(event.localPosition);
          if (canvasElementControlManager.elementSelectComponent
              .hitTest(point: downScenePoint)) {
            //需要拖动选中的元素
            isPointerDownIn = true;
            startControlTarget(
                canvasElementControlManager.elementSelectComponent);
            canvasElementControlManager.updatePointerDownElement(
                canvasElementControlManager.elementSelectComponent);
            return true;
          } else {
            final downElementList = canvasElementControlManager
                .canvasElementManager
                .findElement(point: downScenePoint);
            final downElement = downElementList.lastOrNull;
            if (downElement != null) {
              //按在指定的元素上
              isPointerDownIn = true;
              canvasElementControlManager.canvasElementManager
                  .resetSelectElement(downElement.ofList());
              startControlTarget(
                  canvasElementControlManager.elementSelectComponent);
              canvasElementControlManager.updatePointerDownElement(
                  canvasElementControlManager.elementSelectComponent);
              return true;
            }
          }
        }
      }
    }
    return super.interceptPointerEvent(event);
  }

  @override
  bool onFirstPointerEvent(PointerEvent event) {
    //l.d('$event');
    //debugger();
    if (isPointerDownIn) {
      addDoubleTapDetectorPointerEvent(event);
      if (event.isPointerMove) {
        if (isFirstHandle) {
          if (firstDownEvent?.isMoveExceed(event.localPosition) == true) {
            //首次移动, 并且超过了阈值
            isFirstHandle = false;
            canvasElementControlManager
                .updatePaintInfoType(PaintInfoType.location);
          }
        }
        if (!isFirstHandle) {
          final moveScenePoint =
              canvasViewBox.toScenePoint(event.localPosition);
          final matrix = Matrix4.identity()
            ..translateTo(offset: moveScenePoint - downScenePoint);
          applyTargetMatrixWithAnchor(matrix);
          //debugger();
        }
      } else if (event.isPointerFinish) {
        canvasElementControlManager.updatePointerDownElement(null);
        if (isControlApply) {
          endControlTarget();
        }
      }
    }
    super.onFirstPointerEvent(event);
    return true;
  }

  @override
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) {
    _targetElement?.let((it) => canvasElementControlManager.canvasDelegate
        .dispatchDoubleTapElement(it));
    return true;
  }
}
