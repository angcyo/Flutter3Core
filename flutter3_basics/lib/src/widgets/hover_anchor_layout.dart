part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/03
///
/// 支持在一个锚点[anchor]布局, 鼠标悬停显示提示或界面的布局
///
/// [Tooltip]
///
class HoverAnchorLayout extends StatefulWidget {
  /// 锚点布局
  final Widget anchor;

  /// 悬停/点击时显示的内容
  final Widget? content;

  //--

  /// 命中区域放大的溢出大小
  final double hitInflate;

  //--

  /// 背景色, 同时也是箭头的颜色
  final Color backgroundColor;

  /// 背景阴影
  final List<BoxShadow>? backgroundShadows;

  /// 背景圆角大小
  final double radius;

  /// 强行指定箭头的位置, 不指定则自动计算位置
  @autoInjectMark
  final ArrowPosition? arrowPosition;

  /// 箭头的大小
  final Size arrowSize;

  /// 箭头额外的偏移量
  final double arrowOffset;

  const HoverAnchorLayout({
    super.key,
    required this.anchor,
    this.content,
    this.backgroundColor = Colors.white,
    this.backgroundShadows = const [
      BoxShadow(
        color: kShadowColor,
        offset: kShadowOffset,
        blurRadius: kDefaultBlurRadius,
        spreadRadius: 2,
      ),
    ],
    this.arrowPosition,
    this.radius = kH,
    this.arrowSize = const Size(kX, kH),
    this.hitInflate = kM,
    this.arrowOffset = 30 /*kM*/,
  });

  @override
  State<HoverAnchorLayout> createState() => _HoverAnchorLayoutState();
}

class _HoverAnchorLayoutState extends State<HoverAnchorLayout> {
  final OverlayPortalController controller = OverlayPortalController();

  /// 是否激活当前的部件功能
  bool get isEnable => widget.content != null;

  @override
  void initState() {
    _initLayoutState();
    super.initState();
    GestureBinding.instance.pointerRouter
        .addGlobalRoute(_handleGlobalPointerEvent);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_handleGlobalPointerEvent);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HoverAnchorLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initLayoutState();
  }

  /// 记录一下鼠标悬停的位置
  Offset? _mouseGlobalHoverPosition;

  void _handleGlobalPointerEvent(PointerEvent event) {
    //l.v("_handleGlobalPointerEvent->$event");
    if (event is PointerHoverEvent) {
      _mouseGlobalHoverPosition = event.position;
      //l.v("_handleGlobalPointerEvent->$_mouseGlobalHoverPosition");
      if (_validHoverAreaList.isNotEmpty) {
        _checkHideHoverLayout();
      }
    }
  }

  void _initLayoutState() {
    if (isEnable) {}
  }

  /// 是否已经显示了悬停布局
  bool _isShowHoverLayout = false;

  /// [TooltipState._handleMouseEnter]
  void _handleMouseEnter(PointerEnterEvent event) {
    if (_isShowHoverLayout) {
      return;
    }
    //l.d("show->${nowTimeString()}");
    controller.show();
    _isShowHoverLayout = true;
    /*postFrame(() {
      _isShowHoverLayout = true;
    });*/
  }

  /// [TooltipState._handleMouseExit]
  void _handleMouseExit(PointerExitEvent event) {
    //l.i("_handleMouseExit");
    _checkHideHoverLayout();
  }

  void _checkHideHoverLayout() {
    if (!_isShowHoverLayout) {
      return;
    }
    //l.d("$_validHoverArea" + " $_mouseGlobalHoverPosition");
    final hoverPosition = _mouseGlobalHoverPosition;
    if (hoverPosition != null &&
        (_anchorGlobalBounds
                    ?.inflate(widget.hitInflate)
                    .contains(hoverPosition) ==
                true ||
            _validHoverAreaList.any((element) =>
                element.inflate(widget.hitInflate).contains(hoverPosition)))) {
      // 鼠标悬停到悬停布局上, 不隐藏
      return;
    }
    //debugger();

    //l.i("hide:$_anchorGlobalBounds $_validHoverAreaList \n$hoverPosition");
    _isShowHoverLayout = false;
    controller.hide();
  }

  /// 锚点的全局区域
  Rect? _anchorGlobalBounds;

  /// 有效鼠标hover区域集合
  final List<Rect> _validHoverAreaList = [];

  @override
  Widget build(BuildContext context) {
    if (!isEnable) {
      return widget.anchor;
    }
    return MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: OverlayPortal(
          controller: controller,
          overlayChildBuilder: (ctx) {
            final anchorGlobalBounds =
                context.findRenderObject()?.getGlobalBounds();
            _anchorGlobalBounds = anchorGlobalBounds;
            final anchorBounds = context.findRenderObject()?.getGlobalBounds(
                  Overlay.maybeOf(context)?.context.findRenderObject(),
                );
            //l.d("anchorBounds:$anchorBounds");
            return _ArrowPositionWidget(
              arrowPosition: widget.arrowPosition,
              arrowSize: widget.arrowSize,
              arrowOffset: widget.arrowOffset,
              backgroundColor: widget.backgroundColor,
              backgroundShadows: widget.backgroundShadows,
              anchorBounds: anchorBounds,
              radius: widget.radius,
              validHoverAreaList: _validHoverAreaList,
              content: widget.content,
            );
          },
          child: widget.anchor,
        ));
  }
}

