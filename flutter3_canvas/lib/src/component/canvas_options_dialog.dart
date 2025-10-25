part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/25
///
/// 画布内部使用的选项设置对话框
/// - 所有操作都不支持持久化
///
/// [CanvasDelegate.dispatchCanvasStyleChanged]
///
/// - [CanvasListener.onCanvasStyleChangedAction] 通过监听此方法, 实现持久化
class CanvasOptionsDialog extends StatefulWidget with DialogMixin {
  /// 画布代理, 核心组件
  final CanvasDelegate canvasDelegate;

  const CanvasOptionsDialog(this.canvasDelegate, {super.key});

  @override
  State<CanvasOptionsDialog> createState() => _CanvasOptionsDialogState();
}

class _CanvasOptionsDialogState extends State<CanvasOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    final canvasDelegate = widget.canvasDelegate;
    final canvasStyle = canvasDelegate.canvasStyle;

    final children = [
      LabelSwitchTile(
        label: "显示网格",
        value: canvasStyle.showGrid,
        onValueChanged: (value) {
          canvasStyle.showGrid = value;
          updateState();
          canvasDelegate.refresh();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "显示坐标系",
        value: canvasStyle.showAxis,
        onValueChanged: (value) {
          canvasStyle.showAxis = value;
          updateState();
          canvasDelegate.relayout();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "显示参考线",
        value: canvasStyle.showRefLine,
        onValueChanged: (value) {
          canvasStyle.showRefLine = value;
          updateState();
          canvasDelegate.refresh();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "智能吸附",
        value: canvasStyle.enableElementAdsorb,
        onValueChanged: (value) {
          canvasStyle.enableElementAdsorb = value;
          updateState();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
      //--
      LabelSwitchTile(
        label: "使用公制单位",
        value: canvasStyle.axisUnit is MmUnit,
        onValueChanged: (value) {
          canvasStyle.axisUnit = value ? IUnit.mm : IUnit.dp;
          updateState();
          canvasDelegate.refresh();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "使用英制单位",
        value: canvasStyle.axisUnit is InchUnit,
        onValueChanged: (value) {
          canvasStyle.axisUnit = value ? IUnit.inch : IUnit.dp;
          updateState();
          canvasDelegate.refresh();
          canvasDelegate.dispatchCanvasStyleChanged();
        },
      ),
    ];

    if (isDesktopOrWeb) {
      return widget.buildCenterDialog(
        context,
        children.column()!.desktopConstrained(),
      );
    }

    return widget.buildBottomChildrenDialog(context, children);
  }
}
