part of '../flutter3_webview.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/27
///
/// https://pub.dev/packages/flutter_inappwebview
/// https://inappwebview.dev/docs/intro
///
/// [SingleWebPage]
/// [SingleInAppWebPage]
/// [flutter_inappwebview]
class SingleInAppWebPage extends StatefulWidget with TranslationTypeMixin {
  /// 需要加载的网页地址
  final String? url;

  /// 需要加载的网页内容
  final String? html;
  final String? baseUrl;

  @override
  TranslationType get translationType => TranslationType.slide;

  const SingleInAppWebPage({super.key, this.url, this.html, this.baseUrl});

  @override
  State<SingleInAppWebPage> createState() => _SingleInAppWebPageState();
}

class _SingleInAppWebPageState extends State<SingleInAppWebPage>
    with AbsScrollPage, InAppWebViewStateMixin {
  @override
  void initState() {
    webConfigMixin.url = widget.url;
    webConfigMixin.html = widget.html;
    webConfigMixin.baseUrl = widget.baseUrl;
    super.initState();
  }

  @override
  String? getTitle(BuildContext context) => webviewTile ?? "";

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  @override
  Widget buildBody(BuildContext context, WidgetList? children) =>
      buildInAppWebView(context, webConfigMixin).interceptPopResult(() async {
        if (await onWebviewBackPress() == true) {
          buildContext?.pop();
        }
      });
}
