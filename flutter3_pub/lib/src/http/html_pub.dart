part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/08
///
/// [flutter_html](https://pub.dev/packages/flutter_html)
extension HtmlStringEx on String {
  /// 将html字符串文本内容,快速转换成对应的[Widget]
  /// 默认所有的文本都将放在`body`标签中, 并且默认会有8.0的margin
  ///
  /// [bodyMargin] body的margin, 默认是8.0
  /// [StyledElementBuiltIn.prepare]
  @dsl
  Widget toHtmlWidget(
    BuildContext context, {
    double bodyMargin = 0.0,
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
      "body": Style(
        margin: Margins.all(bodyMargin), //去掉body的margin, 默认是8.0
      ),
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
          context.openWebUrl(url);
        }
      },
      onAnchorTap: (url, attributes, element) {
        //onAnchorTap 会覆盖 onLinkTap
        l.d("Anchor点击[${element?.text}]:$url");
        if (onAnchorTap != null) {
          onAnchorTap(url, attributes, element);
        } else {
          context.openWebUrl(url);
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

  /// 解析html字符串, 解析网页数据
  ///
  /// - [dom.Document]
  /// - [dom.Document.querySelector]
  /// - [dom.Document.querySelectorAll]
  ///
  /// - [dom.Element]
  /// - [dom.Element.querySelector] 查询子元素
  /// - [dom.Element.querySelectorAll] 查询子元素列表
  dom.Document parseHtml({
    String? encoding,
    bool generateSpans = false,
    String? sourceUrl,
  }) => parse(this);
}
