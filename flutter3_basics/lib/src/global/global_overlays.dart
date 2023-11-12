part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/10
///

/// The length of time the notification is fully displayed.
Duration kNotificationDuration = const Duration(milliseconds: 2000);

/// Notification display or hidden animation duration.
Duration kNotificationSlideDuration = const Duration(milliseconds: 300);

/// To build a widget with animated value.
/// [progress] : the progress of overlay animation from 0 - 1
///
typedef OverlayAnimatedWidgetBuilder = Widget Function(
    BuildContext context, double progress);

/// 显示一个通知
/// [showOverlay]的简单封装
showNotification(
  WidgetBuilder builder, {
  Duration? duration,
  Duration? animationDuration,
  Duration? reverseAnimationDuration,
  Key? key,
  Alignment alignment = Alignment.center,
  BuildContext? context,
}) {
  showOverlay(
    (context, progress) {
      if (alignment == Alignment.center) {
        return CenterOpacityNotification(
          builder: builder,
          progress: progress,
        );
      } else if (alignment == Alignment.topCenter ||
          alignment == Alignment.topLeft ||
          alignment == Alignment.topRight) {
        return TopSlideNotification(builder: builder, progress: progress);
      } else if (alignment == Alignment.bottomCenter ||
          alignment == Alignment.bottomLeft ||
          alignment == Alignment.bottomRight) {
        return BottomSlideNotification(builder: builder, progress: progress);
      } else {
        return builder(context);
      }
    },
    duration: duration,
    animationDuration: animationDuration,
    reverseAnimationDuration: reverseAnimationDuration,
    key: key,
    context: context,
  );
}

/// 全局显示一个[OverlayEntry]
/// [curve] 动画曲线/差值器
showOverlay(
  OverlayAnimatedWidgetBuilder builder, {
  BuildContext? context,
  Curve? curve,
  Duration? duration,
  Key? key,
  Duration? animationDuration,
  Duration? reverseAnimationDuration,
}) {
  OverlayState? overlayState;
  if (context == null) {
    GlobalConfig.def.globalContext
        ?.eachVisitChildElements((element, depth, childIndex) {
      if (element.widget is Overlay) {
        overlayState = (element as StatefulElement?)?.state as OverlayState?;
        return false;
      }
      return true;
    });
    //Overlay
  } else {
    overlayState = Overlay.of(context);
  }
  if (overlayState == null) {
    assert(() {
      debugPrint('overlayState is null, dispose this call');
      return true;
    }());
    return;
  }
  context ??= GlobalConfig.def.globalContext;
  if (context == null) {
    assert(() {
      debugPrint('context is null, dispose this call');
      return true;
    }());
    return;
  }
  final overlayKey = key ?? UniqueKey();
  final stateKey = GlobalKey<_OverlayAnimatedState>();
  OverlayEntry entry = OverlayEntry(
    builder: (context) {
      return KeyedSubtree(
        key: key,
        child: _OverlayAnimated(
          key: stateKey,
          builder: builder,
          curve: curve,
          animationDuration: animationDuration ?? kNotificationSlideDuration,
          reverseAnimationDuration:
              reverseAnimationDuration ?? kNotificationSlideDuration,
          duration: duration ?? kNotificationDuration,
          overlayKey: overlayKey,
        ),
      );
    },
  );

  GlobalConfig.of(context).addOverlayEntry(entry, key: overlayKey);
  overlayState?.insert(entry);
}
