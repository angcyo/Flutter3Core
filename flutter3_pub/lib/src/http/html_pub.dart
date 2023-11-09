part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/08
///

extension HtmlStringEx on String {
  /// 将html字符串文本,快速转换成对应的[Widget]
  @dsl
  Widget toHtmlWidget(
    BuildContext context, {
    OnTap? onLinkTap,
    OnTap? onAnchorTap,
    List<HtmlExtension> extensions = const [],
    OnCssParseError? onCssParseError,
    shrinkWrap = false,
    Set<String>? onlyRenderTheseTags,
    Set<String>? doNotRenderTheseTags,
    Map<String, Style>? style,
  }) {
    Map<String, Style> mergeStyle = {
      "a": Style(
        textDecoration: TextDecoration.none, //去掉下划线
      ),
    };
    if (style != null) mergeStyle.addAll(style);
    return Html(
      data: this,
      onLinkTap: (url, attributes, element) {
        l.d("Link点击[${element?.text}]:$url");
        if (onLinkTap != null) {
          onLinkTap(url, attributes, element);
        } else {
          openWebUrl(context, url);
        }
      },
      onAnchorTap: (url, attributes, element) {
        //onAnchorTap 会覆盖 onLinkTap
        l.d("Anchor点击[${element?.text}]:$url");
        if (onAnchorTap != null) {
          onAnchorTap(url, attributes, element);
        } else {
          openWebUrl(context, url);
        }
      },
      style: mergeStyle,
      extensions: extensions,
      onCssParseError: onCssParseError,
      shrinkWrap: shrinkWrap,
      onlyRenderTheseTags: onlyRenderTheseTags,
      doNotRenderTheseTags: doNotRenderTheseTags,
    );
  }
}
