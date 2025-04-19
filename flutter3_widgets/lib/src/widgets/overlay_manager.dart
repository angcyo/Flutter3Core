part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/31
///

/// 用来描述[OverlayEntry]信息
class OverlayEntryInfo {
  /// id
  @flagProperty
  final String? id;

  /// 标签
  @flagProperty
  final String? tag;

  /// 实体
  final OverlayEntry entry;

  /// 关闭overlay的动画控制
  final GlobalKey<OverlayAnimateBuilderState>? entryKey;

  const OverlayEntryInfo(
    this.entry, {
    this.id,
    this.tag,
    this.entryKey,
  });
}

/// [OverlayManager]的控制器
class OverlayManagerController {
  /// [Widget]->[OverlayEntry]
  static OverlayEntry entryOf(
    Widget widget, {
    bool opaque = false,
    bool maintainState = false,
    bool canSizeOverlay = false,
  }) =>
      OverlayEntry(
        builder: (context) {
          return widget;
        },
        opaque: opaque,
        maintainState: maintainState,
        canSizeOverlay: canSizeOverlay,
      );

  OverlayManagerState? managerState;
  final GlobalKey<OverlayState> overlayKey = GlobalKey();

  /// 首页
  OverlayEntryInfo? _homeEntry;

  /// 子页集合
  final List<OverlayEntryInfo> _subOverlayEntries = [];

  /// 动画队列, 需要执行移除动画的对象放这里
  final List<OverlayEntryInfo> _animatePendingOverlayEntries = [];

  /// 所有的[OverlayEntry], 用于界面显示
  List<OverlayEntry> get overlayEntries => [
        if (_homeEntry != null) _homeEntry!.entry,
        ..._subOverlayEntries.map((e) => e.entry),
      ];

  /// 初始化首页
  @initialize
  void _initHomeEntry(Widget? home, OverlayEntry? homeEntry) {
    _homeEntry = null;
    if (homeEntry != null) {
      _homeEntry = OverlayEntryInfo(
        homeEntry,
        tag: 'home',
      );
    } else if (home != null) {
      _homeEntry = OverlayEntryInfo(
        entryOf(
          home,
          opaque: true,
          maintainState: true,
        ),
        tag: 'home',
      );
    }
  }

  //--

  /// 指定id的弹窗是否显示
  bool isShowEntry({String? id}) => findEntryInfoById(id) != null;

  /// 使用id查找[OverlayEntryInfo]
  OverlayEntryInfo? findEntryInfoById(String? id) =>
      _subOverlayEntries.findFirst((e) => e.id == id);

  /// 更新id对应的界面
  /// [StateEx.updateState]
  @api
  void updateEntryById(String? id) {
    findEntryInfoById(id)?.entryKey?.currentState?.updateState();
  }

  /// 隐藏所有[OverlayEntry]
  void hideAllOverlay([bool hide = true]) {
    for (final e in _subOverlayEntries) {
      e.entryKey?.currentState?.offstage = hide;
    }
  }

  /// 显示一个[OverlayEntry]
  void showOverlay(
    OverlayEntry entry, {
    String? tag,
  }) {
    showOverlayInfo(OverlayEntryInfo(entry, tag: tag));
  }

  /// 显示一个[OverlayEntryInfo]
  void showOverlayInfo(OverlayEntryInfo entry) {
    _subOverlayEntries.add(entry);
    overlayKey.currentState?.insert(entry.entry);
  }

  /// 显示一个[widget], 最终还是[OverlayEntry]
  ///
  /// [id] 相同id的[OverlayEntry]只会显示一次
  ///
  /// [TranslationType] 动画类型
  /// [OverlayAnimateBuilder]
  @api
  void showWidget(
    Widget widget, {
    TranslationType? type,
    String? id,
    String? tag,
    bool offstage = false,
  }) {
    //debugger();
    if (id != null) {
      if (findEntryInfoById(id) != null) {
        //相同id的[OverlayEntry]只显示一次
        return;
      }
    }

    type ??= widget.getWidgetTranslationType();
    final GlobalKey<OverlayAnimateBuilderState> animateKey = GlobalKey();
    id ??= $uuid;
    showOverlayInfo(OverlayEntryInfo(
      entryOf(
        OverlayAnimateBuilder(
          key: animateKey,
          offstage: offstage,
          builder: (BuildContext context, Animation<double> animation,
              Widget? child) {
            return buildDialogTransitions(
              context,
              animation,
              animation,
              child!,
              type,
            );
          },
          animationStatusAction: (status) {
            if (status == AnimationStatus.completed) {
              // 完全显示
            } else if (status == AnimationStatus.dismissed) {
              // 完全隐藏
              final find =
                  _animatePendingOverlayEntries.findFirst((e) => e.id == id);
              if (find != null) {
                dismissOverlayInfo(find);
              }
            }
          },
          child: widget,
        ),
      ),
      id: id,
      tag: tag,
      entryKey: animateKey,
    ));
  }

  /// 移除一个[OverlayEntry]
  /// [anim] 是否执行动画, 默认自动选择
  @api
  void removeOverlay({
    OverlayEntry? entry,
    String? tag,
    String? id,
    bool? anim,
  }) {
    final find = _subOverlayEntries
        .findLast((e) => e.entry == entry || e.tag == tag || e.id == id);
    if (find != null) {
      if (anim == false) {
        dismissOverlayInfo(find);
      } else {
        removeOverlayInfo(find);
      }
    }
  }

