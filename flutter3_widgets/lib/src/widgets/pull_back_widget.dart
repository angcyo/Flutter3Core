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

  /// 是否显示拖拽手柄
  final bool showDragHandle;

  /// 内容的装饰, 包含手柄的内容
  final Decoration? contentDecoration;

  //---

  /// 下拉返回时, 是否保持到一定的进度, 并不直接关闭页面?
  /// 而是停留在此进度上
  /// [0~1]
  final double? pullKeepProgress;

  /// 拉的方向, 默认下拉返回, 还不支持横向拉
  final Axis pullAxis = Axis.vertical;

  const PullBackWidget({
    super.key,
    required this.child,
    this.barrierColor,
    this.pullBackController,
    this.onPullBack,
    this.onPullProgress,
    this.pullKeepProgress = 0.3,
    this.canPullBackAction,
    this.showDragHandle = false,
    this.useSafeArea = false,
    this.contentDecoration,
  });

  @override
  State<PullBackWidget> createState() => _PullBackWidgetState();
}

class _PullBackWidgetState extends State<PullBackWidget>
    with SingleTickerProviderStateMixin {
  /// 下拉的效果矩阵
  Matrix4 get _pullBackTransform => Matrix4.identity()
    ..translate(0.0, _pullBackController.value * (_childHeight ?? 0));

  /// [0~1] 0:未开始下拉 1:完全下拉到底部
  late final AnimationController _pullBackController;
  late final Animation<double> _pullBackAnimation;

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
  final double closeFlingVelocity = 500.0;

  @override
  void initState() {
    super.initState();
    _pullBackController = widget.pullBackController ??
        AnimationController(
          duration: kDefaultAnimationDuration,
          vsync: this,
        );
    _pullBackController.addListener(() {
      if (widget.barrierColor != null) {
        updateState();
      }
      widget.onPullProgress?.call(_pullBackController.value);
    });
    //动画结束监听
    _pullBackController.addStatusListener((status) {
      //l.d('$status:${_pullBackController.value}');
      if (_isDragEnd && status == AnimationStatus.completed) {
        _pullBack();
      } /*else if (status == AnimationStatus.dismissed) {
        l.d('dismissed:${_pullBackController.value}');
      } else if (status == AnimationStatus.forward) {
        l.d('forward:${_pullBackController.value}');
      } else if (status == AnimationStatus.reverse) {
        l.d('reverse:${_pullBackController.value}');
      }*/
    });

    _pullBackAnimation = _pullBackController.drive(
      CurveTween(curve: _pullBackCurve),
    );
  }

  /// 处理下拉返回的回调逻辑
  void _pullBack() {
    //debugger();
    //l.d('completed:${_pullBackController.value}');
    if (widget.onPullBack == null) {
      buildContext?.pop();
    } else if (buildContext != null) {
      widget.onPullBack?.call(buildContext!);
    }
  }

  @override
  void dispose() {
    _pullBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        _handleDragUpdate(details.delta.dy);
      },
      onVerticalDragEnd: (details) {
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
        child: AnimatedBuilder(
          animation: _pullBackAnimation,
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
        borderRadius: 0,
        color:
            widget.barrierColor!.withOpacityRatio(1 - _pullBackAnimation.value),
      ),
    );
  }

  bool _isDragEnd = false;

  /// [primaryDelta] 手势每次移动的距离 >0:向下拉 <0:向上拉
  void _handleDragUpdate(double primaryDelta) async {
    _isDragEnd = false;
    final progress = primaryDelta / (_childHeight ?? primaryDelta);
    //l.d('progress:$progress [$primaryDelta/$_childHeight]');
    _pullBackController.value += progress; //value [0~1]
    //l.d("pull back:${_pullBackController.value}");
    //
    ProgressStateNotification(
      tag: PullBackWidget,
      progress: _pullBackController.value,
    ).dispatch(buildContext);
    updateState();
  }

  /// [velocity] 手势结束时的速度 >0:快速向下拉 <0:快速向上拉
  /// [position] 为null时, 表示在非scroll内容中拖拽
  bool _handleDragEnd(ScrollMetrics? position, double velocity) {
    //debugger();
    //l.d('velocity:$velocity value:${_pullBackController.value}');

    if (position != null && position.axis != widget.pullAxis) {
      return false;
    }

    _isDragEnd = true;
    if (position != null) {
      //在滚动列表中
      if (position.pixels > 0) {
        return false;
      }
    }

    if (velocity > closeFlingVelocity ||
        _pullBackController.value > closePullThreshold) {
      //toastInfo('close:${velocity}');
      _tryPullBack();
    } else {
      _pullBackController.reverse();
    }
    return true;
  }

  /// 尝试下拉返回
  void _tryPullBack() async {
    //debugger();
    if (await _handleCanPullBack()) {
      if (_pullBackController.isCompleted) {
        _pullBack();
      } else {
        _pullBackController.forward();
      }
    } else {
      _pullBackController.reverse();
    }
  }

  /// 处理是否需要消耗滚动距离
  /// [offset] 当前手势移动了多少距离
  /// 返回消耗后的距离
  double _handleConsumeUserOffset(ScrollMetrics position, double offset) {
    //debugger();
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
        if (_pullBackController.value != 0) {
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

/// 不指定` physics: null,` `scrollBehavior: null,`时, 系统就会走
/// [ScrollConfiguration]
class _PullBackScrollBehavior extends MaterialScrollBehavior {
  final ScrollPhysics? _physics;

  const _PullBackScrollBehavior({
    ScrollPhysics? physics,
  }) : _physics = physics;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
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
        const BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics()),
    this.consumeUserOffsetAction,
    this.dragEndAction,
  });

  @override
  PullBackScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PullBackScrollPhysics(
      parent: buildParent(ancestor),
      consumeUserOffsetAction: consumeUserOffsetAction,
      dragEndAction: dragEndAction,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    offset = consumeUserOffsetAction?.call(position, offset) ?? offset;
    if (offset == 0.0) {
      return 0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
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
    bool enablePullBack = true,
    Key? key,
    AnimationController? pullBackController,
    void Function(BuildContext context)? onPullBack,
    void Function(double progress)? onPullProgress,
    Future<bool> Function()? canPullBackAction,
  }) {
    if (!enablePullBack) {
      return this;
    }
    return PullBackWidget(
      key: key,
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
