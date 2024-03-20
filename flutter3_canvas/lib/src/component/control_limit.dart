part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/20
///
/// 控制限制器
class ControlLimit {
  final CanvasElementControlManager canvasElementControlManager;

  /// 限制元素单次最小缩放的比例
  double? elementMinScale = 0.001;

  ControlLimit(this.canvasElementControlManager);

  /// 限制缩放
  Matrix4 limitScale() {
    /*final tsx = it.scaleX * sx;
    final tsy = it.scaleY * sy;

    final minScale = canvasDelegate
        ?.canvasElementManager.canvasElementControlManager.elementMinScale;
    if (minScale != null) {
      double minSx = tsx < minScale ? minScale / it.scaleX : sx;
      double minSy = tsy < minScale ? minScale / it.scaleY : sy;

      //debugger();

      if (tsx < minScale || tsy < minScale) {
        //最终的缩放比例小于限制的最小值
        if (sx.equalTo(sy)) {
          //等比缩放
          if (tsx < minScale) {
            sx = minSx;
          } else {
            sx = minSy;
          }
          sy = sx;
        } else {
          //不等比缩放
          sx = minSx;
          sy = minSy;
        }
      }
    }*/
    return Matrix4
        .identity(); /*
      ..translate(it.translateX, it.translateY)
      ..scale(sx, sy, 1.0);*/
  }
}
