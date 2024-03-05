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

  /// 控制点绘制的大小
  @dp
  double controlSize = 25;

  /// 距离目标的偏移量
  @dp
  double controlOffset = 10;

  CanvasViewBox get canvasViewBox =>
      canvasElementManager.canvasDelegate.canvasViewBox;

  BaseControl(this.canvasElementManager, this.controlType) {}

  @entryPoint
  void paintControl(Canvas canvas, PaintMeta paintMeta) {}

  /// 获取控制主体边界4个点位置坐标(场景中的坐标)
  @sceneCoordinate
  List<Offset> getControlSubjectBounds() {
    final result = <Offset>[];
    canvasElementManager.elementSelectComponent.paintProperty?.let((it) {
      final bounds = it.scaleRect;
      final matrix = Matrix4.identity()..rotateBy(it.angle);
      result.add(matrix.mapPoint(bounds.lt));
      result.add(matrix.mapPoint(bounds.rt));
      result.add(matrix.mapPoint(bounds.rb));
      result.add(matrix.mapPoint(bounds.lb));
    });
    return result;
  }
}

/// 删除元素
class DeleteControl extends BaseControl {
  DeleteControl(CanvasElementManager canvasElementManager)
      : super(canvasElementManager, BaseControl.CONTROL_TYPE_DELETE);

  @override
  void paintControl(Canvas canvas, PaintMeta paintMeta) {
    super.paintControl(canvas, paintMeta);
    getControlSubjectBounds()[0].let((point) {
      point = canvasViewBox
          .toViewPoint(point + Offset(-controlOffset, -controlOffset));
      final rect = Rect.fromCircle(center: point, radius: controlSize / 2);
      canvas.drawRect(rect, Paint()..color = Colors.red);
    });
  }
}
