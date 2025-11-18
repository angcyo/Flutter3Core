import 'dart:io';

import 'package:flutter3_core/flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/17
///
abstract final class ShelfHtml {
  /// 响应html内容的模板
  static String getResponseHtml(String tile, String body) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>$tile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<div class="centered-content">
  <p>$body</p>
</div>
</body>
</html>
        ''';

  /// 响应成功的html内容的模板(带有√图标)
  static String getResponseSucceedHtml(String tile, String body) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        .centered-content {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            height: 100%;
        }
    </style>
</head>
<body>
<div class="centered-content">
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
     width="100" height="100">
    <path d="M512 512m-512 0a512 512 0 1 0 1024 0 512 512 0 1 0-1024 0Z" fill="#67EBB2"
          opacity=".15"
    ></path>
    <path d="M512 814.545455a302.545455 302.545455 0 0 1-213.934545-516.48 302.545455 302.545455 0 1 1 427.86909 427.86909A300.555636 300.555636 0 0 1 512 814.545455z m-124.148364-328.052364a36.072727 36.072727 0 0 0-25.6 61.486545l92.997819 93.730909a29.917091 29.917091 0 0 0 42.46109 0l165.853091-166.74909a29.928727 29.928727 0 0 0-40.226909-44.218182l-127.418182 104.808727a29.905455 29.905455 0 0 1-38.597818-0.488727l-45.905454-39.761455a36.002909 36.002909 0 0 0-23.563637-8.808727z"
          fill="#20D76D"></path>
</svg>
<p>$body</p>
</div>
</body>
</html>
  ''';

