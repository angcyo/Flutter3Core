part of '../../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/10
///

/// [OverlayEntry] 动画驱动小部件
class OverlayAnimated extends StatefulWidget {
  /// 自动销毁的时长
  /// The total duration of overlay display.
  /// [Duration.zero] means overlay display forever.
  final Duration duration;

  /// The duration overlay show animation.
  final Duration animationDuration;

  /// The duration overlay hide animation.
  final Duration reverseAnimationDuration;

  final OverlayAnimatedWidgetBuilder builder;

  /// https://api.flutter.dev/flutter/animation/Curves-class.html
  final Curve curve;

  final Key overlayKey;

  /// 动态构建, 这里只监听值的改变, 并且重置隐藏动画的执行
  /// 布局的构建在别的层处理
  final LoadingValueNotifier? loadingInfoNotifier;

  const OverlayAnimated({
    required Key key,
    required this.animationDuration,
    required this.reverseAnimationDuration,
    Curve? curve,
    required this.builder,
    required this.duration,
    required this.overlayKey,
    this.loadingInfoNotifier,
  })  : curve = curve ?? Curves.easeInOut,
        assert(animationDuration >= Duration.zero),
        assert(reverseAnimationDuration >= Duration.zero),
        assert(duration >= Duration.zero),
        super(key: key);

  @override
  OverlayAnimatedState createState() => OverlayAnimatedState();
}

class OverlayAnimatedState extends State<OverlayAnimated>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  CancelableOperation? _autoHideOperation;

  bool _dismissScheduled = false;
  bool _dismissed = false;
  final Completer _dismissedCompleter = Completer();

  /// 使用动画的方式显示[OverlayEntry], 就是执行动画
  /// [hide]
  void show() {
    _autoHideOperation?.cancel();
    _controller.forward(from: _controller.value);
  }

  /// 使用动画的方式隐藏[OverlayEntry]
  /// [immediately] True to dismiss notification immediately. 立即执行
  /// [show]
  Future hide({bool immediately = false}) async {
    if (!immediately &&
        !_controller.isDismissed &&
        _controller.status == AnimationStatus.forward) {
      await _controller.forward(from: _controller.value);
    }
    unawaited(_autoHideOperation?.cancel());
    await _controller.reverse(from: _controller.value);
  }

  /// 真正的移除[OverlayEntry] Dismiss the overlay entry.
  void dismiss({bool animate = true}) {
    if (_dismissed || (_dismissScheduled && animate)) {
      return;
    }
    OverlayEntry? entry =
        GlobalConfig.of(context).getOverlayEntry(key: widget.overlayKey);
    if (!_dismissScheduled) {
      // Remove this entry from overlaySupportState no matter it is animating or not.
      // because when the entry with the same key, we need to show it now.
      GlobalConfig.of(context).removeOverlayEntry(key: widget.overlayKey);
    }
    _dismissScheduled = true;

    if (!animate) {
      _dismissEntry(entry);
      return;
    }

    void animateRemove() {
      if (entry != null) {
        hide().whenComplete(() {
          _dismissEntry(entry);
        });
      } else {
        //no op
      }
    }

    animateRemove();
  }

  // dismiss entry immediately and remove it from screen
  void _dismissEntry(OverlayEntry? entry) {
    if (_dismissed) {
      // already removed from screen
      return;
    }
    _dismissed = true;
    entry?.remove();
    _dismissedCompleter.complete();
  }

  @override
  void initState() {
    widget.loadingInfoNotifier?.addListener(_resetAnimate);
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        reverseDuration: widget.reverseAnimationDuration,
        debugLabel: 'OverlayAnimatedShowHideAnimation');
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        dismiss(animate: false);
      } else if (status == AnimationStatus.completed) {
        if (widget.duration > Duration.zero) {
          // 自动隐藏驱动
          _autoHideOperation =
              CancelableOperation.fromFuture(Future.delayed(widget.duration))
                ..value.whenComplete(() {
                  hide();
                });
        }
      }
    });
    show();
  }

  @override
  void dispose() {
    widget.loadingInfoNotifier?.removeListener(_resetAnimate);
    _controller.dispose();
    _autoHideOperation?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(OverlayAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    //debugger();
    oldWidget.loadingInfoNotifier?.removeListener(_resetAnimate);
    widget.loadingInfoNotifier?.removeListener(_resetAnimate);
    widget.loadingInfoNotifier?.addListener(_resetAnimate);
  }

  /// 重置隐藏动画的时长, 并且重置动画
  void _resetAnimate() {
    if (_autoHideOperation != null) {
      _autoHideOperation?.cancel();
      _autoHideOperation =
          CancelableOperation.fromFuture(Future.delayed(widget.duration))
            ..value.whenComplete(() {
              hide();
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return widget.builder(
          context,
          widget.curve.transform(_controller.value),
        );
      },
    );
  }
}

//---具体的动画实现---

/// 顶部滑动动画
class TopSlideNotification extends StatelessWidget {
  /// Which used to build notification content.
  final WidgetBuilder builder;

  final double progress;

  const TopSlideNotification({
    super.key,
    required this.builder,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation:
          Offset.lerp(const Offset(0, -1), const Offset(0, 0), progress)!,
      child: builder(context),
    );
  }
}

/// 底部滑动动画
class BottomSlideNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final double progress;

  const BottomSlideNotification({
    super.key,
    required this.builder,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation:
          Offset.lerp(const Offset(0, 1), const Offset(0, 0), progress)!,
      child: builder(context),
    );
  }
}

/// 透明渐变动画
class OpacityNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final double progress;

  const OpacityNotification({
    super.key,
    required this.builder,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: builder(context),
    );
  }
}

/// 缩放动画
class ScaleNotification extends StatelessWidget {
  ///build notification content
  final WidgetBuilder builder;

  final double progress;
  final AlignmentGeometry? alignment;

  const ScaleNotification({
    super.key,
    required this.builder,
    required this.progress,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: progress,
      child: builder(context),
    );
  }
}
