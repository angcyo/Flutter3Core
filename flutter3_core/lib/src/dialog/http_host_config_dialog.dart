part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/05/22
///
/// 主机切换对话框
///
/// - [HttpHostConfigDialog]
/// - [OssEndpointConfigDialog]
class HttpHostConfigDialog extends StatefulWidget with DialogMixin {
  const HttpHostConfigDialog({super.key});

  @override
  State<HttpHostConfigDialog> createState() => _HttpHostConfigDialogState();
}

class _HttpHostConfigDialogState extends State<HttpHostConfigDialog> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
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
          "API服务器地址切换(临时)".text(style: globalTheme.textTitleStyle),
        ].row(gap: kH)?.insets(all: kX),
        hLine(context),
        _buildItemTile(globalTheme, "当前服务器", $host, selected: true),
        hLine(context),
        for (final item in Http.hostDataList)
          _buildItemTile(
            globalTheme,
            item.name,
            item.host,
            selected: item.host == $host,
            onTap: () {
              $host = item.host;
              updateState();
            },
          ),
      ].rScroll(shrinkWrap: true),
    );
  }

  Widget _buildItemTile(
    GlobalTheme globalTheme,
    String? name,
    String? host, {
    GestureTapCallback? onTap,
    bool selected = false,
  }) {
    if (selected) {
      onTap = null;
    }
    return [
          name?.text(style: globalTheme.textBodyStyle),
          host?.text(style: globalTheme.textDesStyle),
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

extension HttpHostConfigBuildContextEx on BuildContext {
  /// 显示主机切换对话框
  void showHttpHostConfigDialog() {
    showWidgetDialog(const HttpHostConfigDialog());
  }
}
