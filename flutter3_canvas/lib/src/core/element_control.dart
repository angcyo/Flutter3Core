part of flutter3_canvas;

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

  final CanvasElementManager canvasElementManager;

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
  double controlOffset = 10;

  /// 绘制控制点图片额外的内边距
  @dp
  double controlIcoPadding = 4;

  /// 控制点的图片信息
  PictureInfo? _pictureInfo;

  //---

  CanvasStyle get canvasStyle =>
      canvasElementManager.canvasDelegate.canvasStyle;

  CanvasViewBox get canvasViewBox =>
      canvasElementManager.canvasDelegate.canvasViewBox;

  BaseControl(this.canvasElementManager, this.controlType);

  @entryPoint
  void paintControl(Canvas canvas, PaintMeta paintMeta) {
    paintControlWith(canvas, paintMeta);
  }

  /// 更新控制点的位置
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

  /// 获取控制主体边界4个点位置坐标(场景中的坐标)
  @sceneCoordinate
  List<Offset> getControlSubjectBounds(PaintProperty selectComponentProperty) {
    final result = <Offset>[];
    selectComponentProperty.let((it) {
      final bounds = it.scaleRect;
      final matrix = Matrix4.identity()..rotateBy(it.angle);
      result.add(matrix.mapPoint(bounds.lt));
      result.add(matrix.mapPoint(bounds.rt));
      result.add(matrix.mapPoint(bounds.rb));
      result.add(matrix.mapPoint(bounds.lb));
    });
    return result;
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
  DeleteControl(CanvasElementManager canvasElementManager)
      : super(canvasElementManager, BaseControl.CONTROL_TYPE_DELETE) {
    loadControlPicture('canvas_delete_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    getControlSubjectBounds(selectComponentProperty)[0].let((point) {
      point = canvasViewBox.toViewPoint(point);
      point += Offset(-controlOffset, -controlOffset);
      @viewCoordinate
      final rect = Rect.fromCircle(center: point, radius: controlSize / 2);
      controlBounds = rect;
    });
  }
}

/// 旋转元素控制
class RotateControl extends BaseControl {
  RotateControl(CanvasElementManager canvasElementManager)
      : super(canvasElementManager, BaseControl.CONTROL_TYPE_ROTATE) {
    loadControlPicture('canvas_rotate_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    getControlSubjectBounds(selectComponentProperty)[1].let((point) {
      point = canvasViewBox.toViewPoint(point);
      point += Offset(controlOffset, -controlOffset);
      @viewCoordinate
      final rect = Rect.fromCircle(center: point, radius: controlSize / 2);
      controlBounds = rect;
    });
  }
}

/// 缩放元素控制
class ScaleControl extends BaseControl {
  ScaleControl(CanvasElementManager canvasElementManager)
      : super(canvasElementManager, BaseControl.CONTROL_TYPE_SCALE) {
    loadControlPicture('canvas_scale_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    getControlSubjectBounds(selectComponentProperty)[2].let((point) {
      point = canvasViewBox.toViewPoint(point);
      point += Offset(controlOffset, controlOffset);
      @viewCoordinate
      final rect = Rect.fromCircle(center: point, radius: controlSize / 2);
      controlBounds = rect;
    });
  }
}

/// 锁定等比元素控制
class LockControl extends BaseControl {
  LockControl(CanvasElementManager canvasElementManager)
      : super(canvasElementManager, BaseControl.CONTROL_TYPE_LOCK) {
    loadControlPicture('canvas_lock_point.svg');
  }

  @override
  void updatePaintControlBounds(PaintProperty selectComponentProperty) {
    getControlSubjectBounds(selectComponentProperty)[3].let((point) {
      point = canvasViewBox.toViewPoint(point);
      point += Offset(-controlOffset, controlOffset);
      @viewCoordinate
      final rect = Rect.fromCircle(center: point, radius: controlSize / 2);
      controlBounds = rect;
    });
  }
}
