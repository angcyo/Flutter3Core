part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/25
///
/// 画布内部使用的选项设置对话框, 内部的画布设置对话框
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

class _CanvasOptionsDialogState extends State<CanvasOptionsDialog>
    with CanvasOptionsMixin {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final canvasDelegate = widget.canvasDelegate;
    final children = buildCanvasOptions(context, canvasDelegate);

    if (globalConfig.isInTabletLandscapeModel) {
      return widget.buildDesktopCenterDialog(
        context,
        [DesktopDialogTitleTile(title: "画布选项"), ...children].column()!,
      );
    }

    return widget.buildBottomChildrenDialog(context, children);
  }
}

/// 画布选项
mixin CanvasOptionsMixin<T extends StatefulWidget> on State<T> {
  /// 构建画布可设置的选项小部件列表
  List<Widget> buildCanvasOptions(
    BuildContext context,
    CanvasDelegate? canvasDelegate,
  ) {
    final canvasStyle = canvasDelegate?.canvasStyle;
    return [
      LabelSwitchTile(
        label: "显示网格",
        value: canvasStyle?.showGrid == true,
        onValueChanged: (value) {
          canvasStyle?.showGrid = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "显示坐标系",
        value: canvasStyle?.showAxis == true,
        onValueChanged: (value) {
          canvasStyle?.showAxis = value;
          updateState();
          canvasDelegate?.relayout();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "激活参考线",
        value: canvasStyle?.enableRefLine == true,
        onValueChanged: (value) {
          canvasStyle?.enableRefLine = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "显示参考线",
        value: canvasStyle?.showRefLine == true,
        onValueChanged: (value) {
          canvasStyle?.showRefLine = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "智能吸附",
        value: canvasStyle?.enableElementAdsorb == true,
        onValueChanged: (value) {
          canvasStyle?.enableElementAdsorb = value;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      //--
      LabelSwitchTile(
        label: "使用公制单位",
        value: canvasStyle?.axisUnit is MmUnit,
        onValueChanged: (value) {
          canvasDelegate?.axisUnit = value ? IUnit.mm : IUnit.dp;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: "使用英制单位",
        value: canvasStyle?.axisUnit is InchUnit,
        onValueChanged: (value) {
          canvasDelegate?.axisUnit = value ? IUnit.inch : IUnit.dp;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
    ];
  }
}