  /// 响应成功的html内容的模板(带有√图标, 并还有回到主页按钮)
  static String getReceiveSucceedHtml(String tile, String body, String again) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        .centered-content {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            height: 100%;
        }
        .btn {
            color: #20D76D;
            font-size: 20px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="centered-content">
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
     width="100" height="100">
    <path d="M512 512m-512 0a512 512 0 1 0 1024 0 512 512 0 1 0-1024 0Z" fill="#67EBB2"
          opacity=".15"
    ></path>
    <path d="M512 814.545455a302.545455 302.545455 0 0 1-213.934545-516.48 302.545455 302.545455 0 1 1 427.86909 427.86909A300.555636 300.555636 0 0 1 512 814.545455z m-124.148364-328.052364a36.072727 36.072727 0 0 0-25.6 61.486545l92.997819 93.730909a29.917091 29.917091 0 0 0 42.46109 0l165.853091-166.74909a29.928727 29.928727 0 0 0-40.226909-44.218182l-127.418182 104.808727a29.905455 29.905455 0 0 1-38.597818-0.488727l-45.905454-39.761455a36.002909 36.002909 0 0 0-23.563637-8.808727z"
          fill="#20D76D"></path>
</svg>
<p>$body</p>
<p class="btn">$again</p>
</div>
<script>
    document.querySelector('.btn').addEventListener('click', function () {
        window.location.href = '/';
    });
</script>
</body>
</html>
  ''';

  static String getWebSocketHtml(String tile, String ws) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
<div id="content-wrap" style="height: 100%; overflow: auto;">
    <div id="content" style="padding: 10px">
    </div>
</div>
<script>
    // 创建一个 WebSocket 实例，指定服务器的地址
    const socket = new WebSocket('$ws');

    // 当连接打开时触发
    socket.onopen = function (event) {
        document.getElementById('content').innerHTML = 'WebSocket 已连接->$ws';
        /*socket.send('Hello, WebSocket!');
        setInterval(() => {
            socket.send('Hello, WebSocket! ' + new Date().toLocaleTimeString());
        }, 300);*/
    };

    // 当收到服务器消息时触发
    socket.onmessage = function (event) {
        appendContent(event.data);
    };

    // 当发生错误时触发
    socket.onerror = function (event) {
        appendContent("发生错误:" + JSON.stringify(event));
    };

    // 当连接关闭时触发
    socket.onclose = function (event) {
        appendContent('WebSocket 连接已关闭!');
    };

    // 追加内容到 content
    function appendContent(content) {
        let scroll = isScrollBottom();

        if (hasReg(content, /.*V->.*/g)) {
            content = wrapColor(content, "#9EC5BE");
        } else if (hasReg(content, /.*D->.*/g)) {
            content = wrapColor(content, "#42B00C");
        } else if (hasReg(content, /.*I->.*/g)) {
            content = wrapColor(content, "#32B07D");
        } else if (hasReg(content, /.*W->.*/g)) {
            content = wrapColor(content, "#8F6719");
        } else if (hasReg(content, /.*E->.*/g)) {
            content = wrapColor(content, "#F86967");
        } else if (hasReg(content, /.*A->.*/g)) {
            content = wrapColor(content, "#B42C1D");
        }

        //正则匹配 16:04:35.212
        content = tintColor(content, /\d+:\d+:\d+\.\d+/g, "#b40a0a");

        //content = tintColor(content, /\d+/g, "#4e4915");
        document.getElementById('content').innerHTML += "<br>" + content;
        if (scroll) {
            scrollBottom();
        }
    }

    // 匹配正则内容并着色
    function tintColor(content, reg, color) {
        return content.replace(reg, `<span style="color: \${color};">\$&</span>`);
    }

    function wrapColor(content, color) {
        return `<span style="color: \${color};">` + content + `</span>`;
    }

    // 判断字符串中是否包含正则
    function hasReg(content, reg) {
        return reg.test(content);
    }

    // content 滚动到底部
    function scrollBottom() {
        let contentWrap = document.getElementById('content-wrap');
        let content = document.getElementById('content');
        //console.log(content.scrollHeight);
        contentWrap.scrollTo({
            top: content.scrollHeight,
        });
    }

    //是否滚动到底了
    function isScrollBottom() {
        let contentWrap = document.getElementById('content-wrap');
        let content = document.getElementById('content');
        //debugger;
        return contentWrap.scrollTop + contentWrap.clientHeight >= content.scrollHeight - 60;
    }
</script>
</body>
</html>
  ''';

  //--

  /// 文件浏览头部html
  static String getFilesHeaderHtml(String tile, String parent) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style> * {word-wrap: break-word; padding: 0px} a {line-height: 30px;} .time {color: #d3d3d3;font-size: 12px;} body span {padding: 4px}</style>
</head>
<body>
<h1>$parent</h1>
  ''';

  /// 文件浏览列表html
  static Future<String> getFilesListHtml(String root, String folder) async {
    final buffer = StringBuffer();
    final folderFile = File(folder);
    if (folder.isExistsSync()) {
      if (await folderFile.isDirectory()) {
        //根目录
        buffer.write("<a href='/files?path='>.</a><br>");
        if (root != folder) {
          //上一级目录
          final targetPath = folder.parentPath.replaceAll(root, '');
          buffer.write("<a href='/files?path=$targetPath'>..</a><br>");
        }
        for (final entity
            in folderFile.listFilesSync()?.sortFileList(
                  modifiedTimeDesc: true,
                ) ??
                <FileSystemEntity>[]) {
          final folderName = entity.fileName();
          final targetPath = entity.path.replaceAll(root, '');
          final des = entity.isDirectorySync()
              ? (entity as Directory).listSync().length.toString().connect("项")
              : (entity as File).fileSizeSync().toSizeStr().connect(
                  " ${entity.lastModifiedSync()}",
                );
          buffer.write(
            "<a href='/files?path=$targetPath'>$folderName</a><span class='time'>$des</span><br>",
          );
        }
      } else {
        buffer.write("<p>即将下载文件:$folder<p>");
      }
    } else {
      buffer.write("<p>访问的路径不存在:$folder<p>");
    }

    return buffer.toString();
  }

  /// 文件浏览尾部html
  static String getFilesFooterHtml() => '''
</body>
</html>
  ''';

  //--

  static String getUdpClientListHeaderHtml(String tile, String h1) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {
            word-wrap: break-word;
            padding: 0;
            margin: 0;
        }
        
        * span {
          line-height: 24px;
        }

        a {
            text-decoration: none;
            color: #333;
        }

        .card {
            background-color: #f9f9f9;
            border: 1px solid #f9f9f9;
            border-radius: 5px;
            padding: 10px;
            margin: 10px;
            box-shadow: 0 0 5px #ccc;
            transition: box-shadow 0.3s;
        }

        .card:hover {
            border: 1px solid #0aa6ec;
            border-radius: 5px;
            box-shadow: 0 0 10px #ccc;
        }
        
       .self-card {
            border: 1px solid #c702fd;
        }

    </style>
</head>
<body style="padding: 10px;">
<h1>$h1
    <input type="checkbox" id="refresh_check" checked>
    <label for="refresh_check" style="font-size: 16px">自动刷新</label>
</h1>
<div style="display: flex; flex-wrap: wrap;">
  ''';

  static String getUdpClientListItemHtml(Map map, bool isSelf) =>
      '''
  <a target="_blank" href="${map["address"]}">
      <div class="card ${isSelf ? "self-card" : ""}">
          <p>
            <strong style="margin-right: 4px">平台:</strong>
            <span>${map["platformName"]}</span>
            <span style="margin-left: 4px">${map["packageName"]}</span>
            <span>${map["appVersionName"]}</span>
            <span>(${map["appVersionCode"]})</span>
          </p>
          <p><strong style="margin-right: 4px">设备id:</strong><span>${map["deviceUuid"]}</span></p>
          <p><strong style="margin-right: 4px">设备型号:</strong>   
            <span>${map["brand"]}</span>
            <span>${map["model"]}</span>
            <span>/</span>
            <span>${map["display"]}</span>
          </p>
          <p>
            <strong style="margin-right: 4px">上线时间:</strong>
            <span>${map["startTime"]}</span>
          </p>
      </div>
  </a>
  ''';

  static String getUdpClientListFooterHtml({int refresh = 5000}) =>
      '''
<script>
setInterval(() => {
        if (document.getElementById('refresh_check').checked) {
            location.reload();
        }
    }, $refresh);
</script>
</div>
</body>
</html>
  ''';

  //--

  static String getDebugLogIndexHtml() => '''
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>服务首页</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * {
      word-wrap: break-word;
      padding: 0;
      margin: 0;
    }

    * span {
      line-height: 30px;
    }

    a {
      text-decoration: none;
      color: #333;
    }

    .flex-content {
      display: flex;
      flex-direction: column;
    }

    .flex-full-item {
      flex-grow: 1;
    }

    .card {
      background-color: #f9f9f9;
      border: 1px solid #f9f9f9;
      border-radius: 5px;
      padding: 10px;
      margin: 10px;
      box-shadow: 0 0 5px #ccc;
      transition: box-shadow 0.3s;
    }

    .card:hover {
      border: 1px solid #0aa6ec;
      border-radius: 5px;
      box-shadow: 0 0 10px #ccc;
    }

    /* 添加时间显示样式 */
    .bottom-display {
      text-align: center;
      margin-top: 20px;
      padding: 10px;
      color: #666;
      font-size: 14px;
    }

  </style>
</head>
<body style="padding: 10px; width: 100%; height: 100%">
<h1>服务首页</h1>
<!--复选框-->
<div style="display: flex; flex-wrap: wrap;">
  <a href="/ws">
    <div class="card">
      <p><strong>WebSocket 日志服务</strong></p>
      <p><span>实时查看设备调试信息</span></p>
    </div>
  </a>
  <a href="/files">
    <div class="card">
      <p><strong>Http 文件服务</strong></p>
      <p><span>浏览查看设备文件信息</span></p>
    </div>
  </a>
  <a href="/list">
    <div class="card">
      <p><strong>UDP 客户端服务</strong></p>
      <p><span>浏览查看广播的设备终端信息</span></p>
    </div>
  </a>
</div>
<!-- 在底部插入当前时间 -->
<footer>
  <div class="bottom-display">{{bottomInfo}}</div>
</footer>
</body>
</html>
''';
}
