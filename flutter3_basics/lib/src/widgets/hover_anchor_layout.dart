part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/03
///
/// 支持在一个锚点[anchor]布局, 鼠标悬停显示提示或界面的布局
/// - 支持悬停显示
/// - 支持箭头显示
/// - 支持动画
/// - 支持手势区域共享
///
/// - [Tooltip]
///
/// - [AnchorOverlayLayout]
/// - [HoverAnchorLayout]
///
class HoverAnchorLayout extends StatefulWidget {
  /// 锚点布局
  final Widget anchor;

  /// 悬停/点击时显示的内容
  final Widget? content;

  /// [content]构建内容
  final WidgetNullBuilder? contentBuilder;

  /// 控制器
  final HoverAnchorLayoutController? controller;

  /// 显示/隐藏的状态回调
  final ValueCallback<bool>? onShowAction;

  //--

  /// 命中区域放大的溢出大小
  final double hitInflate;

  //--

  /// 背景色, 同时也是箭头的颜色
  @autoInjectMark
  final Color? backgroundColor;

  /// 背景阴影
  @autoInjectMark
  final List<BoxShadow>? backgroundShadows;

  /// 背景圆角大小
  final double radius;

  /// 是否显示箭头
  final bool showArrow;

  /// 是否显示阴影
  final bool showShadow;

  /// 强行指定箭头的位置, 不指定则自动计算位置
  @autoInjectMark
  final ArrowPosition? arrowPosition;

  /// 箭头的大小
  final Size arrowSize;

  /// 箭头额外的偏移量
  final double arrowOffset;

  /// 是否激活悬停时自动显示
  final bool enableHoverShow;

  /// 是否激活点击锚点显示
  final bool enableTapShow;

  /// 是否激活动画
  final bool enableAnimate;

  /// 是否激活点击后自动销毁
  final bool enableTapDismiss;

  //--

  /// 是否使用根Overlay
  final bool rootOverlay;

  /// 是否激活组件
  final bool enable;

  //--

  const HoverAnchorLayout({
    super.key,
    required this.anchor,
    this.controller,
    this.onShowAction,
    this.content,
    this.contentBuilder,
    this.backgroundColor,
    this.backgroundShadows,
    this.showArrow = true,
    this.showShadow = true,
    this.enableHoverShow = true,
    this.enableTapShow = false,
    this.enableAnimate = true,
    this.enableTapDismiss = false,
    this.arrowPosition,
    this.radius = kH,
    this.arrowSize = const Size(kX, kH),
    this.hitInflate = kM,
    this.arrowOffset = kM,
    //--
    this.rootOverlay = true,
    this.enable = true,
  });

  @override
  State<HoverAnchorLayout> createState() => _HoverAnchorLayoutState();
}