  /// 隐藏最后一个[OverlayEntry]
  @api
  void removeLastOverlay() {
    final last = _subOverlayEntries.lastOrNull;
    if (last != null) {
      removeOverlayInfo(last);
    }
  }

  /// 移除所有
  @api
  void removeAllOverlay() {
    for (final e in _subOverlayEntries) {
      removeOverlayInfo(e);
    }
  }

  //--

  /// 移除一个[OverlayEntryInfo], 有动画执行动画, 没动画直接解雇
  /// [dismissOverlayInfo]
  @api
  void removeOverlayInfo(OverlayEntryInfo entry) {
    _subOverlayEntries.remove(entry); //提前移除, 防止动画时间内快速显示时已存在
    _animatePendingOverlayEntries.add(entry);
    if (entry.entryKey?.currentState == null) {
      dismissOverlayInfo(entry);
    } else {
      entry.entryKey!.currentState!.hide();
    }
  }

  /// 直接解雇一个[OverlayEntryInfo], 无动画
  @callPoint
  void dismissOverlayInfo(OverlayEntryInfo entry) {
    entry.entry.remove();
    _animatePendingOverlayEntries.remove(entry);
  }

  //--

  /// 包裹一个异步操作,
  /// [action]操作时隐藏所有弹窗,
  /// [action]操作结束之后再显示所有弹窗
  Future wrapHideAllOverlay(FutureOr Function() action) async {
    hideAllOverlay();
    await action();
    hideAllOverlay(false);
  }
}

/// [Overlay]管理[OverlayEntry]的小部件
class OverlayManager extends StatefulWidget {
  /// 第一个主页, 之后的页面显示在[home]上
  final Widget? home;
  final OverlayEntry? homeEntry;
  final OverlayManagerController? controller;

  const OverlayManager({
    super.key,
    this.home,
    this.homeEntry,
    this.controller,
  });

  @override
  State<OverlayManager> createState() => OverlayManagerState();
}

class OverlayManagerState extends State<OverlayManager> {
  OverlayManagerController? _controller;

  @override
  void initState() {
    _controller = widget.controller ?? OverlayManagerController();
    _controller
      ?..managerState = this
      .._initHomeEntry(widget.home, widget.homeEntry);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OverlayManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller
      ?..managerState = this
      .._initHomeEntry(widget.home, widget.homeEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _controller?.overlayKey,
      initialEntries: _controller?.overlayEntries ?? [],
    );
  }
}

/// 用来构建[OverlayEntry]的动画
///
/// [OverlayAnimated]
class OverlayAnimateBuilder extends StatefulWidget {
  final Widget? child;
  final TransitionsBuilder builder;

  /// 动画状态回调
  /// [AnimationStatus.completed] 界面完全显示
  /// [AnimationStatus.dismissed] 界面完全隐藏
  final AnimationStatusListener? animationStatusAction;

  //--

  /// https://api.flutter.dev/flutter/animation/Curves-class.html
  final Curve curve;

  /// The duration overlay show animation.
  final Duration animationDuration;

  /// The duration overlay hide animation.
  final Duration reverseAnimationDuration;

  //--

  /// 直接进入离屏显示状态
  final bool offstage;

  const OverlayAnimateBuilder({
    super.key,
    required this.builder,
    this.child,
    this.animationStatusAction,
    this.curve = Curves.easeInOut,
    this.animationDuration = kDefaultAnimationDuration,
    this.reverseAnimationDuration = kDefaultAnimationDuration,
    this.offstage = false,
  });

  @override
  State<OverlayAnimateBuilder> createState() => OverlayAnimateBuilderState();
}

class OverlayAnimateBuilderState extends State<OverlayAnimateBuilder>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  /// 离屏
  bool _offstage = false;

  bool get offstage => _offstage;

  set offstage(value) {
    if (_offstage != value) {
      _offstage = value;
      updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return widget.builder(
          context,
          _controller.drive(CurveTween(curve: widget.curve)),
          child,
        );
      },
    ).offstage(offstage, true);
  }

  @override
  void initState() {
    _offstage = widget.offstage;
    _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        reverseDuration: widget.reverseAnimationDuration,
        debugLabel: 'OverlayAnimatedShowHideAnimation');
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        //dismiss(animate: false);
      } else if (status == AnimationStatus.completed) {
        //
      }
      widget.animationStatusAction?.call(status);
    });
    show();
  }

  @override
  void didUpdateWidget(covariant OverlayAnimateBuilder oldWidget) {
    _offstage = widget.offstage;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 使用动画的方式显示, 执行动画
  /// [hide]
  void show() {
    _controller.forward(from: _controller.value);
  }

  /// 使用动画的方式隐藏
  /// [immediately] 立即执行
  /// [show]
  Future hide({bool immediately = false}) async {
    if (!immediately &&
        !_controller.isDismissed &&
        _controller.status == AnimationStatus.forward) {
      await _controller.forward(from: _controller.value);
    }
    await _controller.reverse(from: _controller.value);
  }
}
