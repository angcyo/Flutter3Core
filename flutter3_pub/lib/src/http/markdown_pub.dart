part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// [flutter_markdown](https://pub.dev/packages/flutter_markdown)
extension MarkdownStringEx on String {
  /// 将markdown字符串文本内容,快速转换成对应的[Widget]
  /// [selectable] 是否支持文本选择
  /// [useScrollView] 是否需要滚动
  @dsl
  Widget toMarkdownWidget(
    BuildContext context, {
    bool useScrollView = false,
    bool selectable = false,
    MarkdownTapLinkCallback? onLinkTap,
    VoidCallback? onAnchorTap,
  }) {
    return SingleMarkdown(
      data: this,
      selectable: selectable,
      useScrollView: useScrollView,
      onTapLink: (text, href, title) {
        assert(() {
          l.d("Link点击[$text]:$title:$href");
          return true;
        }());
        onLinkTap?.call(text, href, title);
        if (onLinkTap == null) {
          context.openWebUrl(href);
        }
      },
      onTapText: () {
        assert(() {
          l.d("onTapText");
          return true;
        }());
        onAnchorTap?.call();
        if (onAnchorTap == null) {}
      },
    );
  }

  /// 将markdown字符串文本内容,快速转换成html内容
  String toHtmlWithMarkdown() => markdownToHtml(this);
}

/// [Markdown]
/// [MarkdownBody]
class SingleMarkdown extends MarkdownWidget {
  /// 是否需要滚动
  final bool useScrollView;

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  ///
  /// See also: [ScrollView.controller]
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  ///
  /// See also: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scroll direction should be
  /// determined by the contents being viewed.
  ///
  /// See also: [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  const SingleMarkdown({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.syntaxHighlighter,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    super.softLineBreak,
    this.useScrollView = false,
  });

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    if (children?.isEmpty == true) {
      return const Empty.zero();
    }

    if (useScrollView) {
      return ListView(
        padding: padding,
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        children: children!,
      );
    }

    if (children!.length == 1 && shrinkWrap) {
      return children.single;
    }
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment:
          fitContent ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