/// 箭头位置控制小部件
/// 用来放置箭头的位置, 和内容的位置
class _ArrowPositionWidget extends StatefulWidget {
  final Widget? content;
  final Rect? anchorBounds;
  final double radius;
  final ArrowPosition? arrowPosition;
  final Size arrowSize;
  final double arrowOffset;
  final Color backgroundColor;
  final List<BoxShadow>? backgroundShadows;
  @output
  final List<Rect> validHoverAreaList;

  const _ArrowPositionWidget({
    super.key,
    this.arrowPosition,
    this.content,
    this.anchorBounds,
    this.radius = 0,
    this.arrowOffset = 0,
    this.arrowSize = const Size(kX, kH),
    this.backgroundColor = Colors.redAccent,
    this.backgroundShadows,
    required this.validHoverAreaList,
  });

  @override
  State<_ArrowPositionWidget> createState() => _ArrowPositionWidgetState();
}

class _ArrowPositionWidgetState extends State<_ArrowPositionWidget> {
  final ArrowPositionManager _arrowPositionManager = ArrowPositionManager();

  @override
  void initState() {
    _arrowPositionManager.isLoad = false;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ArrowPositionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _arrowPositionManager.isLoad = false;
  }

  Offset _parentOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    //debugger();
    return $anyContainer(
      children: [
        ArrowWidget(
          arrowPosition: _arrowPositionManager.outputArrowPosition,
          color: widget.backgroundColor,
          width: widget.arrowSize.width,
          height: widget.arrowSize.height,
        ).anyParentData(
          left: _arrowPositionManager.outputArrowRect.left,
          top: _arrowPositionManager.outputArrowRect.top,
          visible: _arrowPositionManager.isLoad,
          tag: "arrow",
        ),
        if (widget.content != null)
          DecoratedBox(
            decoration: fillDecoration(
              color: widget.backgroundColor,
              borderRadius: _arrowPositionManager.outputRadius,
              boxShadow: [
                BoxShadow(
                  color: kShadowColor,
                  offset: kShadowOffset,
                  blurRadius: kDefaultBlurRadius,
                  spreadRadius: 2,
                )
              ],
            ),
            child: widget.content,
          ).anyParentData(
            left: _arrowPositionManager.outputContentRect.left,
            top: _arrowPositionManager.outputContentRect.top,
            visible: _arrowPositionManager.isLoad,
          ),
      ],
      onLayout: (render, constraints, initResult) {
        widget.validHoverAreaList.clear();
        return null;
      },
      onGetChildOffset:
          (render, constraints, parentSize, childSize, parentData) {
        //debugger();
        if (!_arrowPositionManager.isLoad) {
          _arrowPositionManager.arrowSize = widget.arrowSize;
          _arrowPositionManager.arrowOffset = widget.arrowOffset;
          _arrowPositionManager.screenSize = parentSize;
          _arrowPositionManager.contentSize = childSize;
          _arrowPositionManager.radius = Radius.circular(widget.radius);
          _arrowPositionManager.anchorBox = widget.anchorBounds ?? Rect.zero;
          //debugger(when: parentData.tag == null);
          _arrowPositionManager.load(
            isLoad: parentData.tag == null,
            preferredPosition: widget.arrowPosition,
          );
          updateState();
        }

        final parentOffset = render.getGlobalLocation() ?? Offset.zero;
        _parentOffset = parentOffset;
        if (parentData.tag == "arrow") {
          final outputArrowBounds = _arrowPositionManager.outputArrowBounds;
          final childOffset = outputArrowBounds.lt;
          final rect = (parentOffset + childOffset) & outputArrowBounds.size;
          widget.validHoverAreaList.add(rect);
          //debugger();
        } else {
          final childOffset = _arrowPositionManager.outputContentRect.lt;
          final Rect rect = (parentOffset + childOffset) & childSize;
          //debugger(when: parentData.tag == "arrow");
          widget.validHoverAreaList.add(rect);
        }

        //l.w(widget.validHoverAreaList);
        return null;
      },
      onPaint: isDebug
          ? (render, canvas, size) {
              canvas.drawRect(
                widget.anchorBounds ?? Rect.zero,
                Paint()
                  ..color = Colors.redAccent
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
              );
              for (final rect in widget.validHoverAreaList) {
                canvas.drawRect(
                  rect - _parentOffset,
                  Paint()
                    ..color = Colors.purpleAccent
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              }
            }
          : null,
    );
  }
}

//--

/// [_ExclusiveMouseRegion]
@fromFramework
class _ExclusiveMouseRegion extends MouseRegion {
  const _ExclusiveMouseRegion({
    super.onEnter,
    super.onExit,
    super.child,
  });

  @override
  _RenderExclusiveMouseRegion createRenderObject(BuildContext context) {
    return _RenderExclusiveMouseRegion(
      onEnter: onEnter,
      onExit: onExit,
    );
  }
}

/// [_RenderExclusiveMouseRegion]
@fromFramework
class _RenderExclusiveMouseRegion extends RenderMouseRegion {
  _RenderExclusiveMouseRegion({
    super.onEnter,
    super.onExit,
  });

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
