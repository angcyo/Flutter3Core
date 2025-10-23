part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/13
///

/// 手势按下/抬起时的回调
typedef OnPointerDownAction = void Function(PointerEvent event, bool isDownIn);

/// 鼠标悬停改变的回调
typedef OnPointerHoverAction = void Function(PointerEvent event, bool isHover);

/// 不同状态下, 绘制不同背景的装饰小部件
/// [DecoratedBox]
/// [strokeDecoration]
/// [lineDecoration]
/// [fillDecoration]
/// [lineaGradientDecoration]
class StateDecorationWidget extends SingleChildRenderObjectWidget {
  //region ---正常状态↓---

  /// 正常状态下的背景装饰
  final Decoration? decoration;

  /// 正常状态下的前景装饰
  final Decoration? foregroundDecoration;

  //endregion ---正常状态↑---

  //region ---按下状态↓---

  /// 是否启用按下时的装饰
  final bool enablePressedDecoration;

  /// 按下时的背景装饰
  final Decoration? pressedDecoration;

  /// 按下时的前景装饰
  final Decoration? pressedForegroundDecoration;

  //endregion ---按下状态↑---

  //region ---选中状态↓---

  /// 是否启用选中时的装饰
  final bool enableSelectedDecoration;

  /// 选中时的背景装饰
  final Decoration? selectedDecoration;

  /// 选中时的前景装饰
  final Decoration? selectedForegroundDecoration;

  //endregion ---选中状态↑---
  //
  // region ---悬停状态↓---

  /// 是否启用悬停时的装饰
  final bool enableHoverDecoration;

  /// 悬停时的背景装饰
  final Decoration? hoverDecoration;

  /// 悬停时的前景装饰
  final Decoration? hoverForegroundDecoration;

  //endregion ---悬停状态↑---

  //region ---手势的回调---

  final OnPointerDownAction? onPointerDownAction;
  final OnPointerHoverAction? onPointerHoverAction;

  //endregion ---手势的回调---

