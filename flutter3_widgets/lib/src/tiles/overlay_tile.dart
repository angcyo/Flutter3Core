part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/21
///
/// 覆盖层触发器,
/// 使用[CompositedTransformTarget].[CompositedTransformFollower]+[OverlayEntry]实现
///
/// - [MenuTriggerWidget]
/// - [OverlayTriggerWidget]
///
/// [OverlayPortal]
class OverlayTriggerWidget extends StatefulWidget {
  final Widget? child;

  /// [Overlay]需要显示的内容
  /// - 请自行控制约束大小
  /// - 和[Material]
  final Widget? content;

  /// 是否激活悬停触发显示
  final bool hoverTrigger;

  /// 悬停时的装饰
  @defInjectMark
  final Decoration? hoverDecoration;

  /// 点击的额外回调
  final GestureTapCallback? onTap;

  /// 是否处于选中状态, 会有背景装饰
  final bool? isSelected;

  /// 选中状态的背景
  @defInjectMark
  final Decoration? selectedDecoration;

  /// 鼠标样式
  @defInjectMark
  final MouseCursor? cursor;

  //MARK: - Composited

  /// 对齐锚点的什么位置
  final Alignment targetAnchor;

  /// 浮窗的什么位置
  final Alignment followerAnchor;

  /// 对齐后, 额外的偏移量
  final Offset? alignmentOffset;

  //MARK: - Overlay

  /// 是否使用根Overlay
  final bool rootOverlay;

  const OverlayTriggerWidget({
    super.key,
    this.child,
    this.content,
    this.hoverTrigger = false,
    this.hoverDecoration,
    this.isSelected,
    this.selectedDecoration,
    this.onTap,
    this.cursor,
    //--
    this.targetAnchor = .topLeft,
    this.followerAnchor = .topLeft,
    this.alignmentOffset,
    //--
    this.rootOverlay = false,
  });

  @override
  State<OverlayTriggerWidget> createState() => _OverlayTriggerWidgetState();
}

class _OverlayTriggerWidgetState extends State<OverlayTriggerWidget> {
  /// 1. 创建 LayerLink 用于连接 目标组件 和 悬浮Overlay 组件
  final LayerLink _layerLink = LayerLink();

  /// 2. 维护全局顶层悬浮窗的引用
  OverlayEntry? _overlayEntry;

  /// 显示 Overlay
  void _showOverlay() {
    if (_overlayEntry != null) return; // 防止重复创建
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          // 必须使用 CompositedTransformFollower 来实现坐标跟随
          child: CompositedTransformFollower(
            link: _layerLink,
            // 当目标组件不在屏幕内时隐藏
            showWhenUnlinked: false,
            offset: widget.alignmentOffset ?? .zero /*const Offset(0, 55)*/,
            // 对齐锚点的什么位置
            targetAnchor: widget.targetAnchor,
            // 浮窗的什么位置
            followerAnchor: widget.followerAnchor,
            child: _wrapHoverChild(
              widget.content,
            )?.align(widget.followerAnchor) /*.bounds()*/,
          ),
        );
      },
    );

    // 将创建好的 Entry 插入到全局 Overlay 中
    Overlay.of(context, rootOverlay: widget.rootOverlay).insert(_overlayEntry!);
  }

  /// 隐藏并销毁 Overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    // 关键：如果组件在悬停状态下被销毁，必须手动释放 Overlay，否则会导致内存泄漏和UI残留
    _hideOverlay();
    _debounceTimer?.cancel(); // 销毁时务必释放定时器，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final hoverDecoration =
        widget.hoverDecoration ??
        fillDecoration(
          color: globalTheme.hoverColor,
          radius: kDefaultBorderRadiusH,
        );
    // 3. 必须使用 CompositedTransformTarget 包裹目标组件
    final child = CompositedTransformTarget(
      link: _layerLink,
      child: [_isMouseOverButtonLive, _isMouseOverMenuLive].buildFn(
        () => DecoratedBox(
          decoration: widget.isSelected == true
              ? widget.selectedDecoration ??
                    fillDecoration(
                      color: globalTheme.hoverColor,
                      radius: kDefaultBorderRadiusH,
                    )
              : _isMouseOverButtonLive.value == true ||
                    _isMouseOverMenuLive.value == true
              ? hoverDecoration
              : kEmptyDecoration,
          child: widget.child?.click(() {
            //l.d(_widgetFocusNode.hasFocus);
            if (_overlayEntry == null) {
              _showOverlay();
            } else {
              _hideOverlay();
            }
            widget.onTap?.call();
          }),
        ),
      ),
    );
    //--mouse
    final result = MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) {
        _isMouseOverButtonLive << true;
        if (widget.hoverTrigger) {
          _showOverlay();
        }
      },
      onExit: (_) {
        _isMouseOverButtonLive << false;
        if (widget.hoverTrigger) {
          _scheduleCloseCheck(); // 划出进入缓冲区
        }
      },
      onHover: (_) {
        //l.d("onHover");
      },
      child: child,
    );
    return result;
  }

  //MARK: - hover

  /// 鼠标在当前按钮内
  final _isMouseOverButtonLive = $live(false);

  /// 鼠标在菜单内
  final _isMouseOverMenuLive = $live(false);

  Timer? _debounceTimer;

  /// 核心控制中枢：延迟检查是否应该关闭菜单
  void _scheduleCloseCheck() {
    if (!widget.hoverTrigger) {
      return;
    }
    _debounceTimer?.cancel(); // 每次触发时清除上一次的计时器
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      // 只有当鼠标既不在触发按钮上，也不在任何层级的菜单上时，才真正关闭
      if (_isMouseOverButtonLive.value != true &&
          _isMouseOverMenuLive.value != true) {
        _hideOverlay();
      }
    });
  }

  /// 将Overlay内容使用鼠标区域包裹起来, 共享鼠标的进入/离开事件
  Widget? _wrapHoverChild(Widget? child) {
    if (child == null) return null;
    if (widget.hoverTrigger) {
      return MouseRegion(
        onEnter: (_) {
          _isMouseOverMenuLive << true; // 鼠标进入任何一级的菜单项
        },
        onExit: (_) {
          _isMouseOverMenuLive << false; // 鼠标离开当前菜单项
          _scheduleCloseCheck(); // 触发延迟关闭检查
        },
        child: child,
      );
    }
    return child;
  }
}

