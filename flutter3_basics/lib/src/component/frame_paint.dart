part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/03
///
/// 按照指定的帧率绘制
/// - 通过每一帧的绘制时间，计算出每一帧的间隔时间，从而实现帧率控制。
/// - 掉帧时, 下一帧的绘制时间会提前。掉帧补偿
///
/// 重写[paintFrameMixin]方法, 保证帧率的回调
mixin FramePaintMixin on RenderObject {
  /// 绘制帧率
  /// - 不指定则使用默认帧率
  /// - 帧率不能超过设备帧率
  /// - [Display.refreshRate] 显示器的帧率
  @property
  int? _frameRateMixin;

  set frameRateMixin(int? value) {
    _frameRateMixin = value;
    if (value != null && value > 0) {
      _frameIntervalMixin = 1000 / value;
    }
  }

  /// 每帧的绘制间隔时长
  @tempFlag
  double _frameIntervalMixin = 0;

  /// 上一次绘制的时间
  @tempFlag
  int _lastFrameUpdateTimeMixin = 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_frameRateMixin != null && _frameRateMixin! > 0) {
      final frameInterval = _frameIntervalMixin;
      final currentTime = nowTime();
      final deltaTime = currentTime - _lastFrameUpdateTimeMixin;

      // 1. 时间检查：满足间隔才绘制
      if (deltaTime >= frameInterval) {
        // 2. 补偿修正：保持时钟步调的一致性
        // 使用取模或减去溢出值，确保长期运行不会产生时间漂移
        _lastFrameUpdateTimeMixin =
            currentTime - (deltaTime % frameInterval.toInt());
        paintFrameMixin(context, offset);
      }
    } else {
      paintFrameMixin(context, offset);
    }
  }

  /// 保证帧率的回调
  @overridePoint
  void paintFrameMixin(PaintingContext context, Offset offset) {}
}
