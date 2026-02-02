import 'package:flutter3_core/flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/02
///
/// CCTV 中国新闻 国内新闻
///数据来源: https://news.cctv.com/china/
class CCTVNewsApi {
  CCTVNewsApi();

  static const String _host = "https://news.cctv.com";

  /// 获取国内新闻列表列表
  @api
  Future<List<CCTVNewsItemBean>?> getNewsList({RequestPage? page}) async {
    final api =
        "2019/07/gaiban/cmsdatainterface/page/china_${page?.requestPageIndex ?? 1}.jsonp?cb=china"
            .toApi(_host);
    final body = await api.dioGetString(queryParameters: noRequestLogMap);
    if (body == null || body.isNil) {
      return null;
    }
    final body2 = body.trimStart("china(").trimEnd(")");
    final json = body2.toJson();
    final result = (json["data"]["list"] as List).mapToList<CCTVNewsItemBean>(
      (e) => CCTVNewsItemBean.fromJson(e),
    );
    return result;
  }
}

/// ```
/// {
///     "id": "ARTIQoWFuUKYD4fFqMXeiCan260130",
///     "title": "外交部：中方愿同各国本着互利共赢的精神加强合作",
///     "focus_date": "2026-01-3015:53:19",
///     "url": "https://news.cctv.com/2026/01/30/ARTIQoWFuUKYD4fFqMXeiCan260130.shtml",
///     "image": "https://p5.img.cctvpic.com/photoworkspace/2026/01/30/2026013015530798411.jpg",
///     "image2": "",
///     "image3": "",
///     "brief": "1月30日，外交部发言人郭嘉昆主持例行记者会。有记者就美国领导人关于加拿大、英国同中国开展商业活动的言论提问。",
///     "ext_field": "",
///     "keywords": "中方加强合作 互利共赢 外交部发言人 郭嘉昆 总台 例行记者会 版权所有 领导人央视",
///     "count": ""
/// }
/// ```
class CCTVNewsItemBean {
  /// 新闻简介
  final String? brief;

  final String? count;

  final String? extField;

  /// 焦点时间
  final String? focusDate;

  final String? id;

  /// 新闻图片
  final String? image;

  /// 新闻图片2
  final String? image2;

  /// 新闻图片3
  final String? image3;

  /// 关键字
  final String? keywords;

  /// 新闻标题
  final String? title;

  /// 新闻链接
  final String? url;

  CCTVNewsItemBean({
    this.brief,
    this.count,
    this.extField,
    this.focusDate,
    this.id,
    this.image,
    this.image2,
    this.image3,
    this.keywords,
    this.title,
    this.url,
  });

  /// fromJson
  factory CCTVNewsItemBean.fromJson(Map<String, dynamic> json) {
    return CCTVNewsItemBean(
      brief: json['brief'],
      count: json['count'],
      extField: json['ext_field'],
      focusDate: json['focus_date'],
      id: json['id'],
      image: json['image'],
      image2: json['image2'],
      image3: json['image3'],
      keywords: json['keywords'],
      title: json['title'],
      url: json['url'],
    );
  }
}
