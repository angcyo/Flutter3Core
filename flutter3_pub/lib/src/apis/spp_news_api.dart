import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:html/dom.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/09
///
/// 中华人民共和国最高人民检察院 最高检新闻
/// https://www.spp.gov.cn/spp/tt/index.shtml
class SppNewsApi {
  SppNewsApi();

  static const String _host = "https://www.spp.gov.cn";

  /// 获取最高检新闻列表
  @api
  Future<List<SppNewsItemBean>?> getSppNewsList({RequestPage? page}) async {
    //debugger(when: page != null && !page.isFirstPage);
    final api =
        (page != null && page.isFirstPage == false
                ? "spp/tt/index_${page.requestPageIndex}.shtml"
                : "spp/tt/index.shtml")
            .toApi(_host);
    final html = await api.dioGetString(queryParameters: noRequestLogMap);
    if (html == null || html.isNil) {
      return null;
    }
    final document = html.parseHtml();
    final listElement = document.querySelectorAll(".li_line").firstOrNull;
    if (listElement == null) {
      return null;
    }
    final liElementList = listElement.querySelectorAll("li");

    final List<SppNewsItemBean> result = [];
    for (final liElement in liElementList) {
      final bean = _buildNewsItem(liElement, baseUrl: _host);
      if (bean != null) {
        result.add(bean);
      }
    }
    //debugger();
    return result;
  }

  /// [Element]->[SppNewsItemBean]
  SppNewsItemBean? _buildNewsItem(Element liElement, {String? baseUrl}) {
    final aElement = liElement.querySelector("a");
    String? hrefUrl = aElement?.attributes["href"];
    if (hrefUrl != null &&
        (hrefUrl.startsWith(".") || hrefUrl.startsWith("/"))) {
      hrefUrl = hrefUrl.toApi(baseUrl);
    }
    final title = aElement?.text.replaceAll(RegExp("\n|\t"), "");
    final time = liElement
        .querySelector("span")
        ?.text
        .replaceAll(RegExp("\n|\t"), "");
    l.d(hrefUrl);
    return SppNewsItemBean(url: hrefUrl, title: title, time: time);
  }
}

class SppNewsItemBean {
  /// 标题
  String? title;

  /// 时间
  String? time;

  /// 详情链接
  String? url;

  SppNewsItemBean({this.title, this.time, this.url});
}
