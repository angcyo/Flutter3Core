part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/05

/// 手势偏移距离回调
/// [offset] 手势每次移动的距离 >0:向下拉 <0:向上拉
typedef ScrollUserOffsetAction = double Function(
    ScrollMetrics position, double offset);

/// 手势结束速度回调
/// [velocity] 手势结束时的速度 >0:快速向下拉 <0:快速向上拉
/// 返回true, 表示拦截默认处理
typedef ScrollDragEndAction = bool Function(
    ScrollMetrics position, double velocity);

/// 下拉返回的小部件
/// 支持滚动和非滚动子组件
/// [ScrollConfiguration]
///
/// 对话框路由使用[DialogPageRoute]障碍颜色也能支持进度变化
/// 通过监听[ProgressStateNotification]实现
///
class PullBackWidget extends StatefulWidget {
  /// 子部件
  final Widget child;

  /// 下拉返回控制器, 动画到1就是关闭界面
  final AnimationController? pullBackController;

  /// 下拉返回触发的回调
  final void Function(BuildContext context)? onPullBack;

  /// 下拉进度回调
  final void Function(double progress)? onPullProgress;

  /// 是否可以下拉返回
  final Future<bool> Function()? canPullBackAction;

  //---

  /// 下拉返回的背景颜色, 可以不指定
  /// 指定后, 背景会有颜色, 跟随下拉进度
  final Color? barrierColor;

  /// 下拉返回的内容组件, 是否要使用[SafeArea]
  final bool useSafeArea;

  /// 是否使用滚动消费的方式处理下拉, 否则只有手势能处理下拉
  final bool useScrollConsume;

  /// 是否显示拖拽手柄
  final bool showDragHandle;

  /// 内容的装饰, 包含手柄的内容
  final Decoration? contentDecoration;

  //---

  /// 下拉最大的边界,
  /// 如果这个值>1, 则表示底部需要保留的高度
  /// [0~1]
  final double? pullMaxBound;

  /// 是否允许超出[pullMaxBound]后, 继续下拉
  final bool enablePullMaxBoundOverScroll;

  /// 拉的方向, 默认下拉返回, 还不支持横向拉
  final Axis pullAxis = Axis.vertical;

  /// 手势命中行为
  /// [HitTestBehavior.translucent] 后代和自己都可以命中
  /// [HitTestBehavior.opaque] 只有自己可以命中
  /// [HitTestBehavior.deferToChild] 只有后代可以命中
  final HitTestBehavior? behavior;

  const PullBackWidget({
    super.key,
    required this.child,
    this.barrierColor,
    this.pullBackController,
    this.onPullBack,
    this.onPullProgress,
    this.pullMaxBound,
    this.enablePullMaxBoundOverScroll = true,
    this.useScrollConsume = true,
    this.canPullBackAction,
    this.showDragHandle = false,
    this.useSafeArea = false,
    this.contentDecoration,
    this.behavior = HitTestBehavior.deferToChild,
  });

  @override
  State<PullBackWidget> createState() => _PullBackWidgetState();
}

