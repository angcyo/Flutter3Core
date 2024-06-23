part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/05
///
/// 元素控制
class BaseControl with CanvasComponentMixin, IHandleEventMixin {
  /// 控制点: 删除
  /// [DeleteControl]
  static const sControlTypeDelete = 1;

  /// 控制点: 旋转
  /// [RotateControl]
  static const sControlTypeRotate = 2;

  /// 控制点: 缩放
  /// [ScaleControl]
  static const sControlTypeScale = 3;

  /// 控制点: 锁定等比
  /// [LockControl]
  static const sControlTypeLock = 4;

  /// 控制行为: 平移
  /// [TranslateControl]
  static const sControlTypeTranslate = 5;

  /// 控制行为: 宽度调整
  static const sControlTypeWidth = 6;

  /// 控制行为: 高度调整
  static const sControlTypeHeight = 7;

  final CanvasElementControlManager canvasElementControlManager;

  /// 控制点的类型
  /// [sControlTypeDelete]
  /// [sControlTypeRotate]
  /// [sControlTypeScale]
  /// [sControlTypeLock]
  /// [sControlTypeTranslate]
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
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    super.dispatchPointerEvent(dispatch, event);
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(dispatch, event)) {
        if (event.isPointerDown) {
          isFirstHandle = true;
          isControlApply = false;
          isPointerDownIn = false;
        } else if (event.isPointerFinish) {}
      }
    }
  }

  /// 当前手势是否在控制点上
  bool isPointerInBounds(PointerEvent event) =>
      controlBounds?.contains(event.localPosition) ?? false;

  @override
  bool interceptPointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(dispatch, event)) {
        if (event.isPointerDown && controlBounds != null) {
          isPointerDownIn = isPointerInBounds(event);
          if (isPointerDownIn) {
            onSelfFirstPointerDown(event);
            return true;
          }
        }
      }
    }
    return super.interceptPointerEvent(dispatch, event);
  }

  /// 第一个手势在当前控制点上按下时回调
  void onSelfFirstPointerDown(PointerEvent event) {
    downScenePoint = canvasViewBox.toScenePoint(event.localPosition);
    canvasElementControlManager.canvasDelegate.refresh();
  }

  @override
  bool onPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(dispatch, event)) {
        return onFirstPointerEvent(dispatch, event);
      }
    }
    return super.onPointerEvent(dispatch, event);
  }

  @override
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
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
    return super.onFirstPointerEvent(dispatch, event);
  }

  /// 第一个手指的点击事件回调
  @property
  void onFirstPointerTap(PointerEvent event) {}

  /// 重写此方法, 更新控制点的位置
  @overridePoint
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    if (controlType == sControlTypeDelete) {
      controlBounds = getLTControlBounds(selectComponentProperty);
    } else if (controlType == sControlTypeRotate) {
      controlBounds = getRTControlBounds(selectComponentProperty);
    } else if (controlType == sControlTypeScale) {
      controlBounds = getRBControlBounds(selectComponentProperty);
    } else if (controlType == sControlTypeLock) {
      controlBounds = getLBControlBounds(selectComponentProperty);
    }
  }

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
      //debugger();
      canvas.drawPictureInRect(
        _pictureInfo?.picture,
        dst: rect.deflate(controlIcoPadding),
        pictureSize: _pictureInfo?.size,
        tintColor: Colors.white,
        dstPadding: EdgeInsets.all(controlIcoPadding),
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
      'packages/flutter3_canvas/assets/svg/$svgName',
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

  /// 按下时, 手指在场景中的坐标
  @sceneCoordinate
  Offset downScenePoint = Offset.zero;

  /// 按下时, 目标元素的中心点坐标
  @sceneCoordinate
  Offset? _downTargetElementCenter;

  /// 按下时, 目标元素的操作锚点坐标
  @sceneCoordinate
  Offset? _downTargetElementAnchor;

  /// 需要操作的目标元素
  ElementPainter? _targetElement;

  /// 存档
  ElementStateStack? _elementStateStack;

  /// 是否应用了控制
  /// [endControlTarget] 后重置
  bool isControlApply = false;

  /// 初始化控制的目标元素
  /// 开始控制目标元素
  @callPoint
  void startControlTarget(ElementPainter? element) {
    _downTargetElementCenter = element?.paintProperty?.paintCenter;
    _downTargetElementAnchor =
        element?.paintProperty?.let((it) => Offset(it.left, it.top));
    _targetElement = element;
    _elementStateStack = element?.createStateStack();

    canvasElementControlManager.onSelfControlStateChanged(
      state: ControlState.start,
      control: this,
      controlElement: _targetElement,
    );
  }

  /// 从按下的位置状态开始, 作用矩阵[matrix]
  /// [PaintProperty.applyScaleWithAnchor]
  @callPoint
  void applyTargetMatrix(Matrix4 matrix, [int? controlType]) {
    isControlApply = true;
    _elementStateStack?.restore();

    controlType ??= this.controlType;
    if (_targetElement == null) {
      assert(() {
        l.d('无目标控制元素[$controlType]');
        return true;
      }());
    } else if (controlType == BaseControl.sControlTypeRotate) {
      _targetElement?.rotateElement(matrix);
    } else if (controlType == BaseControl.sControlTypeTranslate) {
      _targetElement?.translateElement(matrix);
    } else {
      assert(() {
        l.d('未适配的控制操作[$controlType]');
        return true;
      }());
    }
  }

  /// 缩放时使用此方法
  /// [applyTargetMatrix]
  /// [PaintProperty.applyScaleWithCenter]
  @callPoint
  void applyScaleMatrix({double sx = 1, double sy = 1, Offset? anchor}) {
    isControlApply = true;
    _elementStateStack?.restore();
    final element = _targetElement;
    if (element is ElementSelectComponent) {
      element.scaleElement(sx: sx, sy: sy, anchor: anchor);
    } else {
      final matrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchor);
      element?.scaleElementWithCenter(matrix);
    }
  }

  /// 结束控制, 并入回退栈
  @callPoint
  @supportUndo
  void endControlTarget() {
    canvasElementControlManager.onSelfControlStateChanged(
      state: ControlState.end,
      control: this,
      controlElement: _targetElement,
    );
    _downTargetElementCenter = null;
    _downTargetElementAnchor = null;
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
    isControlApply = false;
  }

  /// 反向旋转场景中的点坐标
  /// 默认情况下, 旋转场景中的点坐标可能是旋转之后的坐标. 此时反向旋转可以获取旋转之前的点坐标.
  /// 此方法通常在计算缩放比例时使用
  /// [point] 需要反转的点
  /// [center] 旋转锚点
  /// [angle].[point]当前旋转的角度, 弧度
  Offset? reverseRotateScenePoint(Offset? point,
      [Offset? center, double? angle]) {
    if (point == null) {
      return null;
    }
    center ??= _downTargetElementCenter;
    angle ??= _targetElement?.paintProperty?.angle;
    if (center == null) {
      return point;
    }
    if (angle == null) {
      return point;
    }
    if (angle % (2 * pi) == 0) {
      return point;
    }
    final matrix = Matrix4.identity()..rotateBy(angle, anchor: center);
    return matrix.invertMatrix().mapPoint(point);
  }
}

