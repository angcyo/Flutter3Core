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

  /// 子页集合, 排除了[_homeEntry]
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

  /// 指定id的弹窗是否处于隐藏状态
  bool isEntryHidden({String? id, OverlayEntryInfo? entry}) =>
      (entry ?? findEntryInfoById(id))?.entryKey?.currentState?.isHidden ==
      true;

  /// 使用id查找[OverlayEntryInfo]
  OverlayEntryInfo? findEntryInfoById(String? id) =>
      _subOverlayEntries.findFirst((e) => e.id == id);

  /// 更新id对应的界面
  /// [StateEx.updateState]
  @api
  void updateEntryById({String? id}) {
    findEntryInfoById(id)?.entryKey?.currentState?.updateState();
  }

  /// 隐藏所有[OverlayEntry]
  @api
  void hideAllOverlay([bool hide = true]) {
    for (final e in _subOverlayEntries) {
      e.entryKey?.currentState?.offstage = hide;
    }
  }

  /// 插入一个[OverlayEntry]
  void insertOverlay(
    OverlayEntry entry, {
    String? tag,
  }) {
    insertOverlayInfo(OverlayEntryInfo(entry, tag: tag));
  }

  /// 插入一个[OverlayEntryInfo]
  void insertOverlayInfo(OverlayEntryInfo entry) {
    _subOverlayEntries.add(entry);
    overlayKey.currentState?.insert(entry.entry);
  }

  /// 显示一个[widget], 最终还是[OverlayEntry]
  ///
  /// [id] 相同id的[OverlayEntry]只会显示一次
  ///
  /// [offstage] 是否离屏
  /// [hideLast] 是否隐藏最后一个[OverlayEntry]
  ///
  /// [type] 动画类型[TranslationType]
  /// [OverlayAnimateBuilder]
  @api
  void insertWidget(
    Widget widget, {
    TranslationType? type,
    String? id,
    String? tag,
    bool offstage = false,
    //--
    bool hideLast = false,
  }) {
    //debugger();
    if (id != null) {
      final entry = findEntryInfoById(id);
      if (entry != null) {
        //相同id的[OverlayEntry]只显示一次
        if (isEntryHidden(entry: entry)) {
          //entry.entryKey?.currentState?.updateState();
          showEntry(entry: entry);
        }
        return;
      }
    }

    //--last
    final last = _subOverlayEntries.lastOrNull;

    type ??= widget.getWidgetTranslationType();
    final GlobalKey<OverlayAnimateBuilderState> animateKey = GlobalKey();
    id ??= $uuid;
    insertOverlayInfo(OverlayEntryInfo(
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

    if (hideLast) {
      last?.entryKey?.currentState?.hide();
    }
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
    for (final e in _subOverlayEntries.clone().reversed) {
      removeOverlayInfo(e);
    }
  }

  //--

  /// 移除一个[OverlayEntryInfo], 有动画执行动画, 没动画直接解雇
  /// [dismissOverlayInfo]
  @api
  @animateFlag
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

  /// 移除顶层的, 并且显示上一个
  @api
  void pop({bool showPrev = false}) {
    final last = _subOverlayEntries.get(-1);
    final prev = _subOverlayEntries.get(-2); //再上一个
    if (last != null) {
      removeOverlayInfo(last);
    }
    if (showPrev) {
      prev?.entryKey?.currentState?.show();
    }
  }

  /// 显示一个被动画隐藏的[OverlayEntryInfo]
  /// [removeAbove] 是否移除上面的所有[OverlayEntry]
  @api
  void showEntry({
    String? id,
    OverlayEntryInfo? entry,
    bool removeAbove = true,
  }) {
    id ??= entry?.id;
    OverlayEntryInfo? anchorEntry;
    List<OverlayEntryInfo> removeEntries = [];
    bool findAnchor = false;
    for (final e in _subOverlayEntries) {
      if (e.id == id) {
        anchorEntry = e;
        findAnchor = true;
      } else if (findAnchor) {
        removeEntries.add(e);
      }
    }
    if (anchorEntry != null) {
      anchorEntry.entryKey?.currentState?.show();
      if (removeAbove) {
        for (final entry in removeEntries) {
          removeOverlayInfo(entry);
        }
      }
    }
  }

  //--

  /// 包裹一个异步操作, 操作执行前隐藏所有弹窗, 操作执行后显示所有弹窗
  /// [action]操作时隐藏所有弹窗,
  /// [action]操作结束之后再显示所有弹窗
  @api
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

  /// 是否隐藏了
  bool get isHidden => _controller.isDismissed;

  /// 是否处于显示状态
  bool get isShow => _controller.isCompleted;

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