class _PullBackWidgetState extends State<PullBackWidget>
    with TickerProviderStateMixin {
  /// 下拉进度值
  double get _pullBackValue => _pullBackController?.value ?? 0;

  /// 下拉的效果矩阵
  Matrix4 get _pullBackTransform => Matrix4.identity()
    ..translate(
        0.0, (_pullBackValue + _overPullBackValue) * (_childHeight ?? 0));

  /// [0~1] 0:未开始下拉 1:完全下拉到底部
  AnimationController? _pullBackController;

  /// [_pullBackCurve]属性生效的对象
  Animation<double>? _pullBackAnimation;

  /// 到达[PullBackWidget.pullMaxBound]指定的值时, 额外pull的量
  /// [0~1]
  double _overPullBackValue = 0;

  /// 加速曲线
  late final Curve _pullBackCurve = Curves.easeOut;

  final GlobalKey _childKey = GlobalKey(debugLabel: 'PullBack child');

  /// 子组件的高度, 用来计算下拉的距离
  double? get _childHeight {
    final childContext = _childKey.currentContext;
    final renderBox = childContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height;
  }

  /// 下拉关闭位置阈值, 下拉位置超过这个阈值, 就会关闭
  final double closePullThreshold = 0.3;

  /// 快速下拉速度阈值, 快速下拉速度超过这个阈值, 就会关闭
  final double closeFlingVelocity = 1000.0;

  @override
  void initState() {
    super.initState();
    _handlePullMaxBound(false);
  }

  @override
  void dispose() {
    //debugger();
    _pullBackController?.dispose();
    super.dispose();
  }

  ///
  @override
  void didUpdateWidget(covariant PullBackWidget oldWidget) {
    //debugger();
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pullMaxBound != null || widget.pullMaxBound != null) {
      _handlePullMaxBound(widget.pullMaxBound == oldWidget.pullMaxBound);
    }
    updateState();
  }

  void _handlePullMaxBound(bool restoreControllerValue) {
    final oldValue = _pullBackController?.value;
    _pullBackController?.stop();
    _pullBackController?.dispose();
    _pullBackController = null;
    final pullMaxBound = widget.pullMaxBound;
    if (pullMaxBound == null) {
      _initController(1.0);
      if (restoreControllerValue && oldValue != null) {
        try {
          //setState() or markNeedsBuild() called during build.
          _pullBackController?.value = oldValue;
        } catch (e) {
          assert(() {
            l.w(e);
            return true;
          }());
        }
      }
    } else if (pullMaxBound > 1) {
      final oldChildHeight = _childHeight;
      if (_childHeight != null) {
        final height = _childHeight!;
        _initController((_childHeight! - pullMaxBound) / height);
        if (restoreControllerValue && oldValue != null) {
          _pullBackController?.value = oldValue;
        }
      }
      scheduleMicrotask(() {
        final height = _childHeight;
        if (height != null && height == oldChildHeight) {
          //高度无变化
        } else {
          if (height != null) {
            _initController((height - pullMaxBound) / height);
          } else {
            _initController(1.0);
          }
          if (restoreControllerValue && oldValue != null) {
            _pullBackController?.value = oldValue;
          }
          updateState();
        }
      });
    } else {
      _initController(pullMaxBound);
      if (restoreControllerValue && oldValue != null) {
        _pullBackController?.value = oldValue;
      }
    }
  }

  void _initController(double upperBound) {
    final controller = widget.pullBackController ??
        AnimationController(
          duration: kDefaultAnimationDuration,
          vsync: this,
          upperBound: upperBound,
        );
    controller.addListener(() {
      if (widget.barrierColor != null) {
        updateState();
      }
      _notifyProgressChanged();
    });
    //动画结束监听
    controller.addStatusListener((status) {
      //l.d('$status:$_pullBackValue');
      if (_isDragEnd && status == AnimationStatus.completed) {
        _pullBack();
      } /*else if (status == AnimationStatus.dismissed) {
        l.d('dismissed:${_pullBackValue}');
      } else if (status == AnimationStatus.forward) {
        l.d('forward:${_pullBackValue}');
      } else if (status == AnimationStatus.reverse) {
        l.d('reverse:${_pullBackValue}');
      }*/
    });

    _pullBackAnimation = controller.drive(CurveTween(curve: _pullBackCurve));
    _pullBackController = controller;
  }

  /// 当前拖拽手势是否结束
  bool _isDragEnd = true;

  @override
  Widget build(BuildContext context) {
    Widget body = GestureDetector(
      behavior: widget.behavior /*HitTestBehavior.opaque*/,
      onVerticalDragStart: (details) {
        _isDragEnd = false;
      },
      onVerticalDragUpdate: (details) {
        _handleDragUpdate(details.delta.dy);
      },
      onVerticalDragEnd: (details) {
        _isDragEnd = true;
        _handleDragEnd(null, details.primaryVelocity ?? 0);
      },
      /*onPanEnd: (details) {
        //_handleDragEnd(details.primaryVelocity ?? 0);
        l.d('panEnd:${details.primaryVelocity}');
      },
      onPanCancel: () {
        l.d('panCancel');
      },
      onTapCancel: () {
        l.d('tapCancel');
      },*/
      child: ScrollConfiguration(
        behavior: _PullBackScrollBehavior(
          physics: PullBackScrollPhysics(
            consumeUserOffsetAction: _handleConsumeUserOffset,
            dragEndAction: _handleDragEnd,
          ),
        ),
        child: _pullBackAnimation == null
            ? widget.child
            : AnimatedBuilder(
                animation: _pullBackAnimation!,
                builder: (context, child) {
                  Widget content = widget.child;

                  if (widget.showDragHandle) {
                    content = [buildDragHandle(context), content].column()!;
                  }

                  if (widget.contentDecoration != null) {
                    content = Container(
                      clipBehavior: ui.Clip.hardEdge,
                      decoration: widget.contentDecoration,
                      child: content,
                    );
                  }

                  //debugger();
                  /*assert(() {
              l.v('build:$_pullBackValue ${_pullBackController.status} ${_pullBackController.isStarted}');
              return true;
            }());*/
                  return content.matrix(_pullBackTransform);
                },
              ),
      ),
    ).childKeyed(_childKey);

    if (widget.useSafeArea) {
      body = SafeArea(child: body);
    }

    if (widget.barrierColor == null) {
      return body;
    }

    return body.backgroundDecoration(
      fillDecoration(
        radius: 0,
        color: widget.barrierColor!.withOpacityRatio(1 - _pullBackValue),
      ),
    );
  }

  /// [primaryDelta] 手势每次移动的距离 >0:向下拉 <0:向上拉
  void _handleDragUpdate(double primaryDelta) async {
    _isDragEnd = false;
    final progress = primaryDelta / (_childHeight ?? primaryDelta);
    //l.d('progress:$progress [$primaryDelta/$_childHeight]');
    _pullBackController?.value += progress; //value [0~1]
    if (widget.enablePullMaxBoundOverScroll &&
        _childHeight != null &&
        (widget.pullMaxBound ?? 0) > 1) {
      if (_pullBackController != null &&
          _pullBackController!.value >= _pullBackController!.upperBound) {
        _overPullBackValue += progress;
      } else {
        _overPullBackValue = 0;
      }
    } else {
      _overPullBackValue = 0;
    }
    assert(() {
      //l.v("pull back:$_pullBackValue progress:$progress pullMaxBound:${widget.pullMaxBound}");
      return true;
    }());
    //
    _notifyProgressChanged();
    updateState();
  }

  /// 通知进度改变
  void _notifyProgressChanged() {
    widget.onPullProgress?.call(_pullBackValue);
    ProgressStateNotification(
      tag: PullBackWidget,
      progress: _pullBackValue,
    ).dispatch(buildContext);
  }

  /// [velocity] 手势结束时的速度 >0:快速向下拉 <0:快速向上拉
  /// [position] 为null时, 表示在非scroll内容中拖拽
  /// 在滚动列表中 velocity>0:快速向上拉 <0:快速向下拉, 正好相反.
  bool _handleDragEnd(ScrollMetrics? position, double velocity) {
    if (position != null && !widget.useScrollConsume) {
      return false;
    }
    //debugger();
    //velocity:-926.796055846446 value:0.0 axis:Axis.vertical pixels:-57.73985209657339
    //l.d('velocity:$velocity value:$_pullBackValue axis:${position?.axis} pixels:${position?.pixels} position:$position ');
    //position:ScrollPositionWithSingleContext#ce1ca(offset: -52.4, range: 0.0..285.5, viewport: 382.5, ScrollableState, AlwaysScrollableScrollPhysics -> PullBackScrollPhysics -> BouncingScrollPhysics -> RangeMaintainingScrollPhysics, BallisticScrollActivity#76b81(AnimationController#5ee79(▶ -52.446; for BallisticScrollActivity)), ScrollDirection.forward)
    if (widget.enablePullMaxBoundOverScroll) {
      _overPullBackValue = 0;
      updateState();
    }

    if (position != null && position.axis != widget.pullAxis) {
      return false;
    }

    _isDragEnd = true;
    if (position != null) {
      velocity = -velocity;
      //在滚动列表中触发的回调
      if (position.pixels > 0) {
        return false;
      }
    }

    if (velocity.abs() > closeFlingVelocity.abs() && velocity < 0) {
      //快速上拉
      _pullBackController?.reverse();
    } else if (velocity > closeFlingVelocity ||
        _pullBackValue > closePullThreshold) {
      //toastInfo('close:${velocity}');
      _tryPullBack();
    } else {
      _pullBackController?.reverse();
    }
    return true;
  }

  /// 尝试下拉返回
  void _tryPullBack() async {
    //debugger();
    if (await _handleCanPullBack()) {
      if (_pullBackController?.isCompleted == true) {
        _pullBack();
      } else {
        _pullBackController?.forward();
      }
    } else {
      _pullBackController?.reverse();
    }
  }

  /// 处理下拉返回的回调逻辑
  void _pullBack() {
    //debugger();
    //l.d('completed:${_pullBackValue}');
    if (widget.onPullBack == null) {
      if (widget.pullMaxBound == null) {
        buildContext?.pop();
      }
    } else if (buildContext != null) {
      widget.onPullBack?.call(buildContext!);
    }
  }

  /// 处理是否需要消耗滚动距离
  /// [offset] 当前手势移动了多少距离
  /// 返回消耗后的距离
  double _handleConsumeUserOffset(ScrollMetrics position, double offset) {
    if (!widget.useScrollConsume) {
      return offset;
    }
    //debugger();
    //l.d('_handleConsumeUserOffset: offset:$offset value:$_pullBackValue axis:${position.axis} pixels:${position.pixels} position:$position ');
    if (position.axis != widget.pullAxis) {
      return offset;
    }

    //在列表顶部
    if (position.pixels <= 0) {
      //debugger();
      if (offset >= 0) {
        //下拉
        _handleDragUpdate(offset);
        return 0;
      } else {
        //上拉
        if (_pullBackValue != 0) {
          _handleDragUpdate(offset);
          return 0;
        }
      }
    }
    return offset;
  }

  Future<bool> _handleCanPullBack() async {
    if (widget.canPullBackAction != null) {
      return await widget.canPullBackAction!();
    }
    return true;
  }
}

