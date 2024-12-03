part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/05
///

/// 控制点枚举类型
enum ControlTypeEnum {
  /// 控制点: 删除
  /// [DeleteControl]
  delete,

  /// 控制点: 旋转
  /// [RotateControl]
  rotate,

  /// 控制点: 缩放
  /// [ScaleControl]
  scale,

  /// 控制点: 锁定等比
  /// [LockControl]
  lock,

  /// 控制行为: 平移
  /// [TranslateControl]
  translate,

  /// 控制行为: 宽度调整
  width,

  /// 控制行为: 高度调整
  height,

  /// 控制行为: 显示菜单
  menu,
}

/// [CanvasElementControlManager]
mixin CanvasElementControlManagerMixin {
  /// 画布元素控制器
  CanvasElementControlManager get canvasElementControlManager;

  CanvasDelegate get canvasDelegate =>
      canvasElementControlManager.canvasDelegate;

  CanvasElementManager get canvasElementManager =>
      canvasDelegate.canvasElementManager;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  IUnit get axisUnit => canvasDelegate.axisUnit;
}

/// 选中元素的控制点
/// 由[CanvasElementControlManager]管理所有控制点
class BaseControl
    with
        CanvasComponentMixin,
        IHandleEventMixin,
        CanvasElementControlManagerMixin {
  @override
  final CanvasElementControlManager canvasElementControlManager;

  /// 控制点的类型
  /// [ControlTypeEnum]
  final ControlTypeEnum controlType;

  /// 控制点的位置, 视图坐标系
  @viewCoordinate
  Rect? controlBounds;

  /// 控制点的内边距[controlBounds]用来撑大点击区域
  @viewCoordinate
  EdgeInsets? controlPadding;

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

  //--

  /// 绘制控制点图片额外的内边距
  @dp
  double controlIcoPadding = 4;

  /// 控制点的图片信息, 用来绘制控制点图标
  /// [paintControl]->[paintControlWith]
  PictureInfo? _pictureInfo;

  /// 控制点接管绘制对象
  IControlPainter? controlPainter;

  /// 控制点接管绘制方法
  ControlPainterFn? controlPainterFn;

  BaseControl(this.canvasElementControlManager, this.controlType);

  @entryPoint
  void paintControl(Canvas canvas, PaintMeta paintMeta) {
    if (controlPainter != null || controlPainterFn != null) {
      controlBounds?.let((rect) {
        rect = rect.padding(controlPadding);
        controlPainter?.painting(canvas, rect, isPointerDownIn);
        controlPainterFn?.call(canvas, rect, isPointerDownIn);
      });
    } else {
      paintControlWith(canvas, paintMeta);
    }
    /*if (isDebug && controlBounds != null) {
      canvas.drawRect(
        controlBounds!,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = canvasDelegate.canvasStyle.canvasAccentColor,
      );
    }*/
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
    if (controlType == ControlTypeEnum.delete) {
      controlBounds = getLTControlBounds(selectComponentProperty);
    } else if (controlType == ControlTypeEnum.rotate) {
      controlBounds = getRTControlBounds(selectComponentProperty);
    } else if (controlType == ControlTypeEnum.scale) {
      controlBounds = getRBControlBounds(selectComponentProperty);
    } else if (controlType == ControlTypeEnum.lock) {
      controlBounds = getLBControlBounds(selectComponentProperty);
    }
  }

  /// 在指定位置绘制控制点
  @callPoint
  void paintControlWith(Canvas canvas, PaintMeta paintMeta) {
    controlBounds?.let((rect) {
      rect = rect.padding(controlPadding);
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

    return Rect.fromCircle(center: center, radius: controlSize / 2)
        .expand(controlPadding);
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

    return Rect.fromCircle(center: center, radius: controlSize / 2)
        .expand(controlPadding);
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

    return Rect.fromCircle(center: center, radius: controlSize / 2)
        .expand(controlPadding);
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

    return Rect.fromCircle(center: center, radius: controlSize / 2)
        .expand(controlPadding);
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

  /// 存档, 用于控制后的恢复
  /// [endControlTarget]
  ElementStateStack? _elementStateStack;

  /// 是否应用了控制
  /// [endControlTarget] 后重置
  bool isControlApply = false;

  /// 初始化控制的目标元素
  /// 开始控制目标元素
  @callPoint
  void startControlTarget(ElementPainter? element) {
    _setControlTarget(element, ControlState.start);
  }

  /// 更新控制的目标元素, 多指选择元素之后调用
  @callPoint
  void updateControlTarget(ElementPainter? element) {
    _setControlTarget(element, ControlState.update);
  }

  /// 设置控制目标
  void _setControlTarget(ElementPainter? element, ControlState state) {
    _elementStateStack?.dispose();
    _downTargetElementCenter = element?.paintProperty?.paintCenter;
    _downTargetElementAnchor =
        element?.paintProperty?.let((it) => Offset(it.left, it.top));
    _targetElement = element;
    _elementStateStack = element?.createStateStack();

    canvasElementControlManager.onSelfControlStateChanged(
      state: state,
      control: this,
      controlElement: element,
    );
  }

  /// 从按下的位置状态开始, 作用矩阵[matrix]
  /// [PaintProperty.applyScaleWithAnchor]
  @callPoint
  void applyTargetMatrix(Matrix4 matrix, [ControlTypeEnum? controlType]) {
    //debugger();
    isControlApply = true;
    _elementStateStack?.restore();

    controlType ??= this.controlType;
    if (_targetElement == null) {
      assert(() {
        l.d('无目标控制元素[$controlType]');
        return true;
      }());
    } else if (controlType == ControlTypeEnum.rotate) {
      _targetElement?.rotateElement(matrix, fromObj: this);
    } else if (controlType == ControlTypeEnum.translate) {
      _targetElement?.translateElement(matrix, fromObj: this);
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
      element.scaleElement(sx: sx, sy: sy, anchor: anchor, fromObj: this);
    } else {
      final matrix = Matrix4.identity()
        ..scaleBy(sx: sx, sy: sy, anchor: anchor);
      element?.scaleElementWithCenter(matrix, fromObj: this);
    }
  }

  /// 结束控制, 并入回退栈
  @callPoint
  @supportUndo
  void endControlTarget() {
    final element = _targetElement;

    canvasElementControlManager.onSelfControlStateChanged(
      state: ControlState.end,
      control: this,
      controlElement: element,
    );
    _downTargetElementCenter = null;
    _downTargetElementAnchor = null;
    if (isControlApply) {
      if (element != null) {
        // 回退状态
        final old = _elementStateStack;
        _elementStateStack = null; //清空状态栈, 防止被清楚
        final stateStack = element.createStateStack();
        canvasElementControlManager.canvasDelegate.canvasUndoManager.addRunRedo(
          () {
            old?.restore();
          },
          () {
            stateStack.restore();
          },
          false,
        );
      }
    } else {
      //释放
      _elementStateStack?.dispose();
      _elementStateStack = null;
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
      : super(canvasElementControlManager, ControlTypeEnum.delete) {
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
      : super(canvasElementControlManager, ControlTypeEnum.rotate) {
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
      : super(canvasElementControlManager, ControlTypeEnum.scale) {
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
      : super(canvasElementControlManager, ControlTypeEnum.lock) {
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
      : super(canvasElementControlManager, ControlTypeEnum.translate);

  //--

  /// 是否激活组件事件处理
  @override
  bool get enableEventHandled =>
      canvasElementControlManager.elementSelectComponent.enableEventHandled;

  //--

  /// 是否在选择器上重复按下?
  bool _isDownSelectComponent = false;

  /// 按下时, 选中的元素列表
  /// [TranslateControl._downElementList]
  /// [ElementSelectComponent._downElementList]
  List<ElementPainter>? _downElementList;

  @override
  void dispatchPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    super.dispatchPointerEvent(dispatch, event);
    if (event.isPointerDown || event.isPointerCancel) {
      _isDownSelectComponent = false;
      _downElementList = null;
    }
  }

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
          _isFirstTranslate = true;
          downScenePoint = canvasViewBox.toScenePoint(event.localPosition);

          final downElementList = canvasElementControlManager
              .canvasElementManager
              .findElement(point: downScenePoint);
          _downElementList = downElementList;

          /*assert(() {
            l.w("按下[${downElementList.length}]个元素->${downElementList.firstOrNull?.classHash()}:${downElementList.firstOrNull}");
            return true;
          }());*/

          if (selectComponent.children != null &&
              selectComponent.hitTest(point: downScenePoint)) {
            //在选择器上按下
            isPointerDownIn = true;
            isFirstHandle = true;
            _isDownSelectComponent = true;
            canvasElementControlManager
                .updatePaintInfoType(PaintInfoType.location);
            //在元素上点击, 就需要拦截事件, 因为还有双击操作
            startControlTarget(selectComponent);
            return true;
          } else {
            //在选择器外按下, 可能是需要拖动手指下的元素
            final downElement = downElementList.lastOrNull;
            _isDownSelectComponent = false;
            if (downElement != null) {
              //按在指定的元素上
              isPointerDownIn = true;
              canvasElementControlManager.canvasElementManager
                  .resetSelectedElementList(downElement.ofList());
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

  /// 是否是首次移动元素
  bool _isFirstTranslate = false;

  @override
  bool onFirstPointerEvent(PointerDispatchMixin dispatch, PointerEvent event) {
    //l.d('...1...${dispatch.pointerCount}');
    //debugger();
    if (isPointerDownIn) {
      addDoubleTapDetectorPointerEvent(event);
      if (event.isPointerMove) {
        var localPosition = event.localPosition;
        if (isFirstHandle) {
          if (firstDownEvent?.isMoveExceed(localPosition) == true) {
            //首次移动, 并且超过了阈值
            isFirstHandle = false;
            canvasElementControlManager
                .updatePaintInfoType(PaintInfoType.location);
          }
        }
        //debugger();
        if (!isFirstHandle && dispatch.pointerCount <= 1) {
          final moveScenePoint = canvasViewBox.toScenePoint(localPosition);

          @sceneCoordinate
          Offset offset = moveScenePoint - downScenePoint;

          final elementAdsorbControl = canvasDelegate.canvasElementManager
              .canvasElementControlManager.elementAdsorbControl;
          if (elementAdsorbControl.isCanvasComponentEnable) {
            final xAdsorbValue =
                elementAdsorbControl.findElementXAdsorbRefValue(
              _targetElement,
              localPosition,
              offset.dx,
              firstMoveOffset.dx,
            );
            final yAdsorbValue =
                elementAdsorbControl.findElementYAdsorbRefValue(
              _targetElement,
              localPosition,
              offset.dy,
              firstMoveOffset.dy,
            );

            offset = Offset(xAdsorbValue?.adsorbValue ?? offset.dx,
                yAdsorbValue?.adsorbValue ?? offset.dy);

            /*double dx = offset.dx;
            double dy = offset.dy;
            if (xAdsorbValue != null) {
              dx = xAdsorbValue.refValue - downScenePoint.dx;
            }
            if (yAdsorbValue != null) {
              dy = yAdsorbValue.refValue - downScenePoint.dy;
            }

            offset = Offset(dx, dy);*/
          }

          final matrix = Matrix4.identity()..translateTo(offset: offset);
          assert(() {
            //l.d('平移元素[${dispatch.pointerCount}]: offset:$offset');
            return true;
          }());
          applyTargetMatrix(matrix);
          canvasDelegate.dispatchTranslateElement(
            _targetElement,
            _isFirstTranslate,
            false,
          );
          _isFirstTranslate = false;
          //debugger();
        }
      } else if (event.isPointerFinish) {
        endControlTarget();
        //debugger();
        if (!_isFirstTranslate) {
          //移动过
          canvasDelegate.dispatchTranslateElement(
            _targetElement,
            _isFirstTranslate,
            true,
          );
        }
        _isFirstTranslate = false;
        if (isFirstHandle && (_downElementList?.size() ?? 0) > 1) {
          //多个元素被选中的回调, 按下多个元素
          canvasDelegate.dispatchCanvasSelectElementList(
            canvasElementControlManager.elementSelectComponent,
            _downElementList!,
            ElementSelectType.pointer,
          );
        }
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

/// 控制点绘制接口
/// [Canvas]
abstract class IControlPainter with Diagnosticable {
  /// 调试时用得的标签
  String? debugLabel;

  /// 绘制入口
  @entryPoint
  void painting(Canvas canvas, @viewCoordinate Rect bounds, bool downIn);
}

/// [IControlPainter]
typedef ControlPainterFn = void Function(
    Canvas canvas, @viewCoordinate Rect bounds, bool downIn);

/// 控制状态
enum ControlState {
  /// 开始控制
  start,

  /// 更新控制, 比如多指选择了更多的元素
  update,

  /// 结束控制
  end,
}
