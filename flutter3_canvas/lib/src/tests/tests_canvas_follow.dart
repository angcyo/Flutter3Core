part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/10/27
///
/// 测试[CanvasFollowManager]
class CanvasFollowTestDialog extends StatefulWidget with DialogMixin {
  /// 核心对象
  final CanvasDelegate? canvasDelegate;

  const CanvasFollowTestDialog(this.canvasDelegate, {super.key});

  @override
  State<CanvasFollowTestDialog> createState() => _CanvasFollowTestDialogState();
}

class _CanvasFollowTestDialogState extends State<CanvasFollowTestDialog> {
  /// 是否需要动画
  bool _animate = true;

  /// 是否需要外边距
  bool _margin = true;

  final EdgeInsets _followMargin = const EdgeInsets.only(
    left: 10,
    top: 10,
    right: 20,
    bottom: 20,
  );

  Alignment? _alignment = Alignment.center;
  BoxFit? _fit = BoxFit.contain;

  final List<Alignment> _alignmentList = [
    Alignment.center,
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
    Alignment.centerLeft,
    Alignment.centerRight,
  ];

  final List<BoxFit> _fitList = [
    BoxFit.contain,
    BoxFit.cover,
    BoxFit.fill,
    BoxFit.fitWidth,
    BoxFit.fitHeight,
    BoxFit.scaleDown,
    BoxFit.none,
  ];

  CanvasDelegate? get canvasDelegate => widget.canvasDelegate;

  PathElementPainter painter = PathElementPainter()
    ..paintColor = Colors.purpleAccent
    ..paintStrokeWidthSuppressCanvasScale = true;

  @override
  void initState() {
    canvasDelegate?.canvasElementManager.addAfterElement(painter);
    _alignment = canvasDelegate?.canvasFollowManager.alignment ?? _alignment;
    _fit = canvasDelegate?.canvasFollowManager.fit ?? _fit;
    super.initState();
  }

  @override
  void dispose() {
    canvasDelegate?.canvasElementManager.removeAfterElement(painter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentManager = canvasDelegate?.canvasPaintManager.contentManager;
    final canvasFollowManager = canvasDelegate?.canvasFollowManager;
    return widget.buildBottomChildrenDialog(context, [
      [
        //--
        DropdownButtonTile(
          label: "fit",
          dropdownValue: _fit,
          dropdownValueList: _fitList,
          mainAxisSize: MainAxisSize.min,
          onChanged: (value) {
            Feedback.forLongPress(context);
            _fit = value;
            updateState();
          },
        ),
        DropdownButtonTile(
          label: "alignment",
          dropdownValue: _alignment,
          dropdownValueList: _alignmentList,
          mainAxisSize: MainAxisSize.min,
          onChanged: (value) {
            Feedback.forLongPress(context);
            _alignment = value;
            updateState();
          },
        ),
        CheckboxTile(
            value: _animate,
            text: "动画",
            normalWidth: null,
            mainAxisSize: MainAxisSize.min,
            onChanged: (value) {
              _animate = value!;
            }),
        CheckboxTile(
            value: _margin,
            text: "边距",
            normalWidth: null,
            mainAxisSize: MainAxisSize.min,
            onChanged: (value) {
              _margin = value!;
            }),
        //--
        GradientButton.normal(() {
          contentManager?.followCanvasContentTemplate(animate: _animate);
        }, child: "恢复默认跟随".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 400, 300).toRectDp();
          _followRect(rect);
        }, child: "大wh".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 20, 40).toRectDp();
          _followRect(rect);
        }, child: "小wh".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 60, 30).toRectDp();
          _followRect(rect);
        }, child: "小wh2".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 100, 200).toRectDp();
          _followRect(rect);
        }, child: "test".text()),
        GradientButton.normal(() {
          canvasDelegate?.canvasViewBox.translateBy(-100, 0);
        }, child: "平移x-100".text()),
        GradientButton.normal(() {
          canvasDelegate?.canvasViewBox.translateBy(100, 0);
        }, child: "平移x+100".text()),
        GradientButton.normal(() {
          canvasDelegate?.canvasViewBox.translateBy(0, 100);
        }, child: "平移y+100".text()),
        GradientButton.normal(() {
          canvasDelegate?.canvasViewBox.translateBy(0, -100);
        }, child: "平移y-100".text()),
      ]
          .flowLayout(childGap: kH, padding: const EdgeInsets.all(kH))
          ?.size(width: double.infinity),
    ]);
  }

  ///
  void _followRect(Rect rect) {
    final canvasFollowManager = canvasDelegate?.canvasFollowManager;
    painter.initFromPath(rect.toPath());
    canvasFollowManager?.followRect(
      rect,
      fit: _fit,
      alignment: _alignment,
      margin: _margin ? _followMargin : EdgeInsets.zero,
      animate: _animate,
    );
  }
}
