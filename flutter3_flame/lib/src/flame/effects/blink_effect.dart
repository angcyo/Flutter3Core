import 'package:flame/effects.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/06
///
/// 一闪一闪效果
class BlinkEffect extends Effect with EffectTarget<OpacityProvider> {
  /// 闪烁不透明度
  final double blinkOpacity;

  /// 闪烁间隔 s, 指越小闪烁越快
  final double interval;

  BlinkEffect({
    //--
    this.blinkOpacity = 0.3,
    this.interval = 0.08,
    EffectController? controller,
    //闪烁持续时间 s
    double duration = 0.6,
  }) : super(controller = controller ?? EffectController(duration: duration));

  /// 目标最开始的不透明度
  double _startOpacity = 0;

  /// 当前闪烁时间
  double _elapsed = 0;

  /// 是否显示
  bool _visible = true;

  bool _isFinish = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused || _isFinish) {
      return;
    }
    _elapsed += dt;
    // 根据当前时间计算闪烁状态
    _visible = (_elapsed ~/ interval) % 2 == 0;
  }

  @override
  void onStart() {
    super.onStart();
    _startOpacity = target.opacity;
    target.opacity = blinkOpacity;
  }

  @override
  void onFinish() {
    super.onFinish();
    _isFinish = true;
    _visible = true;
    target.opacity = _startOpacity;
  }

  @override
  void apply(double progress) {
    target.opacity = _visible ? _startOpacity : blinkOpacity;
  }
}
