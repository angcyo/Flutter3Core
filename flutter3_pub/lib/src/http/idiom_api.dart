part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/29
///
/// 每日一语 / 每日一成语
/// 数据来源: https://chengyu.t086.com/
class IdiomApi {
  IdiomApi();

  static const String _host = "https://chengyu.t086.com";

  /// 拉取到的成语列表
  @output
  final Set<IdiomBean> _idiomList = {};

  /// 随机在`成语人气排行榜`中获取一个成语以及详情
  /// - https://chengyu.t086.com/cy/paihang.html 成语人气排行榜
  /// - https://chengyu.t086.com/cy8/8786.html 成语详情
  @api
  Future<IdiomBean?> getRandomIdiom() async {
    //debugger();
    try {
      final bytes = await "$_host/cy/paihang.html".dioGetBytes();
      if (isNil(bytes)) return null;
      final html = gbk.decode(bytes!);
      //debugger();
      final document = html.parseHtml();
      final elementList = document.querySelectorAll("div[class=listw] a");
      final element = elementList.random;
      if (element == null) return null;
      final text = element.text;
      final href = element.attributes["href"];

      //获取详情
      final detailUrl = "$_host$href";
      final detailBytes = await detailUrl.dioGetBytes();
      if (isNil(detailBytes)) return null;
      final detailHtml = gbk.decode(detailBytes!);
      final tbodyElement = detailHtml.parseHtml().querySelector(
        "div[class=mainbar] tbody",
      );
      final trList = tbodyElement?.querySelectorAll("tr");
      //debugger();

      final bean = IdiomBean(
        name: text,
        pronounce:
            trList?.getOrNull(1)?.querySelectorAll("td").getOrNull(1)?.text ??
            "",
        des:
            trList?.getOrNull(2)?.querySelectorAll("td").getOrNull(1)?.text ??
            "",
        provenance:
            trList?.getOrNull(3)?.querySelectorAll("td").getOrNull(1)?.text ??
            "",
        sample:
            trList?.getOrNull(4)?.querySelectorAll("td").getOrNull(1)?.text ??
            "",
        synonym:
            trList?.getOrNull(5)?.querySelectorAll("td").getOrNull(1)?.text ??
            "",
        url: detailUrl,
        time: nowTime(),
      );

      _idiomList.add(bean);

      return bean;
    } catch (e, s) {
      //debugger();
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    return null;
  }
}

/// 成语信息数据结构
class IdiomBean with EquatableMixin {
  /// 成语名称
  final String name;

  /// 成语发音
  final String pronounce;

  /// 成语描述/释义
  final String des;

  /// 成语出处
  final String provenance;

  /// 示例
  final String sample;

  /// 近义词
  final String synonym;

  /// 页面详情url
  final String url;

  /// 时间
  final int time;

  IdiomBean({
    required this.name,
    required this.pronounce,
    required this.des,
    required this.provenance,
    required this.sample,
    required this.synonym,
    required this.url,
    required this.time,
  });

  @override
  List<Object?> get props => [name];
}

/// [IdiomApi]的实例
@globalInstance
final $idiomApi = IdiomApi();
