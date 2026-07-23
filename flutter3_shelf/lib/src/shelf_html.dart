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

  /// 获取点击按钮上传文件的html
  static String getUploadFileHtml({
    String title = "发送文件",
    String button = "点击上传图片",
    String action = "/upload",
  }) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$title</title>
    <!--移动端适配-->
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
            height: 100%;
        }

        /* 样式用于垂直排列表单元素 */
        form {
            display: flex;
            flex-direction: column;
            align-items: center;
            pointer-events: none;
        }

        .submit {
            position: relative;
            display: inline-block;
            background: #D0EEFF;
            border: 1px solid #99D3F5;
            border-radius: 4px;
            padding: 4px 12px;
            overflow: hidden;
            color: #1E88C7;
            min-width: 50%;
            margin: 0 0 10px 10px;
            text-decoration: none;
            text-indent: 0;
            line-height: 30px;
        }

        /*虚线边框, 灰色填充*/
        .file-upload {
            border: 2px dashed #ccc;
            background: #f9f9f9;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            border-radius: 5px;
            width: 100%;
            margin: 0 40px;
        }

        /*加载动画div样式*/
        .loading {
            display: none;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.8);
            z-index: 100;
            justify-content: center;
            align-items: center;
            user-select: none;
            pointer-events: none;
            animation: rotate 2s linear infinite;
        }

        @keyframes rotate {
            from {
                transform: rotate(0deg); /* 从0度开始旋转 */
            }
            to {
                transform: rotate(360deg); /* 旋转到360度 */
            }
        }
    </style>
</head>
<body>
<div class="centered-content">
    <div class="file-upload" id="file-upload">
        <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
             width="80" height="80">
            <path d="M872.448 939.008H151.552l-40.96-40.96V299.008l40.96-40.96h158.72v81.92H192.512v517.12h638.976V339.968H713.728v-81.92h158.72l40.96 40.96v599.04z"
                  fill="#437DFF"></path>
            <path d="M387.072 229.376l-34.816-50.176 138.24-94.208h34.816l131.072 94.208-35.84 50.176-113.664-81.92z"
                  fill="#63F7DE"></path>
            <path d="M473.088 137.216h61.44v370.688h-61.44z" fill="#63F7DE"></path>
        </svg>
        <p>$button</p>
        <form action="$action" method="post" enctype="multipart/form-data">
            <input type="file" name="file" style="display: none" id="file">
            <!--<input type="submit" value="发送" class="submit">-->
        </form>
        <div class="loading" id="loading">
            <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
                 width="50" height="50">
                <path d="M469.333333 85.333333m42.666667 0l0 0q42.666667 0 42.666667 42.666667l0 128q0 42.666667-42.666667 42.666667l0 0q-42.666667 0-42.666667-42.666667l0-128q0-42.666667 42.666667-42.666667Z"
                      fill="#000000" opacity=".8"></path>
                <path d="M469.333333 725.333333m42.666667 0l0 0q42.666667 0 42.666667 42.666667l0 128q0 42.666667-42.666667 42.666667l0 0q-42.666667 0-42.666667-42.666667l0-128q0-42.666667 42.666667-42.666667Z"
                      fill="#000000" opacity=".4"></path>
                <path d="M938.666667 469.333333m0 42.666667l0 0q0 42.666667-42.666667 42.666667l-128 0q-42.666667 0-42.666667-42.666667l0 0q0-42.666667 42.666667-42.666667l128 0q42.666667 0 42.666667 42.666667Z"
                      fill="#000000" opacity=".2"></path>
                <path d="M298.666667 469.333333m0 42.666667l0 0q0 42.666667-42.666667 42.666667l-128 0q-42.666667 0-42.666667-42.666667l0 0q0-42.666667 42.666667-42.666667l128 0q42.666667 0 42.666667 42.666667Z"
                      fill="#000000" opacity=".6"></path>
                <path d="M783.530667 180.138667m30.169889 30.169889l0 0q30.169889 30.169889 0 60.339779l-90.509668 90.509668q-30.169889 30.169889-60.339779 0l0 0q-30.169889-30.169889 0-60.339779l90.509668-90.509668q30.169889-30.169889 60.339779 0Z"
                      fill="#000000" opacity=".1"></path>
                <path d="M330.965333 632.661333m30.16989 30.16989l0 0q30.169889 30.169889 0 60.339778l-90.509668 90.509668q-30.169889 30.169889-60.339779 0l0 0q-30.169889-30.169889 0-60.339778l90.509668-90.509668q30.169889-30.169889 60.339779 0Z"
                      fill="#000000" opacity=".5"></path>
                <path d="M843.861333 783.530667m-30.169889 30.169889l0 0q-30.169889 30.169889-60.339779 0l-90.509668-90.509668q-30.169889-30.169889 0-60.339779l0 0q30.169889-30.169889 60.339779 0l90.509668 90.509668q30.169889 30.169889 0 60.339779Z"
                      fill="#000000" opacity=".3"></path>
                <path d="M391.338667 330.965333m-30.16989 30.16989l0 0q-30.169889 30.169889-60.339778 0l-90.509668-90.509668q-30.169889-30.169889 0-60.339779l0 0q30.169889-30.169889 60.339778 0l90.509668 90.509668q30.169889 30.169889 0 60.339779Z"
                      fill="#000000" opacity=".7"></path>
            </svg>
        </div>
    </div>
</div>
<script>
    document.getElementById('file-upload').addEventListener('click', function (e) {
        document.getElementById('file').click();
        if (document.getElementById('loading').style.display === 'flex') {
            e.stopPropagation();
            e.preventDefault();
        }
    });
    document.getElementById('file').addEventListener('change', function () {
        showLoading();
        document.querySelector('form').submit();
    });

    function showLoading() {
        document.getElementById('loading').style.display = 'flex';
    }
</script>
</body>
</html>
''';
}