/// [OverlayEntry]控制小部件
/// - 支持共享拖拽位置的偏移量
/// - 支持动画显示
/// - 支持动画隐藏
class OverlayEntryControlWidget extends StatefulWidget {
  /// 浮窗tag, 用于全局管理, 不指定, 不管理
  final String? tag;

  /// 核心: 浮窗实体
  final OverlayEntry? overlayEntry;

  /// child, 动画控制的部分
  final Widget? child;

  /// 浮窗显示的回调
  final VoidAction? onShow;

  /// 浮窗隐藏的回调
  final VoidAction? onHide;

  //MARK: animate

  /// 是否需要显示动画
  final bool animate;

  /// 动画时长
  final Duration animateDuration;

  /// 获取缩放动画对齐的偏移
  /// - [Alignment]
  /// - [FractionalOffset]
  final Alignment? Function()? onGetScaleAnimateAlign;

  const OverlayEntryControlWidget({
    super.key,
    this.tag,
    this.overlayEntry,
    this.child,
    this.onHide,
    this.onShow,
    //--
    this.animate = true,
    this.animateDuration = const Duration(milliseconds: 150),
    this.onGetScaleAnimateAlign,
  });

  @override
  State<OverlayEntryControlWidget> createState() => OverlayEntryControlState();
}