/*class _PullBackKeepProgressAnimation extends Animatable<double> {
  /// 需要保持的进度, 不为空时生效
  /// 动画最终需要停留在的进度
  /// [lowerBound~upperBound]
  double? pullKeepProgress;

  /// 是否激活
  bool enable = false;

  /// 动画的方向, 用来怎么判断夹紧[pullKeepProgress]
  /// [AnimationDirection.forward] 前进值从 0~1
  /// [AnimationDirection.reverse] 前进值从 1~0
  AnimationDirection direction = AnimationDirection.forward;

  //--

  /// [AnimationController.lowerBound]
  /// 头, 前
  double lowerBound = 0.0;

  /// [AnimationController.upperBound]
  /// 尾, 后
  double upperBound = 1.0;

  Animatable<double>? parent;

  @override
  double transform(double t) {
    t = parent?.transform(t) ?? t;
    final keepProgress = pullKeepProgress;
    //debugger();
    if (enable && keepProgress != null) {
      if (direction == AnimationDirection.forward) {
        t = min(t, keepProgress);
      } else {
        t = max(t, keepProgress);
      }
    }
    assert(() {
      l.v("keepProgress[$enable]->$direction...$pullKeepProgress....$t");
      return true;
    }());
    return t;
  }
}*/

/// 不指定` physics: null,` `scrollBehavior: null,`时, 系统就会走
/// [ScrollConfiguration]
///
/// [ScrollableState._updatePosition]
/// `physics`会从[ScrollBehavior]中获取, 如果此时又指定了`physics`
/// 则会调用自定义的[ScrollPhysics.applyTo]
///
class _PullBackScrollBehavior extends MaterialScrollBehavior {
  final ScrollPhysics? _physics;

