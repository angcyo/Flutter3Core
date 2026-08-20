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

  /// 是否显示画布的快捷键列表
  /// - [CanvasDelegate.canvasKeyManager.shortcutConfigManager]
  final bool? showShortcuts;

  const CanvasOptionsDialog(
    this.canvasDelegate, {
    this.showShortcuts,
    super.key,
  });

  @override
  State<CanvasOptionsDialog> createState() => _CanvasOptionsDialogState();
}

class _CanvasOptionsDialogState extends State<CanvasOptionsDialog>
    with CanvasOptionsMixin {
  @override
  Widget build(BuildContext context) {
    final libRes = context.libRes;
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final canvasDelegate = widget.canvasDelegate;
    final showShortcuts = widget.showShortcuts ?? isDesktopOrWeb;
    final children = [
      ...buildCanvasOptions(
        context,
        canvasDelegate,
        libRes,
        labelTextStyle: globalTheme.textNormalStyle,
      ),
      if (showShortcuts) ...[
        TextTile(
          text: libRes?.libHotkeySettings,
          textStyle: globalTheme.textTitleStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).align(.centerLeft),
        for (final shortcut
            in canvasDelegate
                .canvasKeyManager
                .shortcutConfigManager
                .shortcutConfigList)
          [
                textOf(shortcut)?.text().expanded(),
                ShortcutLabelWidget(configBean: shortcut),
              ]
              .row()
              ?.insets(h: kX, v: kX)
              .ink(() {}, splashColor: Colors.transparent),
      ],
    ];
    if (globalConfig.isInTabletLandscapeModel) {
      return widget.buildDesktopCenterDialog(
        context,
        [
          DesktopDialogTitleTile(title: libRes?.libCanvasOptions ?? "画布选项"),
          [...children].scrollVertical()?.expanded(),
        ].column()!,
      );
    }

    return widget.buildBottomChildrenDialog(context, children, useScroll: true);
  }
}

/// 画布选项
mixin CanvasOptionsMixin<T extends StatefulWidget> on State<T> {
  /// 构建画布可设置的选项小部件列表
  List<Widget> buildCanvasOptions(
    BuildContext context,
    CanvasDelegate? canvasDelegate,
    LibRes? libRes, {
    TextStyle? labelTextStyle,
    double? radius,
  }) {
    final canvasStyle = canvasDelegate?.canvasStyle;
    return [
      LabelSwitchTile(
        label: libRes?.libShowGrid,
        value: canvasStyle?.showGrid == true,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasStyle?.showGrid = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: libRes?.libShowCoordinateSystem,
        value: canvasStyle?.showAxis == true,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasStyle?.showAxis = value;
          updateState();
          canvasDelegate?.relayout();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: libRes?.libActivateGuideLines,
        value: canvasStyle?.enableRefLine == true,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasStyle?.enableRefLine = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: libRes?.libShowGuideLines,
        value: canvasStyle?.showRefLine == true,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasStyle?.showRefLine = value;
          updateState();
          canvasDelegate?.refresh();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: libRes?.libSmartSnap,
        value: canvasStyle?.enableElementAdsorb == true,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasStyle?.enableElementAdsorb = value;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      //--
      LabelSwitchTile(
        label: libRes?.libUseMetricUnits,
        value: canvasStyle?.axisUnit is MmUnit,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasDelegate?.axisUnit = value ? IUnit.mm : IUnit.dp;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
      LabelSwitchTile(
        label: libRes?.libUseImperialUnits,
        value: canvasStyle?.axisUnit is InchUnit,
        labelTextStyle: labelTextStyle,
        radius: radius,
        onValueChanged: (value) {
          canvasDelegate?.axisUnit = value ? IUnit.inch : IUnit.dp;
          updateState();
          canvasDelegate?.dispatchCanvasStyleChanged();
        },
      ),
    ];
  }
}
