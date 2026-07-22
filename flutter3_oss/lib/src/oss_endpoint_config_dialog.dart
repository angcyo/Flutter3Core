part of '../flutter3_oss.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/08
///
/// OSS 端点切换对话框
/// @return true 发生了改变
class OssEndpointConfigDialog extends StatefulWidget with DialogMixin {
  @hiveFlag
  static HiveStringValue $ossEndpointHive = $hiveString(
    "_key_oss_endpoint_config",
  );
  @hiveFlag
  static HiveStringValue $ossBucketHive = $hiveString("_key_oss_bucket_config");

  final EdgeInsetsGeometry? margin;

  const OssEndpointConfigDialog({super.key, this.margin});

  @override
  State<OssEndpointConfigDialog> createState() =>
      _OssEndpointConfigDialogState();
}

class _OssEndpointConfigDialogState extends State<OssEndpointConfigDialog> {
  bool _changed = false;

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
          "OSS Endpoint 切换".text(style: globalTheme.textTitleStyle),
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
              if (item.ossEndpoint == currentData?.ossEndpoint) {
                widget.closeDialogIf(context, result: _changed);
              } else {
                OssEndpointConfigDialog.$ossEndpointHive << item.ossEndpoint;
                OssEndpointConfigDialog.$ossBucketHive << item.ossBucket;
                OssClient.ossConfigLive << item;
                _changed = true;
                updateState();
              }
            },
          ),
      ].rScroll(shrinkWrap: true),
      margin: widget.margin,
    );
  }

  Widget _buildItemTile(
    GlobalTheme globalTheme,
    String? ossEndpoint,
    String? ossBucket, {
    GestureTapCallback? onTap,
    bool selected = false,
  }) {
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

/// 同时配置 HTTP 端点 和 OSS 端点
/// - [HttpHostConfigDialog]
/// - [OssEndpointConfigDialog]
/// @return true 发生了改变
class HttpAndOssConfigDialog extends StatefulWidget with DialogMixin {
  const HttpAndOssConfigDialog({super.key});

  @override
  State<HttpAndOssConfigDialog> createState() => _HttpAndOssConfigDialogState();
}

class _HttpAndOssConfigDialogState extends State<HttpAndOssConfigDialog> {
  @override
  Widget build(BuildContext context) {
    return [
      HttpHostConfigDialog(margin: insets(all: kX)),
      OssEndpointConfigDialog(margin: insets(all: kX)),
    ].row(mainAxisAlignment: .center)!;
  }
}

extension OssEndpointConfigBuildContextEx on BuildContext {
  /// 显示OSS 端点切换对话框
  Future<T?> showOssEndpointConfigDialog<T>() {
    return showWidgetDialog<T>(const OssEndpointConfigDialog());
  }

  /// 显示HTTP 和 OSS 端点切换对话框
  Future<T?> showHttpAndOssConfigDialog<T>() {
    return showWidgetDialog<T>(const HttpAndOssConfigDialog());
  }
}
