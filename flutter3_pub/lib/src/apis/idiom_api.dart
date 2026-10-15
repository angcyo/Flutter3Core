import 'package:charset/charset.dart';
import 'package:flutter3_core/flutter3_core.dart';

import '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/29
///
/// 每日一语 / 每日一成语
/// 数据来源: https://chengyu.t086.com/
///
/// # chinese-xinhua
/// https://github.com/pwxcoo/chinese-xinhua
///
/// https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/refs/heads/master/data/idiom.json
///
/// ## 歇后语
/// http://xhy.5156edu.com/html2/xhy.html
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
  Future<IdiomBean?> getRandomIdiom({bool? throwError}) async {
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
        l.e(e, stack: s);
        return true;
      }());
      if (throwError == true) {
        rethrow;
      }
    }
    return null;
  }

  /// 从`chinese-xinhua`中获取一个随机成语
  ///
  /// https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/refs/heads/master/data/idiom.json
  ///
  /// ```
  /// [
  ///     {
  ///         "derivation": "语出《法华经·法师功德品》下至阿鼻地狱。”",
  ///         "example": "但也有少数意志薄弱的……逐步上当，终至堕入～。★《上饶集中营·炼狱杂记》",
  ///         "explanation": "阿鼻梵语的译音，意译为无间”，即痛苦无有间断之意。常用来比喻黑暗的社会和严酷的牢狱。又比喻无法摆脱的极其痛苦的境地。",
  ///         "pinyin": "ā bí dì yù",
  ///         "word": "阿鼻地狱",
  ///         "abbreviation": "abdy"
  ///     },
  ///     ...
  /// ]
  /// ```
  Future<IdiomBean?> getRandomIdiomFromChineseXinhua({
    String? url,
    bool? throwError,
  }) async {
    /*final url =
        "https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/refs/heads/master/data/idiom.json";*/
    url ??=
        "https://codeberg.org/angcyo/chinese-xinhua/raw/branch/master/data/idiom.json";
    final name = "idiom.json";
    try {
      final string = await ConfigFile.readConfigFile(
        name,
        ignoreFileCache: false,
        forceAssetToFile: false,
        httpUrl: url,
        waitHttp: true,
      );
      if (isNil(string)) return null;
      final list = string!.toJson();
      final value = list[nextInt(list.length)];
      final derivation = value["derivation"];
      final example = value["example"];
      return IdiomBean(
        name: value["word"],
        pronounce: value["pinyin"],
        des: value["explanation"],
        provenance: derivation,
        sample: example == "无" ? derivation : example,
      );
    } catch (e, s) {
      //debugger();
      assert(() {
        l.e(e, stack: s);
        return true;
      }());
      if (throwError == true) {
        rethrow;
      }
    }
    return null;
  }
}

/// 成语信息数据结构
class IdiomBean with Equatable {
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
  final String? synonym;

  /// 页面详情url
  final String? url;

  /// 时间
  final int? time;

  IdiomBean({
    required this.name,
    required this.pronounce,
    required this.des,
    required this.provenance,
    required this.sample,
    this.synonym,
    this.url,
    this.time,
  });

  @override
  List<Object?> get props => [name];
}

/// [IdiomApi]的实例
@globalInstance
final $idiomApi = IdiomApi();
