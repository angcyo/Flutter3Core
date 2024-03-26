import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';

import '../../assets_generated/assets.gen.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/25

/// 文件/文件夹点击事件
typedef FilePathTapAction = void Function(String path);

/// 文件/文件夹tile
class DebugFileTile extends StatelessWidget {
  /// 文件/文件夹路径
  final String? path;

  /// 点击事件
  final FilePathTapAction? onTap;

  /// 图标大小
  final iconSize = 50.0;

  const DebugFileTile({super.key, this.path, this.onTap});

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);

    final path = this.path;
    final file = path?.file();
    if (path == null || file == null) {
      return "null".text();
    }
    final fileName = path.fileName();
    final stat = file.statSync();
    final modified = stat.modified.format();

    List<Widget?> result;
    if (path.isDirectorySync()) {
      final folder = path.folder;
      final infoRow = [
        "${folder.listFilesSync()?.length ?? "--"} 项".text(
          style: globalConfig.globalTheme.textDesStyle,
        ),
        Empty.width(kX),
        stat.size
            .toFileSizeStr()
            .text(
              style: globalConfig.globalTheme.textDesStyle,
            )
            .expanded(),
        Empty.width(kX),
        stat.modeString().text(
              style: globalConfig.globalTheme.textDesStyle,
            ),
        Empty.width(kX),
        modified.text(
          style: globalConfig.globalTheme.textDesStyle,
        ),
      ].row();
      result = [
        loadCoreAssetImageWidget(
          Assets.assetsCore.png.coreFileIconFolder.keyName,
          width: iconSize,
          height: iconSize,
        ),
        Empty.width(kX),
        [
          fileName.text(
            style: globalConfig.globalTheme.textBodyStyle,
          ),
          infoRow,
        ].column(crossAxisAlignment: CrossAxisAlignment.start)!.expanded(),
      ];
    } else {
      final infoRow = [
        stat.size
            .toFileSizeStr()
            .text(
              style: globalConfig.globalTheme.textDesStyle,
            )
            .expanded(),
        Empty.width(kX),
        stat.modeString().text(
              style: globalConfig.globalTheme.textDesStyle,
            ),
        Empty.width(kX),
        modified.text(
          style: globalConfig.globalTheme.textDesStyle,
        ),
      ].row();
      result = [
        getFileIconWidget(fileName, width: iconSize, height: iconSize),
        Empty.width(kX),
        [
          [
            fileName.text(
              style: globalConfig.globalTheme.textBodyStyle,
            ),
            infoRow,
            file.md5()?.toUpperCase().text(
                  style: globalConfig.globalTheme.textDesStyle,
                ),
          ].column(crossAxisAlignment: CrossAxisAlignment.start)?.expanded(),
        ].row()?.expanded(),
      ];
    }

    return result.row()!.paddingAll(kH).ink(
      onTap: () {
        onTap?.call(path);
      },
    );
  }
}
