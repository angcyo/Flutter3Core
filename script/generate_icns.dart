import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/30
///
/// 用来生成macOS .icns 文件
/// - macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png 默认使用此输入图片
void main(List<String> args) async {
  // 1. 配置你的 1024x1024 PNG 源文件路径
  final sourceIcon =
      args.firstOrNull ??
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png';
  final outputName = args.length > 1 ? args[1] : 'AppIcon';
  final iconsetName = "$outputName.iconset";

  if (!Platform.isMacOS) {
    print('❌ 该脚本只能在 macOS 系统上运行');
    return;
  }

  final outputPath = 'macos/Runner/';
  final dir = Directory("$outputPath$iconsetName");
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create();

  // 严格对应的标准尺寸
  final sizes = {
    16: ['16x16', '16x16@2x'],
    32: ['32x32', '32x32@2x'],
    128: ['128x128', '128x128@2x'],
    256: ['256x256', '256x256@2x'],
    512: ['512x512', '512x512@2x'],
  };

  print('⏳ 正在使用系统 sips 裁剪标准尺寸...');
  for (final size in sizes.keys) {
    for (final name in sizes[size]!) {
      final currentSize = name.contains('@2x') ? size * 2 : size;
      // 注意这里的命名：icon_ 开头，严格契合 iconutil 的要求
      await Process.run('sips', [
        '-z',
        '$currentSize',
        '$currentSize',
        sourceIcon,
        '--out',
        '$iconsetName/icon_$name.png',
      ]);
    }
  }

  print('⏳ 正在生成成品 .icns 文件...');
  final outputIcns = '$outputPath$outputName.icns';
  await Process.run('iconutil', ['-c', 'icns', iconsetName, '-o', outputIcns]);

  await dir.delete(recursive: true);
  print('✨ 成功！成品已输出至: $outputIcns');
}
