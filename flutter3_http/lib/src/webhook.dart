part of '../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/28
///
/// 一些常用的webhook机器人消息处理
class Webhook {
  /// 发送飞书文本消息
  /// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot#756b882f
  static Future<http.Response> sendFeishuText(
    String webhook,
    String? text, {
    bool atAll = false,
  }) async {
    //post请求
    final postBody = {
      "msg_type": "text",
      "content": {
        "text": '''${atAll ? "<at user_id=\"all\">所有人</at>" : ""}$text''',
      },
    };
    final response = await http.post(
      Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }

  /// 发送飞书富文本消息
  /// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot#f62e72d5
  static Future<http.Response> sendFeishuRichText(
    String webhook,
    String? title,
    String? text, {
    bool atAll = false,
  }) async {
    //post请求
    final postBody = {
      "msg_type": "post",
      "content": {
        "post": {
          "zh_cn": {
            "title": title,
            "content": [
              [
                if (text != null) ...[
                  {"tag": "text", "text": text},
                  {"tag": "text", "text": "\n"},
                ],
                if (atAll) ...[
                  {"tag": "text", "text": "\n"},
                  {"tag": "at", "user_id": "all"},
                ],
              ],
            ],
          },
        },
      },
    };
    final response = await http.post(
      Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }

  /// 发送飞书卡片
  /// https://open.feishu.cn/document/client-docs/bot-v3/add-custom-bot#478cb64f
  ///
  /// 卡片样式编辑:
  /// https://open.feishu.cn/cardkit
  ///
  static Future<http.Response> sendFeishuInteractive(
    String webhook,
    String? title,
    String? text, {
    String? subTitle,
    bool atAll = false,
  }) async {
    //post请求
    final postBody = {
      "msg_type": "interactive",
      "card": {
        "schema": "2.0",
        "config": {
          "update_multi": true,
          "style": {
            "text_size": {
              "normal_v2": {
                "default": "normal",
                "pc": "normal",
                "mobile": "heading",
              },
            },
          },
        },
        "header": title == null
            ? null
            : {
                "title": {"tag": "plain_text", "content": title},
                "subtitle": {"tag": "plain_text", "content": subTitle},
                "template": "blue",
                // blue wathet turquoise green yellow orange red carmine violet purple indigo grey default
                "padding": "12px 12px 12px 12px",
              },
        "body": {
          "direction": "vertical",
          "padding": "12px 12px 12px 12px",
          "elements": [
            if (text != null)
              {
                "tag": "markdown",
                "content": text,
                "text_align": "left",
                "text_size": "normal_v2",
                "margin": "0px 0px 0px 0px",
              },
            if (atAll)
              {
                "tag": "div",
                "text": {"content": "<at id=all></at>", "tag": "lark_md"},
              },
          ],
        },
      },
    };
    final response = await http.post(
      Uri.parse(webhook),
      body: jsonEncode(postBody),
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }
}