class OverlayEntryControlState extends State<OverlayEntryControlWidget>
    with SingleTickerProviderStateMixin {
  /// 管理所有浮窗
  static final _overlayEntryControlStateMap =
      <String, OverlayEntryControlState>{};

  /// 获取指定的控制状态
  @api
  static OverlayEntryControlState? getOverlayEntryControlStateByTag(
    String? tag,
  ) {
    return _overlayEntryControlStateMap[tag];
  }

  /// 关闭指定浮窗
  @api
  static bool hideOverlayByTag(String? tag) {
    return _overlayEntryControlStateMap[tag]?.hideOverlay() == true;
  }

  //MARK: 共享数据

  /// 共享: 拖拽偏移总量
  /// - 用于实现拖拽移动浮窗
  ///
  /// 使用[OverlayDragTriggerWidget]触发拖拽
  /// 具体的浮窗监听[dragOffsetLive]的变化刷新界面位置, 不监听则没有任何效果
  final dragOffsetLive = $live(Offset.zero);

  /// 浮窗实体
  @tempFlag
  OverlayEntry? _overlayEntry;

  //MARK: animate

  late final AnimationController animateController = AnimationController(
    duration: widget.animateDuration,
    reverseDuration: widget.animateDuration,
    vsync: this,
  );

  Alignment? _scaleAlignment;

  @override
  void initState() {
    super.initState();
    _overlayEntry = widget.overlayEntry;
    if (widget.animate) {
      _scaleAlignment = widget.onGetScaleAnimateAlign?.call();
      _waitScaleAlignment();
    }
    if (widget.tag != null) {
      _overlayEntryControlStateMap[widget.tag!] = this;
      widget.onShow?.call();
    }
  }

  /// 等待下一帧
  void _waitScaleAlignment() {
    if (_scaleAlignment == null && widget.onGetScaleAnimateAlign != null) {
      $nextFrame(() {
        _scaleAlignment = widget.onGetScaleAnimateAlign?.call();
        _waitScaleAlignment();
      });
    } else {
      animateController.forward();
      updateState();
    }
  }

  @override
  void didUpdateWidget(covariant OverlayEntryControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlayEntry != oldWidget.overlayEntry) {
      _overlayEntry = widget.overlayEntry;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? child = widget.child;
    if (widget.animate) {
      child = FadeTransition(
        opacity: animateController,
        child: ScaleTransition(
          alignment: _scaleAlignment ?? FractionalOffset(0, 0),
          scale: animateController,
          child: child,
        ),
      ).offstage(_scaleAlignment == null, true);
    }
    return OverlayEntryControlStateScope(
      overlayEntryControlState: this,
      child: child ?? empty,
    );
  }

  /// 隐藏界面
  /// - 支持动画
  @api
  bool hideOverlay() {
    if (_overlayEntry == null) {
      return false;
    }
    if (widget.tag != null) {
      _overlayEntryControlStateMap.remove(widget.tag);
    }
    if (widget.animate) {
      animateController.reverse().then((value) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        widget.onHide?.call();
      });
      return true;
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.onHide?.call();
      return true;
    }
  }
}

/// 提供一个[OverlayEntryControlState]用于操作浮窗
class OverlayEntryControlStateScope extends InheritedWidget {
  static OverlayEntryControlState? of(
    BuildContext? context, {
    bool depend = false,
  }) {
    if (depend) {
      return context
          ?.dependOnInheritedWidgetOfExactType<OverlayEntryControlStateScope>()
          ?.overlayEntryControlState;
    } else {
      return context
          ?.getInheritedWidgetOfExactType<OverlayEntryControlStateScope>()
          ?.overlayEntryControlState;
    }
  }

  /// 隐藏浮窗
  static bool hideOverlay(BuildContext? context, {bool depend = false}) {
    return OverlayEntryControlStateScope.of(
          context,
          depend: depend,
        )?.hideOverlay() ==
        true;
  }

  //--

  final OverlayEntryControlState overlayEntryControlState;

  const OverlayEntryControlStateScope({
    super.key,
    required this.overlayEntryControlState,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant OverlayEntryControlStateScope oldWidget) {
    return overlayEntryControlState != oldWidget.overlayEntryControlState;
  }
}

/// 浮窗拖拽触发小部件
class OverlayDragTriggerWidget extends StatefulWidget {
  /// 小部件
  final Widget? child;

  /// 默认的偏移量
  final Offset? offset;

  const OverlayDragTriggerWidget({super.key, this.child, this.offset});

  @override
  State<OverlayDragTriggerWidget> createState() =>
      _OverlayDragTriggerWidgetState();
}

class _OverlayDragTriggerWidgetState extends State<OverlayDragTriggerWidget> {
  /// 默认的偏移量
  Offset defOffset = Offset.zero;

  /// 当前拖拽位置, 关键值
  Offset dragOffset = Offset.zero;

  /// 总共需要的偏移
  @output
  Offset get positionOffset => dragOffset + defOffset;

  @override
  void didUpdateWidget(covariant OverlayDragTriggerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.offset != defOffset) {
      defOffset = widget.offset ?? Offset.zero;
      _onUpdateOverlayPosition();
    }
  }

  @override
  void initState() {
    defOffset = widget.offset ?? Offset.zero;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.child ?? empty;
    return body
        .gesture(
          onPanUpdate: (details) {
            dragOffset += details.delta;
            _onUpdateOverlayPosition();
          },
          onPanStart: (details) {},
          onPanEnd: (details) {
            //
          },
          onTap: null,
          behavior: .translucent,
        )
        .mouse(cursor: SystemMouseCursors.move);
  }

