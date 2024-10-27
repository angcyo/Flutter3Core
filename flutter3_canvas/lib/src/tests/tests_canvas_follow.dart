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

  CanvasDelegate? get canvasDelegate => widget.canvasDelegate;

  PathElementPainter painter = PathElementPainter()
    ..paintStrokeWidthSuppressCanvasScale = true;

  @override
  void initState() {
    canvasDelegate?.canvasElementManager.addAfterElement(painter);
    super.initState();
  }

  @override
  void dispose() {
    canvasDelegate?.canvasElementManager.removeAfterElement(painter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasFollowManager = canvasDelegate?.canvasFollowManager;
    return widget.buildBottomChildrenDialog(context, [
      [
        CheckboxTile(
            value: _animate,
            text: "动画",
            normalWidth: null,
            mainAxisSize: MainAxisSize.min,
            onChanged: (value) {
              _animate = value!;
            }),
        GradientButton.normal(() {}, child: "恢复默认跟随".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 600, 800).toRectDp();
          painter.initFromPath(rect.toPath());
          canvasFollowManager?.followRect(
            rect,
            animate: _animate,
          );
        }, child: "大wh".text()),
        GradientButton.normal(() {
          final rect = const Rect.fromLTWH(0, 0, 100, 200).toRectDp();
          painter.initFromPath(rect.toPath());
          canvasFollowManager?.followRect(
            rect,
            animate: _animate,
          );
        }, child: "小wh".text()),
      ]
          .flowLayout(childGap: kH, padding: const EdgeInsets.all(kH))
          ?.size(width: double.infinity),
    ]);
  }
}