/// 删除元素控制
class DeleteControl extends BaseControl {
  DeleteControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.sControlTypeDelete) {
    loadControlPicture('canvas_delete_point.svg');
  }

  @override
  void onFirstPointerTap(PointerEvent event) {
    canvasElementControlManager.removeSelectedElement();
  }
}

/// 旋转元素控制
class RotateControl extends BaseControl {
  RotateControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.sControlTypeRotate) {
    loadControlPicture('canvas_rotate_point.svg');
  }

  @override
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    //l.d('$event');
    //debugger();
    if (isPointerDownIn) {
      if (event.isPointerDown) {
        //按下时, 就更新绘制的控制信息
        canvasElementControlManager.updatePaintInfoType(PaintInfoType.rotate);
      } else if (event.isPointerMove) {
        if (isFirstHandle) {
          if (firstDownEvent?.isMoveExceed(event.localPosition) == true) {
            //首次移动, 并且超过了阈值
            isFirstHandle = false;
            startControlTarget(
                canvasElementControlManager.elementSelectComponent);
          }
        }
        if (!isFirstHandle) {
          final moveScenePoint =
              canvasViewBox.toScenePoint(event.localPosition);
          _downTargetElementCenter?.let((it) {
            final angle = angleBetween(it, downScenePoint, it, moveScenePoint);
            final matrix = Matrix4.identity()..rotateBy(angle, anchor: it);
            assert(() {
              //l.d('旋转元素[${angle.jd}]:$angle $it');
              return true;
            }());
            applyTargetMatrix(matrix);
            //debugger();
          });
        }
      } else if (event.isPointerFinish) {
        endControlTarget();
      }
    }
    super.onFirstPointerEvent(dispatch, event);
    return true;
  }
}