  /// 共享偏移数据
  @overridePoint
  void _onUpdateOverlayPosition() {
    OverlayEntryControlStateScope.of(
      context,
    )?.dragOffsetLive.updateValue(positionOffset);
  }
}

extension OverlayWidgetEx on Widget {
  /// [Overlay]覆盖层现实触发器
  @dsl
  Widget overlayTrigger({
    Key? key,
    Widget? content,
    bool hoverTrigger = false,
    Decoration? hoverDecoration,
    GestureTapCallback? onTap,
    bool? isSelected,
    Decoration? selectedDecoration,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
    MouseCursor? cursor,
    bool enable = true,
  }) {
    if (!enable) {
      return this;
    }
    return OverlayTriggerWidget(
      key: key,
      hoverTrigger: hoverTrigger,
      content: content,
      hoverDecoration: hoverDecoration,
      isSelected: isSelected,
      selectedDecoration: selectedDecoration,
      targetAnchor: targetAnchor ?? .topLeft,
      followerAnchor: followerAnchor ?? .topLeft,
      alignmentOffset: alignmentOffset,
      onTap: onTap,
      cursor: cursor,
      child: this,
    );
  }

  /// 触发浮窗拖拽, 将数据共享到[OverlayEntryControlWidget], 监听偏移量更新界面, 刷新位置
  ///
  /// [OverlayDragTriggerWidget]
  Widget overlayDragTrigger({Key? key, Offset? defOffset, bool enable = true}) {
    if (!enable) {
      return this;
    }
    return OverlayDragTriggerWidget(key: key, offset: defOffset, child: this);
  }
}

/// 浮窗上下文扩展
///
/// - [OverlayTriggerWidget]
/// - [ArrowPopupOverlay]
extension OverlayEx on BuildContext {
  /// 在指定锚点位置显示浮窗 [Overlay]+[OverlayEntry]实现
  ///
  /// - [closeBefore]
  ///   - null: 支持显示多个浮窗
  ///   - true: 如果已存在浮窗, 则关闭, 并不显示新的.
  ///   - false: 如果已存在浮窗, 则跳过
  ///
  /// - [OverlayEntry.remove] 手动移除
  /// - [OverlayEntryControlState.hideOverlayByTag] 隐藏指定标签的浮窗
  ///
  /// - [PopupEx.showArrowPopupOverlay]
  OverlayEntry showOverlay(
    Widget? Function(BuildContext, OverlayEntry)? contentBuilder, {
    BuildContext? anchorChild,
    bool rootOverlay = false,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
    //--
    VoidAction? onHide /*隐藏浮窗时的回调*/,
    @defInjectMark Alignment? scaleAlignment /*缩放动画对齐方式*/,
    //--
    @defInjectMark String? tag /*唯一标识, 用于关闭指定浮窗*/,
    bool? closeBefore = false,
  }) {
    if (closeBefore != null && tag != null) {
      final overlayEntryControlState =
          OverlayEntryControlState.getOverlayEntryControlStateByTag(tag);
      final overlayEntry = overlayEntryControlState?._overlayEntry;
      if (overlayEntryControlState != null && overlayEntry != null) {
        if (closeBefore) {
          overlayEntryControlState.hideOverlay();
        }
        return overlayEntry;
      }
    }
    final that = this;
    final overlay = Overlay.of(that, rootOverlay: rootOverlay);
    //--
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        FractionalOffset? fractionalOffset;
        final child = contentBuilder?.call(context, overlayEntry!) ?? empty;
        return OverlayEntryControlWidget(
          tag: tag ?? child.runtimeType.toString(),
          overlayEntry: overlayEntry,
          onHide: onHide,
          onGetScaleAnimateAlign: () => fractionalOffset,
          child: AlignmentAnchorLayout(
            anchorChild: anchorChild ?? that,
            anchorAncestor: overlay.context.findRenderObject(),
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            alignmentOffset: alignmentOffset,
            onChildUpdatePosition: (_, parentSize, childSize, childOffset) {
              final align = scaleAlignment ?? followerAnchor ?? .centerLeft;
              final offset = childOffset + align.alongSize(childSize);
              fractionalOffset = FractionalOffset(
                offset.dx / parentSize.width,
                offset.dy / parentSize.height,
              );
            },
            child: child,
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    return overlayEntry;
  }
}
