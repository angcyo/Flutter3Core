part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/27
///
/// [PaintProperty] 扩展
extension PaintPropertyEx on PaintProperty {
  /// 从 [PaintProperty] 对应的后置矩形中获取一个指定对齐位置的点坐标
  /// - [offset] 原始位置时的额外偏移量
  /// - [useOperateMatrix] 是否使用 [operateMatrix] 进行坐标转换, 这样得到的坐标更接近数据真实的坐标
  /// - [postMatrix] 额外需要作用的后置矩阵
  @sceneCoordinate
  Offset getPostAlignPosition(
    Alignment align, {
    Offset offset = .zero,
    bool useOperateMatrix = true,
    //--
    Matrix4? postMatrix,
  }) {
    if (useOperateMatrix) {
      @sceneCoordinate
      final bounds = this.rect;
      Offset position = align.withinRect(bounds);
      position += offset;
      position = operateMatrix.postConcatIt(postMatrix).mapPoint(position);
      /*assert(() {
        if (align == .topLeft) {
          l.d("topLeft position->$position angle:$angle");
        }
        return true;
      }());*/
      return position;
    } else {
      @sceneCoordinate
      final bounds = paintScaleRect;
      Offset position = align.withinRect(bounds);
      position += offset;
      final rotateMatrix = Matrix4.identity()
        ..rotateBy(angle, anchor: bounds.center);
      position = rotateMatrix.postConcatIt(postMatrix).mapPoint(position);
      return position;
    }
  }
}

extension CanvasOffsetEx on Offset {
  /// 转换为视图坐标
  @viewCoordinate
  Offset toViewPoint(CanvasViewBox? viewBox) {
    return viewBox?.toViewPoint(this) ?? this;
  }

  /// 转换为场景坐标
  @sceneCoordinate
  Offset toScenePoint(CanvasViewBox? viewBox, {bool isSceneOrigin = false}) {
    return viewBox?.toScenePoint(this, isSceneOrigin: isSceneOrigin) ?? this;
  }
}
