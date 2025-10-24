part of '../../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/24
///
/// 参考线构建组件
/// 在坐标轴上拖动以生成参考线
///
class RefLineComponent with IPainterEventHandlerMixin, TranslateDetectorMixin {
  final CanvasAxisManager axisManager;

  /// 要构建什么方向的参考线
  final Axis axis;

  RefLineComponent(this.axisManager, this.axis);

  @override
  bool handlePointerEvent(@viewCoordinate PointerEvent event) {
    return addTranslateDetectorPointerEvent(event);
  }

  RefLineData? _refLineData;

  @override
  bool handleTranslateDetectorPointerEvent(
    PointerEvent event,
    double ddx,
    double ddy,
    double mdx,
    double mdy,
  ) {
    //debugger();
    _refLineData ??= RefLineData(axis, 0);
    final value = axis == Axis.horizontal
        ? axisManager.toScenePoint(event.localPosition).y
        : axisManager.toScenePoint(event.localPosition).x;
    _refLineData?.sceneValue = value;
    l.i(
      "sceneValue->${_refLineData?.axis} $value -> ${_refLineData?.sceneValue}",
    );
    axisManager.addRefLine(_refLineData);
    return true;
  }
}

/// 参考线数据
final class RefLineData {
  /// 轴向
  ///
  /// - [Axis.horizontal] 横向参考线, 横着绘制
  /// - [Axis.vertical] 纵向参考线, 竖着绘制
  final Axis axis;

  /// 场景中, 距离场景原点的距离值
  @dp
  @sceneCoordinate
  double sceneValue;

  RefLineData(this.axis, this.sceneValue);
}
