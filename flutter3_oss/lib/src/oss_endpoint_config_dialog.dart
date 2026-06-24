part of '../flutter3_oss.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/08
///
/// OSS 端点切换对话框
class OssEndpointConfigDialog extends StatefulWidget with DialogMixin {
  const OssEndpointConfigDialog({super.key});

  @override
  State<OssEndpointConfigDialog> createState() =>
      _OssEndpointConfigDialogState();
}

class _OssEndpointConfigDialogState extends State<OssEndpointConfigDialog> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final currentData = OssClient.ossConfigLive.value;
    return widget.buildAdaptiveCenterDialog(
      context,
      [
        [
          Icon(
            Icons.beenhere_outlined,
            size: 24,
            color: globalTheme.accentColor,
            shadows: [kBoxShadow],
          ),
          "OSS Endpoint 切换(临时)".text(style: globalTheme.textTitleStyle),
        ].row(gap: kH)?.insets(all: kX),
        hLine(context),
        _buildItemTile(
          globalTheme,
          "当前 Endpoint",
          currentData?.ossEndpoint,
          selected: true,
        ),
        hLine(context),
        for (final item in OssClient.ossConfigList)
          _buildItemTile(
            globalTheme,
            item.ossEndpoint,
            item.ossBucket,
            selected:
                item.ossEndpoint == currentData?.ossEndpoint &&
                item.ossBucket == currentData?.ossBucket,
            onTap: () {
              OssClient.ossConfigLive << item;
              updateState();
            },
          ),
      ].rScroll(shrinkWrap: true),
    );
  }

  Widget _buildItemTile(
    GlobalTheme globalTheme,
    String? ossEndpoint,
    String? ossBucket, {
    GestureTapCallback? onTap,
    bool selected = false,
  }) {
    if (selected) {
      onTap = null;
    }
    final ossEndpointLabel = ossEndpoint?.contains("heyuan") == true
        ? "河源"
        : ossEndpoint?.contains("hongkong") == true
        ? "香港"
        : null;
    return [
          ossEndpoint
              ?.connect(null, ossEndpointLabel?.wph.connect(" "))
              .text(style: globalTheme.textBodyStyle),
          ossBucket?.text(style: globalTheme.textDesStyle),
        ]
        .column(crossAxisAlignment: .start)!
        .insets(h: kX, v: kH)
        .click(onTap)
        .stateDecoration(
          strokeDecoration(
            color: selected ? globalTheme.accentColor : globalTheme.borderColor,
          ),
          pressedDecoration: strokeDecoration(),
          enablePressedDecoration: onTap != null,
        )
        .insets(h: kX, v: kH);
  }
}

extension OssEndpointConfigBuildContextEx on BuildContext {
  /// 显示OSS 端点切换对话框
  void showOssEndpointConfigDialog() {
    showWidgetDialog(const OssEndpointConfigDialog());
  }
}
