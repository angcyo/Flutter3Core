part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/24
///
/// 画布缩放控制Tile
///
/// - [CanvasMonitorPainter]
class CanvasScaleRadioTile extends StatefulWidget {
  /// 核心对象
  final CanvasDelegate? canvasDelegate;

  const CanvasScaleRadioTile(this.canvasDelegate, {super.key});

  @override
  State<CanvasScaleRadioTile> createState() => _CanvasScaleRadioTileState();
}

class _CanvasScaleRadioTileState extends State<CanvasScaleRadioTile> {
  /// 画布监听
  late final canvasListener = CanvasListener(
    onCanvasViewBoxChangedAction: (viewBox, isInitialize, isCompleted) {
      updateState();
    },
  );

  /// 缩放比例列表
  late final scaleRadioList = [
    -1.0 /*自适应*/,
    0.25,
    0.5,
    0.75,
    1.0,
    1.5,
    2.0,
    4.0,
    6.0,
    8.0,
    10.0,
  ];

  @override
  void initState() {
    widget.canvasDelegate?.addCanvasListener(canvasListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.canvasDelegate?.removeCanvasListener(canvasListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lRes = libRes(context);
    final globalTheme = GlobalTheme.of(context);
    final canvasDelegate = widget.canvasDelegate;
    final viewBox = canvasDelegate?.canvasViewBox;
    final scaleText = stringBuilder((builder) {
      final sx = ((viewBox?.scaleX ?? 1.0) * 100).round();
      final sy = ((viewBox?.scaleY ?? 1.0) * 100).round();
      if (sx == sy) {
        builder.addText("$sx%");
      } else {
        builder.addText("$sx%/$sy%");
      }
    });
    return [
      Icon(Icons.remove).ib(() {
        canvasDelegate?.canvasKeyManager.zoomOut();
      }),
      DesktopIconMenuTile(
        iconWidget: scaleText.text(textStyle: globalTheme.textBodyStyle),
        popupBodyWidget: [
          for (final radio in scaleRadioList.reversed)
            DesktopIconMenuTile(
              mainAxisAlignment: .center,
              iconWidget: switch (radio) {
                -1.0 => lRes?.libCanvasAdaptive ?? "自适应",
                _ => "${(radio * 100).round()}%",
              }.text(textStyle: globalTheme.textBodyStyle, textAlign: .center),
              onTap: () {
                if (radio == -1.0) {
                  //canvasDelegate?.followPainter();
                  /*canvasDelegate?.canvasFollowManager.followCanvasContent(
                    restoreDef: true,
                  );*/
                  canvasDelegate?.followRect();
                } else {
                  canvasDelegate?.canvasViewBox.scaleTo(sx: radio, sy: radio);
                }
              },
            ),
        ].column()?.box(width: 100),
        popupAlignment: .topCenter,
      ),
      Icon(Icons.add).ib(() {
        canvasDelegate?.canvasKeyManager.zoomIn();
      }),
    ].row(mainAxisSize: .min)!;
  }
}