class _HoverAnchorLayoutState extends State<HoverAnchorLayout>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);

  final OverlayPortalController _overlayController = OverlayPortalController();

  //--

  AnimationController? _backingController;

  AnimationController get _controller {
    return _backingController ??= AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
  }

  CurvedAnimation? _backingOverlayAnimation;

  CurvedAnimation get _overlayAnimation {
    return _backingOverlayAnimation ??= CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  void _handleStatusChanged(AnimationStatus status) {
    assert(mounted);
    /*assert(() {
      l.d("动画状态->$status");
      return true;
    }());*/
    switch ((_animationStatus.isDismissed, status.isDismissed)) {
      case (false, true):
        //debugger();
        //_checkHideHoverLayout(false);
        _hideOverlay();
      case (true, false):
        _checkShowHoverLayout();
      case (true, true) || (false, false):
        break;
    }
    _animationStatus = status;
  }

  /// 隐藏浮窗
  void _hideOverlay() {
    _isShowHoverLayout = false;
    _overlayController.hide();
    widget.onShowAction?.call(false);
  }

  /// 显示浮窗
  void _showOverlay() {
    _isShowHoverLayout = true;
    _overlayController.show();
    widget.onShowAction?.call(true);
  }

  //--

  /// 是否激活当前的部件功能
  bool get isEnableLayout =>
      widget.content != null || widget.contentBuilder != null;

  @override
  void initState() {
    _initLayoutState();
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(
      _handleGlobalPointerEvent,
    );
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointerEvent,
    );
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HoverAnchorLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?._show = null;
    oldWidget.controller?._hide = null;
    oldWidget.controller?._toggle = null;
    _arrowPositionManager.isLoad = false;
    _initLayoutState();
  }

  /// 记录一下鼠标悬停的位置
  Offset? _mouseGlobalHoverPosition;

  /// 全局鼠标手势处理
  void _handleGlobalPointerEvent(PointerEvent event) {
    if (!widget.enable) {
      return;
    }
    //l.v("_handleGlobalPointerEvent->$event");
    if (event.isPointerHover) {
      _mouseGlobalHoverPosition = event.position;
      _arrowPositionManager.tempPosition = event.position;
      //l.v("_handleGlobalPointerEvent->$_mouseGlobalHoverPosition");
      if (_validHoverAreaList.isNotEmpty && widget.enableHoverShow) {
        _checkHideHoverLayout();
      }
    } else if (event.isPointerDown) {
      if (widget.enableTapShow) {
        _checkHideHoverLayout();
      }
    } else if (event.isPointerUp) {
      //l.v("_handleGlobalPointerEvent->$event $getAnchorGlobalBounds");
      if (!widget.enableHoverShow && widget.enableTapShow) {
        //激活点击显示
        if (getAnchorGlobalBounds?.contains(event.position) == true) {
          _checkShowHoverLayout();
        } else if (widget.enableTapDismiss) {
          _checkHideHoverLayout(false);
        }
      }
    }
  }

  void _initLayoutState() {
    widget.controller?._show = () {
      _checkShowHoverLayout();
    };
    widget.controller?._hide = () {
      _checkHideHoverLayout(false);
    };
    widget.controller?._toggle = () {
      if (_isShowHoverLayout) {
        //debugger();
        _checkHideHoverLayout(false);
      } else {
        _checkShowHoverLayout();
      }
    };
    if (isEnableLayout) {}
  }

  /// 是否已经显示了悬停布局
  bool _isShowHoverLayout = false;

  /// [TooltipState._handleMouseEnter]
  void _handleMouseEnter(PointerEnterEvent event) {
    if (!widget.enableHoverShow) {
      return;
    }
    _checkShowHoverLayout();
  }

  /// [TooltipState._handleMouseExit]
  void _handleMouseExit(PointerExitEvent event) {
    //l.i("_handleMouseExit");
    if (!widget.enableHoverShow) {
      return;
    }
    _checkHideHoverLayout();
  }

  void _checkShowHoverLayout() {
    if (_isShowHoverLayout) {
      return;
    }
    //debugger();
    //l.d("show->${nowTimeString()}");
    _showOverlay();
    if (widget.enableAnimate && isMounted) {
      _controller.forward();
    }
    /*postFrame(() {
      _isShowHoverLayout = true;
    });*/
  }

  void _checkHideHoverLayout([bool checkHoverArea = true]) {
    if (!_isShowHoverLayout) {
      return;
    }

    //debugger();
    if (checkHoverArea) {
      //l.d("$_validHoverArea" + " $_mouseGlobalHoverPosition");
      final hoverPosition = _mouseGlobalHoverPosition;
      if (hoverPosition != null &&
          (_anchorGlobalBounds
                      ?.inflate(widget.hitInflate)
                      .contains(hoverPosition) ==
                  true ||
              _validHoverAreaList.any(
                (element) =>
                    element.inflate(widget.hitInflate).contains(hoverPosition),
              ))) {
        // 鼠标悬停到悬停布局上, 不隐藏
        return;
      }

      //debugger();
      //l.i("hide:$_anchorGlobalBounds $_validHoverAreaList \n$hoverPosition");
    }
    //debugger();
    _isShowHoverLayout = false;
    if (widget.enableAnimate) {
      _controller.reverse();
    } else {
      _hideOverlay();
    }
  }

  /// 锚点的全局区域
  Rect? _anchorGlobalBounds;

  /// 有效鼠标hover区域集合
  final List<Rect> _validHoverAreaList = [];

  final ArrowPositionManager _arrowPositionManager = ArrowPositionManager();

  @override
  Widget build(BuildContext context) {
    if (!isEnableLayout) {
      return widget.anchor;
    }

    final child = widget.rootOverlay
        ? OverlayPortal.targetsRootOverlay(
            controller: _overlayController,
            overlayChildBuilder: _buildOverlayChild,
            child: widget.anchor,
          )
        : OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: _buildOverlayChild,
            child: widget.anchor,
          );

    return MouseRegion(
      onEnter: _handleMouseEnter,
      onExit: _handleMouseExit,
      child: child,
    );
  }

  /// 获取锚点在全局区域的位置
  Rect? get getAnchorGlobalBounds =>
      context.findRenderObject()?.getGlobalBounds();

  /// 获取锚点在当前[Overlay]窗口中的位置
  Rect? get getAnchorBounds => context.findRenderObject()?.getGlobalBounds(
    Overlay.maybeOf(
      context,
      rootOverlay: widget.rootOverlay,
    )?.context.findRenderObject(),
  );

  /// 构建悬浮布局
  Widget _buildOverlayChild(BuildContext ctx) {
    final overlayRender = Overlay.maybeOf(
      context,
      rootOverlay: widget.rootOverlay,
    )?.context.findRenderObject();
    final anchorRender = context.findRenderObject();
    final anchorGlobalBounds = anchorRender?.getGlobalBounds();
    _anchorGlobalBounds = anchorGlobalBounds;
    final anchorBounds = anchorRender?.getGlobalBounds(overlayRender);
    //l.d("anchorBounds:$anchorBounds");
    return _ArrowPositionWidget(
      showArrow: widget.showArrow,
      arrowPosition: widget.arrowPosition,
      arrowSize: widget.arrowSize,
      screenSize: overlayRender?.getSizeOrNull(),
      arrowOffset: widget.arrowOffset,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      backgroundShadows:
          widget.backgroundShadows ??
          (widget.showShadow
              ? const [
                  BoxShadow(
                    color: kShadowColor,
                    offset: kShadowOffset,
                    blurRadius: kDefaultBlurRadius,
                    spreadRadius: 2,
                  ),
                ]
              : null),
      anchorBounds: anchorBounds,
      radius: widget.radius,
      validHoverAreaList: _validHoverAreaList,
      arrowPositionManager: _arrowPositionManager,
      content: widget.content ?? widget.contentBuilder!(ctx),
      onPaintTransform: widget.enableAnimate
          ? (render, context, offset, size) {
              final value = _overlayAnimation
                  .tween(0.9, 1.0, curve: Curves.fastOutSlowIn)
                  .value;
              if (_controller.isAnimating) {
                //l.d("value->$value");
                render.postMarkNeedsPaint();
              }
              /*assert(() {
                l.d("${_arrowPositionManager.outputArrowBounds.center}");
                return true;
              }());*/
              return render.getEffectiveTransform(
                Matrix4.diagonal3Values(value, value, 1.0),
                origin: _arrowPositionManager.outputArrowBounds.center,
              );
            }
          : null,
    ).fadeTransition(widget.enableAnimate ? _overlayAnimation : null)
    /*.scaleTransition(
                  widget.enableAnimate ? _overlayAnimation : null,
                  from: 0.9,
                  to: 1,
                  alignment:
                      _arrowPositionManager.outputArrowPosition.alignment,
                )*/
    ;
  }
}

