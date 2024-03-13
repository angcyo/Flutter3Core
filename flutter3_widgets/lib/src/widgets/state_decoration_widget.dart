part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/13
///

/// 手势按下/抬起时的回调
typedef OnPointerDownAction = void Function(PointerEvent event, bool isDownIn);

/// 不同状态下, 绘制不同背景的装饰小部件
/// [DecoratedBox]
class StateDecorationWidget extends SingleChildRenderObjectWidget {
  /// 是否启用按下时的装饰
  final bool enablePressedDecoration;

  /// 是否启用选中时的装饰
  final bool enableSelectedDecoration;

  /// 按下时的背景装饰
  final Decoration? pressedDecoration;

  /// 选中时的背景装饰
  final Decoration? selectedDecoration;

  /// 按下时的前景装饰
  final Decoration? pressedForegroundDecoration;

  /// 选中时的前景装饰
  final Decoration? selectedForegroundDecoration;

  final OnPointerDownAction? onPointerDownAction;

  const StateDecorationWidget({
    super.key,
    super.child,
    this.pressedDecoration,
    this.selectedDecoration,
    this.pressedForegroundDecoration,
    this.selectedForegroundDecoration,
    this.onPointerDownAction,
    this.enablePressedDecoration = true,
    this.enableSelectedDecoration = true,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderStateDecoration(
        pressedDecoration: pressedDecoration,
        selectedDecoration: selectedDecoration,
        pressedForegroundDecoration: pressedForegroundDecoration,
        selectedForegroundDecoration: selectedForegroundDecoration,
        onPointerDownAction: onPointerDownAction,
        enablePressedDecoration: enablePressedDecoration,
        enableSelectedDecoration: enableSelectedDecoration,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderStateDecoration renderObject) {
    renderObject
      ..clearPainters()
      ..pressedDecoration = pressedDecoration
      ..selectedDecoration = selectedDecoration
      ..pressedForegroundDecoration = pressedForegroundDecoration
      ..selectedForegroundDecoration = selectedForegroundDecoration
      ..onPointerDownAction = onPointerDownAction
      ..enablePressedDecoration = enablePressedDecoration
      ..enableSelectedDecoration = enableSelectedDecoration
      ..markNeedsPaint();
  }
}

/// [RenderDecoratedBox]
class _RenderStateDecoration extends RenderProxyBox {
  bool enablePressedDecoration;
  bool enableSelectedDecoration;

  Decoration? pressedDecoration;
  BoxPainter? _pressedPainter;

  Decoration? selectedDecoration;
  BoxPainter? _selectedPainter;

  Decoration? pressedForegroundDecoration;
  BoxPainter? _pressedForegroundPainter;

  Decoration? selectedForegroundDecoration;
  BoxPainter? _selectedForegroundPainter;

  OnPointerDownAction? onPointerDownAction;

  ImageConfiguration configuration = ImageConfiguration.empty;

  _RenderStateDecoration({
    RenderBox? child,
    this.pressedDecoration,
    this.selectedDecoration,
    this.pressedForegroundDecoration,
    this.selectedForegroundDecoration,
    this.onPointerDownAction,
    this.enablePressedDecoration = true,
    this.enableSelectedDecoration = true,
  }) : super(child);

  @override
  void performLayout() {
    super.performLayout();
  }

  @override
  bool hitTestSelf(ui.Offset position) =>
      enablePressedDecoration || onPointerDownAction != null;

  bool _isPointerDown = false;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (enablePressedDecoration) {
        _isPointerDown = true;
        markNeedsPaint();
      }
      onPointerDownAction?.call(event, true);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
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
    final ImageConfiguration filledConfiguration =
        configuration.copyWith(size: size);
    //背景绘制
    if (_isPointerDown) {
      _pressedPainter ??= pressedDecoration?.createBoxPainter(markNeedsPaint);
      _pressedPainter?.paint(context.canvas, offset, filledConfiguration);
      setIsComplexHint(context, pressedDecoration);
    }
    _selectedPainter ??= selectedDecoration?.createBoxPainter(markNeedsPaint);
    _selectedPainter?.paint(context.canvas, offset, filledConfiguration);
    setIsComplexHint(context, selectedDecoration);
    super.paint(context, offset);
    //前景绘制
    if (_isPointerDown) {
      _pressedForegroundPainter ??=
          pressedForegroundDecoration?.createBoxPainter(markNeedsPaint);
      _pressedForegroundPainter?.paint(
          context.canvas, offset, filledConfiguration);
      setIsComplexHint(context, pressedForegroundDecoration);
    }
    _selectedForegroundPainter ??=
        selectedForegroundDecoration?.createBoxPainter(markNeedsPaint);
    _selectedForegroundPainter?.paint(
        context.canvas, offset, filledConfiguration);
    setIsComplexHint(context, selectedForegroundDecoration);
  }

  @override
  void detach() {
    clearPainters();
    super.detach();
    markNeedsPaint();
  }

  @override
  void dispose() {
    clearPainters();
    super.dispose();
  }

  void clearPainters() {
    _pressedPainter?.dispose();
    _pressedPainter = null;
    _selectedPainter?.dispose();
    _selectedPainter = null;
    _pressedForegroundPainter?.dispose();
    _pressedForegroundPainter = null;
    _selectedForegroundPainter?.dispose();
    _selectedForegroundPainter = null;
  }

  void setIsComplexHint(PaintingContext context, Decoration? decoration) {
    if (decoration != null) {
      if (decoration.isComplex) {
        context.setIsComplexHint();
      }
    }
  }
}
