part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/27
/// 当元素[ElementPainter]的[PaintProperty]属性发生变化时的处理器
///    - [ElementPainter.paintProperty]属性
///
/// 当元素的缩放属性发生变化时，将缩放属性直接作用到宽高中, 并实时改变原始数据
///
mixin PropertyScaleHandler on ElementPainter {
  /// 是否启用缩放属性处理
  /// - [onSelfScalePropertyChanged]
  bool get isScalePropertyEnabled => true;

  /// [ElementPainter.updatePaintProperty]驱动
  @callPoint
  void onUpdatePaintProperty(PaintProperty value) {
    if (isScalePropertyEnabled) {
      final sx = value.scaleX;
      final sy = value.scaleY;
      if (sx != 1 || sy != 1) {
        // 缩放属性不为1时，将缩放属性作用到宽高中
        final beforeBounds = value.paintBounds;
        value.width *= sx;
        value.height *= sy;
        value.scaleX = 1;
        value.scaleY = 1;
        onSelfScalePropertyChanged(value, fromSx: sx, fromSy: sy);
        final afterBounds = value.paintBounds;
        value.left += (beforeBounds.left - afterBounds.left);
        value.top += (beforeBounds.top - afterBounds.top);
        /*l.d(
        "left: ${beforeBounds.left} -> ${afterBounds.left} top: ${beforeBounds.top} -> ${afterBounds.top}",
      );*/
      }
    }
  }

  /// 元素缩放属性变化时的回调
  /// - [fromSx] 之前的缩放X属性
  /// - [fromSy] 之前的缩放Y属性
  @overridePoint
  void onSelfScalePropertyChanged(
    PaintProperty value, {
    required double fromSx,
    required double fromSy,
  }) {}
}
