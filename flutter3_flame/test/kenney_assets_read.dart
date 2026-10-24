import 'dart:io';

import 'package:xml/xml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 读取`TextureAtlas` xml 资源文件, 生成对应的精灵代码
///
/// https://kenney.nl/assets/
void main() async {
  //sheet xml 文件路径
  final sheetXmlInput =
      //r"E:\projects\games\kenney_shooting-gallery\Spritesheets\spritesheet_hud.xml"
      r"E:\projects\games\kenney_shape-characters\Spritesheet\spritesheet_default.xml";
  final bookshelfXml = await File(sheetXmlInput).readAsString();
  final document = XmlDocument.parse(bookshelfXml);

  final outputBuffer = StringBuffer();
  int count = 0;
  for (final subTexture in document.findAllElements('SubTexture')) {
    final name = toCamelCase(subTexture.getAttribute('name'));
    final x = subTexture.getAttribute('x');
    final y = subTexture.getAttribute('y');
    final width = subTexture.getAttribute('width');
    final height = subTexture.getAttribute('height');
    outputBuffer.writeln('''
      Sprite get ${name}Sprite => Sprite(image, srcPosition: Vector2($x, $y), srcSize: Vector2($width, $height));
      ''');
    count++;
  }
  final outputPath = "build/kenney_assets.dart";
  await File(outputPath).writeAsString(outputBuffer.toString());
  print("$outputPath ->$count 个");
}

/// 转换为小驼峰命名法
String toCamelCase(String? input) {
  if (input == null) return '';
  if (input.isEmpty) return input;

  //移除扩展.png
  input = input.replaceFirst('.png', '');

  final parts = input.split('_');
  if (parts.length < 2) return input;

  final buffer = StringBuffer(parts.first.toLowerCase());

  for (int i = 1; i < parts.length; i++) {
    final part = parts[i];
    if (part.isEmpty) continue;
    buffer.write(part[0].toUpperCase());
    buffer.write(part.substring(1).toLowerCase());
  }

  return buffer.toString();
}