/// 箭头位置控制小部件
/// 用来放置箭头的位置, 和内容的位置
class _ArrowPositionWidget extends StatefulWidget {
  final ArrowPositionManager arrowPositionManager;
  final Widget? content;
  final Rect? anchorBounds;
  final double radius;
  final bool showArrow;
  final ArrowPosition? arrowPosition;
  final Size arrowSize;
  final Size? screenSize;
  final double arrowOffset;
  final Color backgroundColor;
  final List<BoxShadow>? backgroundShadows;
  @output
  final List<Rect> validHoverAreaList;

  final AnyWidgetPaintTransformAction? onPaintTransform;

  const _ArrowPositionWidget({
    super.key,
    this.showArrow = true,
    this.arrowPosition,
    this.content,
    this.anchorBounds,
    this.radius = 0,
    this.arrowOffset = 0,
    this.arrowSize = const Size(kX, kH),
    this.screenSize,
    this.backgroundColor = Colors.redAccent,
    this.backgroundShadows,
    this.onPaintTransform,
    required this.arrowPositionManager,
    required this.validHoverAreaList,
  });

  @override
  State<_ArrowPositionWidget> createState() => _ArrowPositionWidgetState();
}

class _ArrowPositionWidgetState extends State<_ArrowPositionWidget> {
  static const _kArrowTag = "arrow";
  static const _kContentTag = "content";

