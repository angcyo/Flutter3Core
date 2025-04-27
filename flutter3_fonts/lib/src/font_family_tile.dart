part of '../flutter3_fonts.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/15
///
/// 字体预览
/// [FontFamilyMeta]
/// [GoogleFonts]
///
/// [Axis.vertical]
/// [字体名]           [trailingWidget]尾部
/// [预览文本-可选]
///
/// [Axis.horizontal]
/// [字体名]           [预览文本-可选][trailingWidget]尾部
///
/// [direction]
///
class FontFamilyTile extends StatefulWidget {
  /// 字体描述元数据
  /// 不指定数据, 则表示默认
  final FontFamilyMeta? fontFamilyMeta;

  /// 不指定[fontFamilyMeta]时, 需要显示的默认小部件
  final Widget? defWidget;

  /// 预览的文本
  final String? previewText;

  /// 尾部的小部件
  final Widget? trailingWidget;

  /// 内填充
  final EdgeInsetsGeometry? padding;

  /// 是否单行显示
  final bool isSingleLine;

  /// 对齐方式
  final Alignment? alignment;

  //--

  /// 布局方向, 默认是上下, 可以指定成左右
  final Axis direction;

  const FontFamilyTile(
    this.fontFamilyMeta, {
    super.key,
    this.previewText,
    this.trailingWidget,
    this.padding = kItemPadding,
    this.isSingleLine = false,
    this.defWidget,
    this.alignment,
    this.direction = Axis.vertical,
  });

  @override
  State<FontFamilyTile> createState() => _FontFamilyTileState();
}

class _FontFamilyTileState extends State<FontFamilyTile> {
  @override
  void initState() {
    super.initState();
    if (widget.fontFamilyMeta != null) {
      $fontsManager.loadFontFamily(widget.fontFamilyMeta!).get((value, error) {
        if (value is bool && value) {
          updateState();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.fontFamilyMeta?.textStyle();
    final fontFamily = widget.fontFamilyMeta?.displayFontFamily;

    final fontFamilyWidget = fontFamily?.text(
          style: textStyle,
          maxLines: widget.isSingleLine ? 1 : null,
        ) ??
        widget.defWidget ??
        "Default".text();

    final previewTextWidget = widget.previewText?.text(
      style: textStyle,
      maxLines: widget.isSingleLine ? 1 : null,
    );

    if (widget.direction == Axis.horizontal) {
      final left = fontFamilyWidget;
      return [left.expanded(), previewTextWidget, widget.trailingWidget]
              .row()
              ?.paddingInsets(widget.padding) ??
          empty;
    }

    final left = [fontFamilyWidget, previewTextWidget].column(
        crossAxisAlignment: widget.alignment == Alignment.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start);
    return [left?.expanded(), widget.trailingWidget]
            .row()
            ?.paddingInsets(widget.padding) ??
        empty;
  }
}
