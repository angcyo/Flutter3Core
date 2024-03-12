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

  final CanvasElementControlManager canvasElementControlManager;

  /// 控制点的类型
  final int controlType;

  /// 控制点的位置, 视图坐标系
  @viewCoordinate
  Rect? controlBounds;

  /// 手势是否在控制点上按下
  bool isPointerDownIn = false;

  /// 控制点绘制的大小
  @dp
  double controlSize = 24;

  /// 距离目标的偏移量
  @dp
  double controlOffset = -4;

  /// 绘制控制点图片额外的内边距
  @dp
  double controlIcoPadding = 4;

  /// 控制点的图片信息
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
  bool interceptPointerEvent(PointerEvent event) {
    if (isCanvasComponentEnable) {
      if (isFirstPointerEvent(event)) {
        if (event.isPointerDown) {
          isPointerDownIn =
              controlBounds?.contains(event.localPosition) ?? false;
          if (isPointerDownIn) {
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
        l.d('$event');
        return true;
      }
    }
    return super.onPointerEvent(event);
  }

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
  void loadControlPicture(String svgName) {
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
    });
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
  LockControl(CanvasElementControlManager canvasElementControlManager)
      : super(canvasElementControlManager, BaseControl.CONTROL_TYPE_LOCK) {
    loadControlPicture('canvas_lock_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    controlBounds = getLBControlBounds(selectComponentProperty);
  }
}
