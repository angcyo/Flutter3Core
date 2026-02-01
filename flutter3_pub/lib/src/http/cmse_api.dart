import 'package:flutter3_core/flutter3_core.dart';
import 'package:html/dom.dart';

import '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/31
///
/// 中国载人航天 - 飞行任务
/// 数据来源: https://www.cmse.gov.cn/fxrw/
class CmseApi {
  CmseApi();

  static const String _host = "https://www.cmse.gov.cn";

  /// 获取飞行任务列表
  Future<List<CmseFXRWItemBean>?> getFXRWList({RequestPage? page}) async {
    //debugger(when: page != null && !page.isFirstPage);
    final api =
        (page != null && page.isFirstPage == false
                ? "fxrw/index_${page.requestPageIndex - 1}.html"
                : "fxrw")
            .toApi(_host);
    final html = await api.dioGetString(queryParameters: noRequestLogMap);
    if (html == null || html.isNil) {
      return null;
    }
    final document = html.parseHtml();
    final listElement = document.querySelectorAll("#list").firstOrNull;
    if (listElement == null) {
      return null;
    }
    final liElementList = listElement.querySelectorAll("li");

    final List<CmseFXRWItemBean> result = [];
    for (final liElement in liElementList) {
      final bean = _buildFXRWItem(liElement, baseUrl: "fxrw".toApi(_host));
      if (bean != null) {
        result.add(bean);
      }
    }
    //debugger();
    return result;
  }

  /// [Element]->[CmseFXRWItemBean]
  CmseFXRWItemBean? _buildFXRWItem(Element liElement, {String? baseUrl}) {
    final imgElement = liElement.querySelector("img");
    String? imgUrl = imgElement?.attributes["src"];
    if (imgUrl != null && imgUrl.startsWith(".")) {
      imgUrl = imgUrl.toApi(baseUrl);
    }
    final title = liElement
        .querySelector(".title")
        ?.text
        .replaceAll(RegExp("\n|\t"), "");

    final infoItemElementList = liElement.querySelectorAll(".infoItem");
    final infoItemList = infoItemElementList.map((element) {
      final label = element
          .querySelector(".infoL")
          ?.text
          .replaceAll(RegExp("\n|\t"), "");
      final des = element
          .querySelector(".infoR")
          ?.text
          .replaceAll(RegExp("\n|\t"), "");
      return (label, des);
    });
    return CmseFXRWItemBean(
      imgUrl: imgUrl,
      title: title,
      infoItemList: infoItemList,
    );
  }
}

class CmseFXRWItemBean with EquatableMixin {
  /// 封面的地址
  /// - https://www.cmse.gov.cn/fxrw/202511/W020251125475201572708.jpg
  final String? imgUrl;

  /// 标题
  /// - 任务名称 ： 神舟二十二号飞行任务
  final String? title;

  /// - 发射时间 :  2025年11月25日12时11分
  /// - 发射地点 :  酒泉卫星发射中心
  /// - 任务概况 :  本次任务是中国载人航天工程立项实施以来的第38次发射任务，也是中国载人航天工程第1次应急发射任务。
  final Iterable<(String? label, String? des)>? infoItemList;

  CmseFXRWItemBean({this.imgUrl, this.title, this.infoItemList});

  @override
  List<Object?> get props => [title];

  @override
  String toString() {
    return 'CmseFXRWItemBean{imgUrl: $imgUrl, title: $title, infoItemList: $infoItemList}';
  }
}