  const _PullBackScrollBehavior({
    ScrollPhysics? physics,
  }) : _physics = physics;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    //debugger();
    return _physics ?? super.getScrollPhysics(context);
  }
}

/// [RangeMaintainingScrollPhysics]
/// [BouncingScrollPhysics]
/// [ClampingScrollPhysics]
class PullBackScrollPhysics extends AlwaysScrollableScrollPhysics {
  /// 消耗手势移动距离量的回调, 返回还剩多少距离需要滚动
  final ScrollUserOffsetAction? consumeUserOffsetAction;

  /// 滚动到底后的默认加速度回调
  final ScrollDragEndAction? dragEndAction;

  const PullBackScrollPhysics({
    super.parent =
        const ClampingScrollPhysics() /*const BouncingScrollPhysics(
      parent: RangeMaintainingScrollPhysics(),
    )*/
    ,
    this.consumeUserOffsetAction,
    this.dragEndAction,
  });

  @override
  PullBackScrollPhysics applyTo(ScrollPhysics? ancestor) {
    //debugger();
    return PullBackScrollPhysics(
      parent: buildParent(ancestor),
      consumeUserOffsetAction: consumeUserOffsetAction,
      dragEndAction: dragEndAction,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    //debugger();
    offset = consumeUserOffsetAction?.call(position, offset) ?? offset;
    if (offset == 0.0) {
      return 0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    //debugger();
    if (dragEndAction?.call(position, velocity) == true) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

/// 构建一个拖拽手柄
Widget buildDragHandle(
  BuildContext context, {
  double width = 50,
  double height = kM,
  double padding = kL,
}) {
  final globalTheme = GlobalTheme.of(context);
  return SizedBox(
    width: width,
    height: height + padding + padding,
    child: SizedBox(
      width: width,
      height: height,
    )
        .backgroundDecoration(
          fillDecoration(
              color: context.isThemeDark
                  ? globalTheme.icoNormalColor
                  : Colors.black12),
        )
        .align(Alignment.center),
  );
}

extension PullBackWidgetExtension on Widget {
  /// 下拉返回的小部件
  /// [ModalBottomSheetRoute.showDragHandle]
  /// [buildDragHandle]
  Widget pullBack({
    Key? key,
    bool enablePullBack = true,
    bool useScrollConsume = true,
    AnimationController? pullBackController,
    double? pullMaxBound,
    void Function(BuildContext context)? onPullBack,
    void Function(double progress)? onPullProgress,
    Future<bool> Function()? canPullBackAction,
  }) {
    if (!enablePullBack) {
      return this;
    }
    return PullBackWidget(
      key: key,
      pullMaxBound: pullMaxBound,
      useScrollConsume: useScrollConsume,
      pullBackController: pullBackController,
      onPullBack: onPullBack ??
          (context) {
            context.pop();
          },
      onPullProgress: onPullProgress,
      canPullBackAction: canPullBackAction ?? () async => true,
      child: this,
    );
  }
}
