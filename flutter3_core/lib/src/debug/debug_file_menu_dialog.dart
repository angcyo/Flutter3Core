import 'package:flutter/material.dart';

import '../../assets_generated/assets.gen.dart';
import '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 文件菜单对话框
class DebugFileMenuDialog extends StatelessWidget with DialogMixin {
  /// 文件路径, 支持文件/文件夹夹路径
  final String? filePath;

  /// 删除文件回调
  final VoidAction? onDeleteAction;

  //--

  /// 是否在弹窗中显示当前的对话框
  /// - 影响样式
  @override
  final bool? dialogInPopup;

  /// 影响样式和页面的关闭方式
  @override
  final bool? dialogInOverlay;

  const DebugFileMenuDialog(
    this.filePath, {
    super.key,
    this.onDeleteAction,
    this.dialogInOverlay,
    this.dialogInPopup,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);
    final isFile = filePath?.isFileSync() ?? false;
    const size = 25.0;
    return [
          if (!dialogIsPopupStyle) buildDragHandle(context),
          if (isFile)
            IconTextTile(
              iconWidget: loadCoreAssetSvgPicture(
                Assets.svg.fileBrowseOpen,
                width: size,
                height: size,
                tintColor: context.isThemeDark
                    ? globalTheme.icoNormalColor
                    : null,
              ),
              text: "打开文件",
              onTap: () {
                close(context);
                if (filePath?.mimeType()?.isImageMimeType == true) {
                  context.showWidgetDialog(
                    SingleImageDialog(filePath: filePath),
                    useSafeArea: false,
                  );
                } else {
                  context.showWidgetDialog(
                    SingleTextDialog(filePath: filePath),
                  );
                }
              },
            ),
          if (isFile)
            IconTextTile(
              iconWidget: loadCoreAssetSvgPicture(
                Assets.svg.fileBrowseShare,
                width: size,
                height: size,
                tintColor: context.isThemeDark
                    ? globalTheme.icoNormalColor
                    : null,
              ),
              text: "分享文件",
              onTap: () {
                globalConfig.shareDataFn?.call(context, filePath?.file());
                close(context);
              },
            ),
          IconTextTile(
            iconWidget: loadCoreAssetSvgPicture(
              Assets.svg.fileBrowseDelete,
              width: size,
              height: size,
              tintColor: context.isThemeDark
                  ? globalTheme.icoNormalColor
                  : null,
            ),
            text: isFile ? "删除文件" : "删除文件夹",
            onTap: () {
              filePath?.deleteSync();
              onDeleteAction?.call();
              close(context);
            },
          ),
          IconTextTile(
            iconWidget: Empty.size(size),
            text: "复制路径",
            onTap: () {
              filePath?.copy();
              close(context);
            },
          ),
          if (isDesktopOrWeb)
            IconTextTile(
              iconWidget: Empty.size(size),
              text: "打开所在文件夹",
              onTap: () {
                final path = isFile ? filePath?.parentPath : filePath;
                openFilePath(path);
                close(context);
              },
            ),
        ]
        .column()!
        .container(color: globalTheme.whiteBgColor)
        .pullBack(enablePullBack: dialogIsPopupStyle != true)
        .matchParent(matchHeight: false)
        .align(Alignment.bottomCenter, enable: dialogIsPopupStyle != true)
        .desktopConstrained(
          enable: dialogIsPopupStyle,
          maxWidth: kPopupMinWidth,
        )
        .clipRadius(enable: dialogIsPopupStyle == true);
  }

  void close(BuildContext context) {
    if (dialogInOverlay == true) {
      OverlayEntryControlStateScope.hideOverlay(context);
    } else {
      Navigator.of(context).pop();
    }
  }
}
