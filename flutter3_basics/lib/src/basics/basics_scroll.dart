part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/30
///
/// [ScrollController]扩展
extension ScrollControllerEx on ScrollController {
  /// 滚动到顶部
  @api
  void scrollToTop({
    double offset = 0,
    bool anim = true,
    Duration duration = kDefaultAnimationDuration,
    Curve curve = Curves.easeOut,
  }) {
    if (!hasClients) {
      assert(() {
        l.w('操作被忽略,无客户端!');
        return true;
      }());
      return;
    }
    if (!offset.isValid) {
      assert(() {
        l.w('操作被忽略,无效的滚动偏移量->$offset');
        return true;
      }());
      return;
    }
    if (anim) {
      animateTo(offset, duration: duration, curve: curve);
    } else {
      jumpTo(offset);
    }
  }

  /// 停止滚动
  @api
  void stopScroll() {
    position.didEndScroll();
  }

  /// 滚动到当前位置

  /// 滚动到底部
  @api
  Timer? scrollToBottom({
    bool anim = true,
    Duration? duration,
    Curve curve = Curves.easeOut,
    //--
    double pollStep = 100 /*轮询滚动步长*/,
    Duration timeoutDuration = const Duration(seconds: 5),
  }) {
    if (!hasClients) {
      assert(() {
        l.w('操作被忽略,无客户端!');
        return true;
      }());
      return null;
    }
    duration ??= kDefaultAnimationDuration;
    if (position.maxScrollExtent.isValid) {
      //数值有效
      scrollToTop(
        offset: position.maxScrollExtent,
        anim: anim,
        duration: duration,
        curve: curve,
      );
    } else {
      //滚动数值无效, 则慢慢滚动直到数值有效
      final timer = timerPeriodic(const Duration(milliseconds: 16), (timer) {
        if (position.maxScrollExtent.isValid) {
          timer.cancel();
          //一旦发现数值有效, 则滚动到有效位置
          scrollToTop(
            offset: position.maxScrollExtent,
            anim: anim,
            duration: duration!,
            curve: curve,
          );
        } else {
          scrollToTop(
            offset: position.pixels + pollStep,
            anim: false,
            duration: duration!,
            curve: curve,
          );
        }
      });
      timerDelay(timeoutDuration, () {
        timer.cancel();
      });
      return timer;
    }
    return null;
  }

  @api
  void scrollToCurrent({
    bool anim = false,
    Duration duration = kDefaultAnimationDuration,
    Curve curve = Curves.easeOut,
  }) {
    if (!hasClients) {
      assert(() {
        l.w('操作被忽略,无客户端!');
        return true;
      }());
      return;
    }
    //l.d("...test:${position.pixels} ${position.minScrollExtent} ${position.maxScrollExtent}");
    //debugger();
    scrollToTop(
      offset: min(position.pixels, position.maxScrollExtent),
      anim: anim,
      duration: duration,
      curve: curve,
    );
  }
}
