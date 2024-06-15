part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体预览
/// [FontFamilyMeta]
/// [GoogleFonts]
class FontFamilyTile extends StatefulWidget {
  /// 字体描述元数据
  final FontFamilyMeta fontFamilyMeta;

  /// 预览的文本
  final String? previewText;

  /// 尾部的小部件
  final Widget? trailingWidget;

  const FontFamilyTile(
    this.fontFamilyMeta, {
    super.key,
    this.previewText,
    this.trailingWidget,
  });

  @override
  State<FontFamilyTile> createState() => _FontFamilyTileState();
}

class _FontFamilyTileState extends State<FontFamilyTile> {
  @override
  void initState() {
    super.initState();
    $fontsManager.loadFontFamily(widget.fontFamilyMeta).get((value, error) {
      if (value is bool && value) {
        updateState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.fontFamilyMeta.textStyle();
    final fontFamily = widget.fontFamilyMeta.fontFamily;

    final left = [
      fontFamily.text(style: textStyle),
      widget.previewText?.text(style: textStyle),
    ].column(crossAxisAlignment: CrossAxisAlignment.start);
    return [left?.expanded(), widget.trailingWidget]
            .row()
            ?.paddingInsets(kItemPadding) ??
        empty;
  }
}