  const StateDecorationWidget({
    super.key,
    super.child,
    this.decoration,
    this.foregroundDecoration,
    this.pressedDecoration,
    this.selectedDecoration,
    this.pressedForegroundDecoration,
    this.selectedForegroundDecoration,
    this.hoverDecoration,
    this.hoverForegroundDecoration,
    this.enablePressedDecoration = true,
    this.enableSelectedDecoration = true,
    this.enableHoverDecoration = true,
    this.onPointerDownAction,
    this.onPointerHoverAction,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderStateDecoration(
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        pressedDecoration: pressedDecoration,
        selectedDecoration: selectedDecoration,
        pressedForegroundDecoration: pressedForegroundDecoration,
        selectedForegroundDecoration: selectedForegroundDecoration,
        hoverDecoration: hoverDecoration,
        hoverForegroundDecoration: hoverForegroundDecoration,
        enablePressedDecoration: enablePressedDecoration,
        enableSelectedDecoration: enableSelectedDecoration,
        enableHoverDecoration: enableHoverDecoration,
        onPointerDownAction: onPointerDownAction,
        onPointerHoverAction: onPointerHoverAction,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderStateDecoration renderObject,
  ) {
    renderObject
      ..clearPainters()
      ..decoration = decoration
      ..foregroundDecoration = foregroundDecoration
      ..pressedDecoration = pressedDecoration
      ..selectedDecoration = selectedDecoration
      ..pressedForegroundDecoration = pressedForegroundDecoration
      ..selectedForegroundDecoration = selectedForegroundDecoration
      ..hoverDecoration = hoverDecoration
      ..hoverForegroundDecoration = hoverForegroundDecoration
      ..enablePressedDecoration = enablePressedDecoration
      ..enableSelectedDecoration = enableSelectedDecoration
      ..enableHoverDecoration = enableHoverDecoration
      ..onPointerDownAction = onPointerDownAction
      ..onPointerHoverAction = onPointerHoverAction
      ..markNeedsPaint();
  }
}

/// [RenderDecoratedBox]
class _RenderStateDecoration extends RenderProxyBoxWithHitTestBehavior
    implements MouseTrackerAnnotation {
  Decoration? decoration;
  BoxPainter? _painter;

  Decoration? foregroundDecoration;
  BoxPainter? _foregroundPainter;

  //--悬停样式
  bool enableHoverDecoration;
  Decoration? hoverDecoration;
  BoxPainter? _hoverPainter;
  Decoration? hoverForegroundDecoration;
  BoxPainter? _hoverForegroundPainter;

  //--按下样式
  bool enablePressedDecoration;
  Decoration? pressedDecoration;
  BoxPainter? _pressedPainter;
  Decoration? pressedForegroundDecoration;
  BoxPainter? _pressedForegroundPainter;

  //--选中样式
  bool enableSelectedDecoration;
  Decoration? selectedDecoration;
  BoxPainter? _selectedPainter;
  Decoration? selectedForegroundDecoration;
  BoxPainter? _selectedForegroundPainter;

  OnPointerDownAction? onPointerDownAction;
  OnPointerHoverAction? onPointerHoverAction;

  ImageConfiguration configuration = ImageConfiguration.empty;

  @override
  HitTestBehavior behavior;

  _RenderStateDecoration({
    RenderBox? child,
    this.behavior = HitTestBehavior.translucent,
    this.decoration,
    this.foregroundDecoration,
    //--
    this.enableHoverDecoration = true,
    this.hoverDecoration,
    this.hoverForegroundDecoration,
    //--
    this.enablePressedDecoration = true,
    this.pressedDecoration,
    this.pressedForegroundDecoration,
    //--
    this.enableSelectedDecoration = true,
    this.selectedDecoration,
    this.selectedForegroundDecoration,
    //--
    this.onPointerDownAction,
    this.onPointerHoverAction,
  }) : super(child: child, behavior: behavior);

  ///
  @override
  void performLayout() {
    super.performLayout();
  }

  @override
  bool hitTestSelf(ui.Offset position) =>
      enableHoverDecoration ||
      enablePressedDecoration ||
      onPointerDownAction != null;

  bool _isHover = false;
  bool _isPointerDown = false;
  Offset? _pointerDown;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      if (enableHoverDecoration && !_isHover) {
        _isHover = true;
        markNeedsPaint();
        onPointerHoverAction?.call(event, _isHover);
      }
    } else if (event is PointerDownEvent) {
      if (enablePressedDecoration) {
        _isPointerDown = true;
        _pointerDown = event.localPosition;
        markNeedsPaint();
      }
      onPointerDownAction?.call(event, true);
    } else if (event is PointerMoveEvent) {
      if (_isPointerDown && event.isMoveExceed(_pointerDown)) {
        _isPointerDown = false;
        markNeedsPaint();
      }
    } else if (_isPointerDown &&
        (event is PointerUpEvent || event is PointerCancelEvent)) {
      if (enablePressedDecoration) {
        _isPointerDown = false;
        markNeedsPaint();
      }
      onPointerDownAction?.call(event, false);
    }
    super.handleEvent(event, entry);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final ImageConfiguration filledConfiguration = configuration.copyWith(
      size: size,
    );
    //背景绘制
    _painter ??= decoration?.createBoxPainter(markNeedsPaint);
    _painter?.paint(context.canvas, offset, filledConfiguration);
    setCanvasIsComplexHint(context, decoration);
    if (_isHover) {
      //
      _hoverPainter ??= hoverDecoration?.createBoxPainter(markNeedsPaint);
      _hoverPainter?.paint(context.canvas, offset, filledConfiguration);
      setCanvasIsComplexHint(context, hoverDecoration);
    }
    if (_isPointerDown) {
      //
      _pressedPainter ??= pressedDecoration?.createBoxPainter(markNeedsPaint);
      _pressedPainter?.paint(context.canvas, offset, filledConfiguration);
      setCanvasIsComplexHint(context, pressedDecoration);
    }
    //
    if (enableSelectedDecoration) {
      _selectedPainter ??= selectedDecoration?.createBoxPainter(markNeedsPaint);
      _selectedPainter?.paint(context.canvas, offset, filledConfiguration);
      setCanvasIsComplexHint(context, selectedDecoration);
    }
    super.paint(context, offset);
    //前景绘制
    if (_isHover) {
      //
      _hoverForegroundPainter ??= hoverForegroundDecoration?.createBoxPainter(
        markNeedsPaint,
      );
      _hoverForegroundPainter?.paint(
        context.canvas,
        offset,
        filledConfiguration,
      );
      setCanvasIsComplexHint(context, hoverForegroundDecoration);
    }
    if (_isPointerDown) {
      //
      _pressedForegroundPainter ??= pressedForegroundDecoration
          ?.createBoxPainter(markNeedsPaint);
      _pressedForegroundPainter?.paint(
        context.canvas,
        offset,
        filledConfiguration,
      );
      setCanvasIsComplexHint(context, pressedForegroundDecoration);
    }
    //
    if (enableSelectedDecoration) {
      _selectedForegroundPainter ??= selectedForegroundDecoration
          ?.createBoxPainter(markNeedsPaint);
      _selectedForegroundPainter?.paint(
        context.canvas,
        offset,
        filledConfiguration,
      );
      setCanvasIsComplexHint(context, selectedForegroundDecoration);
    }
    //
    _foregroundPainter ??= foregroundDecoration?.createBoxPainter(
      markNeedsPaint,
    );
    _foregroundPainter?.paint(context.canvas, offset, filledConfiguration);
    setCanvasIsComplexHint(context, foregroundDecoration);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _validForMouseTracker = true;
  }

  @override
  void detach() {
    _validForMouseTracker = false;
    clearPainters();
    super.detach();
  }