/// 缩放元素控制
class ScaleControl extends BaseControl {
  ScaleControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.sControlTypeScale) {
    loadControlPicture('canvas_scale_point.svg');
  }

  bool get _isLockRatio =>
      canvasElementControlManager.elementSelectComponent.isLockRatio;

  @sceneCoordinate
  Offset _downScenePointInvert = Offset.zero;

  @sceneCoordinate
  Offset? _downTargetElementAnchorInvert;

  /// 如果元素很小时, 则进行放大操作需要额外的放大倍数
  @dp
  final double _scaleSizeThreshold = 10;

  /// 额外放大的倍数
  final double _scaleFactor = 100;

  Rect? _downTargetElementBounds;

  @override
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    if (isPointerDownIn) {
      if (event.isPointerMove) {
        if (isFirstHandle) {
          if (firstDownEvent?.isMoveExceed(event.localPosition) == true) {
            //首次移动, 并且超过了阈值
            isFirstHandle = false;
            startControlTarget(
                canvasElementControlManager.elementSelectComponent);
            _downScenePointInvert = reverseRotateScenePoint(downScenePoint)!;
            _downTargetElementAnchorInvert =
                reverseRotateScenePoint(_downTargetElementAnchor);
            _downTargetElementBounds = canvasElementControlManager
                .elementSelectComponent.paintProperty?.paintBounds;
          }
        }
        if (!isFirstHandle) {
          final moveScenePoint =
              canvasViewBox.toScenePoint(event.localPosition);
          final moveScenePointInvert = reverseRotateScenePoint(moveScenePoint)!;

          //需要计算的缩放比例
          double sx = 1;
          double sy = 1;

          if (_downTargetElementAnchorInvert != null) {
            final anchorInvert = _downTargetElementAnchorInvert!;
            if (_isLockRatio) {
              //等比缩放
              final oldC = distance(anchorInvert, _downScenePointInvert);
              final newC = distance(anchorInvert, moveScenePointInvert);

              final scale = newC / oldC;
              sx = scale;
              sy = scale;

              /*_downTargetElementBounds?.let((it) {
                if (it.width <= _scaleSizeThreshold ||
                    it.height <= _scaleSizeThreshold) {
                  if (scale > 1) {
                    sx *= _scaleFactor;
                    sy *= _scaleFactor;
                  }
                }
              });*/
            } else {
              //自由缩放
              final oldWidth = anchorInvert.dx - _downScenePointInvert.dx;
              final newWidth = anchorInvert.dx - moveScenePointInvert.dx;

              final oldHeight = anchorInvert.dy - _downScenePointInvert.dy;
              final newHeight = anchorInvert.dy - moveScenePointInvert.dy;

              sx = newWidth / oldWidth;
              sy = newHeight / oldHeight;

              /*_downTargetElementBounds?.let((it) {
                if (it.width <= _scaleSizeThreshold) {
                  if (sx > 1) {
                    sx *= _scaleFactor;
                  }
                }

                if (it.height <= _scaleSizeThreshold) {
                  if (sy > 1) {
                    sy *= _scaleFactor;
                  }
                }
              });*/
            }
            //debugger();

            if (sx > 0 && sy > 0) {
              /*assert(() {
                l.d('缩放元素: sx:$sx sy:$sy anchor:$_downTargetElementAnchor');
                return true;
              }());*/
              applyScaleMatrix(
                sx: sx,
                sy: sy,
                anchor: _downTargetElementAnchor!,
              );
            } else {
              assert(() {
                l.w('缩放比例异常(负数): sx:$sx sy:$sy');
                return true;
              }());
            }
          } else {
            assert(() {
              l.w('缩放操作锚点为空, 不应该出现此情况!');
              return true;
            }());
          }
        }
      } else if (event.isPointerFinish) {
        endControlTarget();
      }
    }
    super.onFirstPointerEvent(dispatch, event);
    return true;
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
      : super(canvasElementControlManager, BaseControl.sControlTypeLock) {
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
  void onFirstPointerTap(PointerEvent event) {
    isLock = !isLock;
    canvasElementControlManager.elementSelectComponent.isLockRatio = isLock;
    canvasElementControlManager.canvasDelegate.refresh();
  }
}

