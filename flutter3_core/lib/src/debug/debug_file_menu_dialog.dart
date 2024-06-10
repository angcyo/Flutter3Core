import 'package:flutter/material.dart';

import '../../assets_generated/assets.gen.dart';
import '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 文件菜单对话框
class DebugFileMenuDialog extends StatelessWidget {
  /// 文件路径, 支持文件/文件夹夹路径
  final String? filePath;

  /// 删除文件回调
  final VoidAction? onDeleteAction;

  const DebugFileMenuDialog(
    this.filePath, {
    super.key,
    this.onDeleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = GlobalTheme.of(context);
    final isFile = filePath?.isFileSync() ?? false;
    const size = 25.0;
    return [
      buildDragHandle(context),
      if (isFile)
        IconTextTile(
          iconWidget: loadCoreAssetSvgPicture(
            Assets.svg.fileBrowseOpen,
            width: size,
            height: size,
            tintColor: context.isThemeDark ? globalTheme.icoNormalColor : null,
          ),
          text: "打开文件",
          onTap: () {
            close(context);
            if (filePath?.mimeType()?.isImageMimeType == true) {
              context.showWidgetDialog(SingleImageDialog(
                filePath: filePath,
              ));
            } else {
              context.showWidgetDialog(SingleTextDialog(
                filePath: filePath,
              ));
            }
          },
        ),
      if (isFile)
        IconTextTile(
          iconWidget: loadCoreAssetSvgPicture(
            Assets.svg.fileBrowseShare,
            width: size,
            height: size,
            tintColor: context.isThemeDark ? globalTheme.icoNormalColor : null,
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
          tintColor: context.isThemeDark ? globalTheme.icoNormalColor : null,
        ),
        text: isFile ? "删除文件" : "删除文件夹",
        onTap: () {
          filePath?.deleteSync();
          onDeleteAction?.call();
          close(context);
        },
      ),
    ]
        .column()!
        .container(color: globalTheme.whiteBgColor)
        .pullBack()
        .matchParent(matchHeight: false)
        .align(Alignment.bottomCenter);
  }

  void close(BuildContext context) {
    Navigator.of(context).pop();
  }
}