  ArrowPositionManager get _arrowPositionManager => widget.arrowPositionManager;

  @override
  void initState() {
    _arrowPositionManager.isLoad = false;
    super.initState();
  }

  @override
  void dispose() {
    _arrowPositionManager.isLoad = false;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ArrowPositionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _arrowPositionManager.isLoad = false;
  }

  @implementation
  Offset _parentOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    //debugger();
    //l.d("build...");
    return $anyContainer(
      onPaintTransform: widget.onPaintTransform,
      children: [
        if (widget.content != null)
          DecoratedBox(
            decoration: fillDecoration(
              color: widget.backgroundColor,
              borderRadius: _arrowPositionManager.outputRadius,
              boxShadow: widget.backgroundShadows,
            ),
            child: widget.content?.clip(
              borderRadius: _arrowPositionManager.outputRadius,
            ),
          ).anyParentData(
            left: _arrowPositionManager.outputContentRect.left,
            top: _arrowPositionManager.outputContentRect.top,
            visible: _arrowPositionManager.isLoad,
            tag: _kContentTag,
          ),
        //因为有阴影的存在, 所以...
        if (widget.showArrow)
          ArrowWidget(
            arrowPosition: _arrowPositionManager.outputArrowPosition,
            color: widget.backgroundColor,
            width: widget.arrowSize.width,
            height: widget.arrowSize.height,
            boxShadow: widget.backgroundShadows,
          ).anyParentData(
            left: _arrowPositionManager.outputArrowRect.left,
            top: _arrowPositionManager.outputArrowRect.top,
            visible: _arrowPositionManager.isLoad,
            tag: _kArrowTag,
          ),
      ],
      onLayout: (render, constraints, initResult) {
        widget.validHoverAreaList.clear();
        return null;
      },
      onGetChildOffset: (render, constraints, parentSize, childSize, parentData) {
        //debugger();
        if (!_arrowPositionManager.isLoad) {
          _arrowPositionManager.arrowSize = widget.showArrow
              ? widget.arrowSize
              : Size.zero;
          _arrowPositionManager.arrowOffset = widget.arrowOffset;
          _arrowPositionManager.screenSize = widget.screenSize ?? parentSize;
          _arrowPositionManager.contentSize = childSize;
          _arrowPositionManager.radius = Radius.circular(widget.radius);
          _arrowPositionManager.anchorBox = widget.anchorBounds ?? Rect.zero;
          //debugger(when: parentData.tag == null);
          _arrowPositionManager.load(
            isLoad: parentData.tag == _kContentTag,
            preferredPosition: widget.arrowPosition,
          );
          updateState();
        }

        //debugger();
        () {
          //l.d("nextMicrotask...");
          final parentOffset = render.getGlobalLocation() ?? Offset.zero;
          _parentOffset = parentOffset;
          if (parentData.tag == _kArrowTag) {
            final outputArrowBounds = _arrowPositionManager.outputArrowBounds;
            final childOffset = outputArrowBounds.lt;
            final rect = (parentOffset + childOffset) & outputArrowBounds.size;
            widget.validHoverAreaList.add(rect);
            //l.d("arrow->$rect ${_arrowPositionManager.outputArrowRect}->${_arrowPositionManager.outputArrowBounds}");
            //debugger();
          } else if (parentData.tag == _kContentTag) {
            final childOffset = _arrowPositionManager.outputContentRect.lt;
            final Rect rect = (parentOffset + childOffset) & childSize;
            //debugger(when: parentData.tag == "arrow");
            widget.validHoverAreaList.add(rect);
          }
          if (isDebug) {
            render.markNeedsPaint();
          }
        }.nextMicrotask();

        //l.w(widget.validHoverAreaList);
        return null;
      },
      /*onPaint: isDebug
          ? (render, canvas, size) {
              canvas.drawRect(
                widget.anchorBounds ?? Rect.zero,
                Paint()
                  ..color = Colors.redAccent
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
              );
              */
      /*for (final rect in widget.validHoverAreaList) {
                canvas.drawRect(
                  rect - _parentOffset,
                  Paint()
                    ..color = Colors.purpleAccent
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              }*/
      /*
              //canvas.drawCross(widget.arrowPositionManager.tempPosition - _parentOffset);
              //canvas.drawText("$_parentOffset");
              //render.postMarkNeedsPaint();
              //l.d("validHoverAreaList: ${widget.validHoverAreaList}");
            }
          : null,*/
    );
  }
}