/// 平移元素控制
class TranslateControl extends BaseControl with DoubleTapDetectorMixin {
  TranslateControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.sControlTypeTranslate);

  @override
  bool interceptPointerEvent(
      PointerDispatchMixin dispatch, PointerEvent event) {
    //l.d('...2...${dispatch.pointerCount}');
    //debugger();
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(dispatch, event)) {
        final selectComponent =
            canvasElementControlManager.elementSelectComponent;
        if (event.isPointerDown) {
          downScenePoint = canvasViewBox.toScenePoint(event.localPosition);
          if (selectComponent.hitTest(point: downScenePoint)) {
            //在选择器上按下, 则是需要拖动选中的元素
            //debugger();
            isPointerDownIn = true;
            isFirstHandle = true;
            canvasElementControlManager
                .updatePaintInfoType(PaintInfoType.location);
            //在元素上点击, 就需要拦截事件, 因为还有双击操作
            startControlTarget(selectComponent);
            return true;
          } else {
            //在选择器外按下, 可能是需要拖动其他元素
            final downElementList = canvasElementControlManager
                .canvasElementManager
                .findElement(point: downScenePoint);
            final downElement = downElementList.lastOrNull;
            if (downElement != null) {
              //按在指定的元素上
              isPointerDownIn = true;
              canvasElementControlManager.canvasElementManager
                  .resetSelectElement(downElement.ofList());
              startControlTarget(selectComponent);
              return true;
            }
          }
        } else if (event.isPointerMove) {
          //debugger();
          if (isPointerDownIn) {
            if (isFirstHandle && dispatch.pointerCount <= 1) {
              if (firstDownEvent?.isMoveExceed(event.localPosition) == true) {
                //首次移动, 并且超过了阈值
                isFirstHandle = false;
                startControlTarget(selectComponent);
                return true;
              }
            }
          }
        }
      }
    }
    return super.interceptPointerEvent(dispatch, event);
  }

  @override
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    //l.d('...1...${dispatch.pointerCount}');
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
        //debugger();
        if (!isFirstHandle && dispatch.pointerCount <= 1) {
          final moveScenePoint =
              canvasViewBox.toScenePoint(event.localPosition);
          final offset = moveScenePoint - downScenePoint;
          final matrix = Matrix4.identity()..translateTo(offset: offset);
          assert(() {
            //l.d('平移元素[${dispatch.pointerCount}]: offset:$offset');
            return true;
          }());
          applyTargetMatrix(matrix);
          //debugger();
        }
      } else if (event.isPointerFinish) {
        endControlTarget();
      }
    }
    super.onFirstPointerEvent(dispatch, event);
    return true;
  }

  @override
  bool onDoubleTapDetectorPointerEvent(PointerEvent event) {
    //debugger();
    _targetElement?.let((it) => canvasElementControlManager.canvasDelegate
        .dispatchDoubleTapElement(it));
    return true;
  }
}

/// 控制状态
enum ControlState {
  /// 开始控制
  start,

  /// 结束控制
  end,
}
