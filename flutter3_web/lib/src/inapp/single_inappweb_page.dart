part of '../../flutter3_web.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/27
///
/// [SingleWebPage]
/// [SingleInAppWebPage]
/// [flutter_inappwebview]
class SingleInAppWebPage extends StatefulWidget {
  /// 需要加载的网页地址
  final String? url;

  /// 需要加载的网页内容
  final String? html;
  final String? baseUrl;

  const SingleInAppWebPage({
    super.key,
    this.url,
    this.html,
    this.baseUrl,
  });

  @override
  State<SingleInAppWebPage> createState() => _SingleInAppWebPageState();
}

class _SingleInAppWebPageState extends State<SingleInAppWebPage>
    with AbsScrollPage, InAppWebViewStateMixin {
  WebviewConfig config = WebviewConfig();

  @override
  void initState() {
    config.url = widget.url;
    config.html = widget.html;
    config.baseUrl = widget.baseUrl;
    super.initState();
  }

  @override
  String? getTitle(BuildContext context) => webviewTile ?? "";

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  @override
  Widget buildBody(BuildContext context, WidgetList? children) =>
      buildInAppWebView(context, config).interceptPopResult(() async {
        if (await onBackPress() == true) {
          buildContext?.pop();
        }
      });
}
