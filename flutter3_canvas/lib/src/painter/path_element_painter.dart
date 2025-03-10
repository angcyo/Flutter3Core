part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
///
/// 矢量路径绘制元素对象
class PathElementPainter extends ElementPainter {
  /// 当前绘制的路径, 请主动调用
  /// [PathEx.moveToZero]
  @dp
  Path? painterPath;

  /// transform获取操作后的图片
  @dp
  Path? get operatePath => transformElementOperatePath(painterPath);

  PathElementPainter() {
    paintStrokeWidthSuppressCanvasScale = true;
  }

  /// [path] 要绘制路径数据
  /// [moveToZero] 是否移动到0,0点
  /// [initPaintProperty] 是否初始化[PaintProperty]属性
  /// [exactBounds] 是否精确计算边界, 会消耗性能
  ///
  /// 请注意[isVisibleInCanvasBox]可见性测试
  @property
  void initFromPath(
    Path? path, {
    bool moveToZero = true,
    bool initPaintProperty = true,
    bool? exactBounds,
  }) {
    painterPath = moveToZero ? path?.moveToZero(exact: exactBounds) : path;
    if (initPaintProperty) {
      final bounds = painterPath?.getExactBounds(exactBounds) ?? Rect.zero;
      if (paintProperty == null) {
        updatePaintProperty(PaintProperty()
          ..width = bounds.width
          ..height = bounds.height);
      } else {
        paintProperty?.let((it) {
          it.width = bounds.width;
          it.height = bounds.height;
        });
      }
    }
    refresh();
  }

  ///
  @override
  void onPaintingSelfBefore(Canvas canvas, PaintMeta paintMeta) {
    super.onPaintingSelfBefore(canvas, paintMeta);
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    paintItUiPath(canvas, paintMeta, painterPath);
    if (painterPath == null) {
      assert(() {
        l.w('[$runtimeType]no data painting.');
        return true;
      }());
    }
    super.onPaintingSelf(canvas, paintMeta);
  }
}