/// 控制器
class HoverAnchorLayoutController {
  Action? _show;
  Action? _hide;
  Action? _toggle;

  @api
  void show() {
    assert(() {
      if (_show == null) {
        l.w("控制器未[attach]");
      }
      return true;
    }());
    _show?.call();
  }

  @api
  void toggle() {
    assert(() {
      if (_toggle == null) {
        l.w("控制器未[attach]");
      }
      return true;
    }());
    _toggle?.call();
  }

  @api
  void hide() {
    _hide?.call();
  }
}

//--

/// [_ExclusiveMouseRegion]
@fromFramework
class _ExclusiveMouseRegion extends MouseRegion {
  const _ExclusiveMouseRegion({super.onEnter, super.onExit, super.child});

  @override
  _RenderExclusiveMouseRegion createRenderObject(BuildContext context) {
    return _RenderExclusiveMouseRegion(onEnter: onEnter, onExit: onExit);
  }
}

/// [_RenderExclusiveMouseRegion]
@fromFramework
class _RenderExclusiveMouseRegion extends RenderMouseRegion {
  _RenderExclusiveMouseRegion({super.onEnter, super.onExit});

  static bool isOutermostMouseRegion = true;
  static bool foundInnermostMouseRegion = false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool isHit = false;
    final bool outermost = isOutermostMouseRegion;
    isOutermostMouseRegion = false;
    if (size.contains(position)) {
      isHit =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if ((isHit || behavior == HitTestBehavior.translucent) &&
          !foundInnermostMouseRegion) {
        foundInnermostMouseRegion = true;
        result.add(BoxHitTestEntry(this, position));
      }
    }

    if (outermost) {
      // The outermost region resets the global states.
      isOutermostMouseRegion = true;
      foundInnermostMouseRegion = false;
    }
    return isHit;
  }
}

//--

extension HoverAnchorLayoutEx on Widget {
  /// 使用[HoverAnchorLayout]实现的悬停提示功能
  /// - [tooltip] 提示内容小部件
  /// - [arrowPosition] 箭头位置
  Widget hoverTooltip(
    Widget? tooltip, {
    bool enable = true,
    //--
    ArrowPosition? arrowPosition,
    bool showArrow = true,
    //--
    bool showShadow = true,
    bool enableTapDismiss = false,
    Color? backgroundColor,
  }) => HoverAnchorLayout(
    anchor: this,
    content: tooltip,
    enable: enable,
    showShadow: showShadow,
    backgroundColor: backgroundColor,
    //--
    showArrow: showArrow,
    arrowPosition: arrowPosition,
    enableTapDismiss: enableTapDismiss,
  );

  /// 使用[HoverAnchorLayout]实现的悬停布局功能
  /// - [overlay] 浮窗内容小部件
  /// - [arrowPosition] 箭头位置
  Widget hoverLayout({
    Widget? overlay,
    WidgetNullBuilder? overlayBuilder,
    bool enable = true,
    ValueCallback<bool>? onShowAction,
    //--
    ArrowPosition? arrowPosition,
    bool showArrow = true,
    //--
    bool showShadow = true,
    Color? backgroundColor,
    //--
    bool enableHoverShow = false,
    bool enableTapTrigger = true,
    bool enableTapDismiss = true,
  }) => HoverAnchorLayout(
    anchor: this,
    onShowAction: onShowAction,
    content: overlay,
    contentBuilder: overlayBuilder,
    enable: enable,
    showShadow: showShadow,
    backgroundColor: backgroundColor,
    //--
    showArrow: showArrow,
    arrowPosition: arrowPosition,
    //--
    enableHoverShow: enableHoverShow,
    enableTapShow: enableTapTrigger,
    enableTapDismiss: enableTapDismiss,
  );
}
