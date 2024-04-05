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

  /// 下拉返回控制器
  final AnimationController? pullBackController;

  /// 下拉返回触发的回调
  final void Function(BuildContext context)? onPullBack;

  /// 下拉进度回调
  final void Function(double progress)? onPullProgress;

  /// 是否可以下拉返回
  final Future<bool> Function()? canPullBackAction;

  const PullBackWidget({
    super.key,
    required this.child,
    this.pullBackController,
    this.onPullBack,
    this.onPullProgress,
    this.canPullBackAction,
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
      //updateState();
      widget.onPullProgress?.call(_pullBackController.value);
    });
    //动画结束监听
    _pullBackController.addStatusListener((status) {
      //l.d('$status:${_pullBackController.value}');
      if (status == AnimationStatus.completed) {
        //l.d('completed:${_pullBackController.value}');
        widget.onPullBack?.call(buildContext);
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

  @override
  void dispose() {
    _pullBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            return widget.child.matrix(_pullBackTransform);
          },
        ),
      ),
    ).childKeyed(_childKey);
  }

  /// [primaryDelta] 手势每次移动的距离 >0:向下拉 <0:向上拉
  void _handleDragUpdate(double primaryDelta) async {
    final progress = primaryDelta / (_childHeight ?? primaryDelta);
    //l.d('progress:$progress [$primaryDelta/$_childHeight]');
    _pullBackController.value += progress;
    updateState();
  }

  /// [velocity] 手势结束时的速度 >0:快速向下拉 <0:快速向上拉
  bool _handleDragEnd(ScrollMetrics? position, double velocity) {
    //l.d('velocity:$velocity value:${_pullBackController.value}');

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
      _pullBackController.forward();
    } else {
      _pullBackController.reverse();
    }
  }

  /// 处理是否需要消耗滚动距离
  /// [offset] 当前手势移动了多少距离
  /// 返回消耗后的距离
  double _handleConsumeUserOffset(ScrollMetrics position, double offset) {
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
  final ScrollUserOffsetAction? consumeUserOffsetAction;
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
Widget buildDragHandle({
  double width = 40,
  double height = 5,
  double padding = 4,
}) {
  return SizedBox(
    width: width,
    height: height + padding + padding,
    child: SizedBox(
      width: width,
      height: height,
    )
        .backgroundDecoration(
          fillDecoration(color: Colors.black12),
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
