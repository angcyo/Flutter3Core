part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///

/// 默认的动画时长
const kDefaultAnimationDuration = Duration(milliseconds: 300);

extension AnimationEx on Widget {
  /// 透明度动画, 渐隐动画.
  /// [out] fade out or fade in
  Widget fade({
    Animation<double>? opacity,
    bool out = false,
  }) {
    return FadeTransition(
      opacity: opacity ??
          Tween(begin: out ? 1.0 : 0.0, end: out ? 0.0 : 1.0).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(out ? 0 : 1),
              curve: Curves.easeIn,
            ),
          ),
      child: this,
    );
  }

  /// 滑动动画
  Widget slide({
    Animation<Offset>? offset,
    Offset? from,
    Offset? to,
    bool out = false,
  }) {
    return SlideTransition(
      position: offset ??
          Tween<Offset>(
            begin: from ?? (out ? Offset.zero : const Offset(0, 1)),
            end: to ?? (out ? const Offset(0, 1) : Offset.zero),
          ).animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(out ? 0 : 1),
            curve: Curves.easeIn,
          )),
      child: this,
    );
  }

  /// 动画切换2个[Widget].[AnimatedSwitcher]
  Widget animatedSwitcher({
    Key? key,
    Duration? duration,
    Duration? reverseDuration,
    Curve switchInCurve = Curves.linear,
    Curve switchOutCurve = Curves.linear,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    AnimatedSwitcherLayoutBuilder layoutBuilder =
        AnimatedSwitcher.defaultLayoutBuilder,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration ?? kDefaultAnimationDuration,
      reverseDuration: reverseDuration,
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      child: this,
    );
  }
}