  @override
  void dispose() {
    clearPainters();
    super.dispose();
  }

  void clearPainters() {
    _painter?.dispose();
    _painter = null;
    _foregroundPainter?.dispose();
    _foregroundPainter = null;

    _pressedPainter?.dispose();
    _pressedPainter = null;
    _pressedForegroundPainter?.dispose();
    _pressedForegroundPainter = null;

    _selectedPainter?.dispose();
    _selectedPainter = null;
    _selectedForegroundPainter?.dispose();
    _selectedForegroundPainter = null;

    _hoverPainter?.dispose();
    _hoverPainter = null;
    _hoverForegroundPainter?.dispose();
    _selectedForegroundPainter = null;
  }

  void _handlePointerEnter(PointerEnterEvent event) {
    if (!_isHover) {
      _isHover = true;
      markNeedsPaint();
      onPointerHoverAction?.call(event, _isHover);
      /*postFrame(() {
        markNeedsPaint();
      });*/
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    if (_isHover) {
      _isHover = false;
      markNeedsPaint();
      onPointerHoverAction?.call(event, _isHover);
      /*postFrame(() {
        markNeedsPaint();
      });*/
    }
  }

  //region --Mouse--

  bool _validForMouseTracker = false;

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => _handlePointerEnter;

  @override
  PointerExitEventListener? get onExit => _handlePointerExit;

  @override
  bool get validForMouseTracker =>
      _validForMouseTracker && enableHoverDecoration;

  //endregion --Mouse--
}

extension StateDecorationWidgetEx on Widget {
  /// 状态装饰
  /// [decoration] 默认情况下的背景装饰
  /// [foregroundDecoration] 默认情况下的前景装饰
  /// [pressedDecoration] 按下时的背景装饰
  /// [selectedDecoration] 选中时的背景装饰
  /// [StateDecorationWidget]
  Widget stateDecoration(
    Decoration? decoration, {
    Decoration? foregroundDecoration,
    Decoration? pressedDecoration,
    Decoration? selectedDecoration,
    Decoration? hoverDecoration,
    bool enableSelectedDecoration = true,
    bool enableHoverDecoration = true,
    bool enablePressedDecoration = true,
  }) {
    return StateDecorationWidget(
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      pressedDecoration: pressedDecoration,
      selectedDecoration: selectedDecoration,
      hoverDecoration: hoverDecoration,
      enablePressedDecoration: enablePressedDecoration,
      enableSelectedDecoration: enableSelectedDecoration,
      enableHoverDecoration: enableHoverDecoration,
      child: this,
    );
  }

  /// [backgroundDecoration]
  Widget backgroundColor(
    Color? fillColor, {
    Key? key,
    double? fillRadius,
    //--
    Color? strokeColor,
    double strokeWidth = 1,
    BorderStyle strokeStyle = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
    //--
    bool clip = false,
  }) => backgroundDecoration(
    null,
    key: key,
    fillColor: fillColor,
    fillRadius: fillRadius,
    //--
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    strokeStyle: strokeStyle,
    strokeAlign: strokeAlign,
  );

  /// 绘制背景
  /// [fillColor] 使用纯色填充背景
  ///
  /// [fillDecoration] 填充装饰
  /// [strokeDecoration] 描边装饰
  ///
  /// [StateDecorationWidget]
  /// [Decoration]
  /// [fillDecoration]
  Widget backgroundDecoration(
    Decoration? decoration, {
    Key? key,
    Color? fillColor,
    double? fillRadius,
    //--
    Color? strokeColor,
    double strokeWidth = 1,
    BorderStyle strokeStyle = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
    //--
    Decoration? foregroundDecoration,
    Decoration? pressedDecoration,
    Decoration? selectedDecoration,
    bool enablePressedDecoration = true,
    //--
    bool clip = false,
  }) {
    final BorderSide? strokeSide = strokeColor == null
        ? null
        : BorderSide(
            color: strokeColor,
            width: strokeWidth,
            style: strokeStyle,
            strokeAlign: strokeAlign,
          );

    final borderRadius = fillRadius == null
        ? null
        : BorderRadius.circular(fillRadius);
    decoration ??= fillColor == null
        ? null
        : BoxDecoration(
            color: fillColor,
            borderRadius: borderRadius,
            //--
            border: strokeSide == null
                ? null
                : BorderDirectional(
                    top: strokeSide,
                    bottom: strokeSide,
                    start: strokeSide,
                    end: strokeSide,
                  ),
          );
    if (decoration == null) {
      return this;
    }
    return StateDecorationWidget(
      key: key,
      decoration: decoration,
      //--
      foregroundDecoration: foregroundDecoration,
      pressedDecoration: pressedDecoration,
      selectedDecoration: selectedDecoration,
      enablePressedDecoration: enablePressedDecoration,
      child: this,
    ).clipRadius(
      enable: clip && borderRadius != null,
      borderRadius: borderRadius,
    );
  }
}
