part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/02
///
/// 接受外部应用的分享数据
/// https://pub.dev/packages/receive_sharing_intent_plus
///
/// ```
/// //监听平台文件分享流
/// $receiveIntent.fileStream.listen((files) {
///   if (!isNil(files)) {
///     //监听到有需要处理的打开文件
///     if (files!.length == 1 &&
///         (files.first.path.endsWith("xxx"))) {
///       //打开固件文件
///       GlobalConfig.def.getNavigatorState(context)?.pushWidget(
///           FirmwareUpgradePage(firmwareUrl: files.first.path));
///     } else {
///       GlobalConfig.def
///           .getNavigatorState(context)
///           ?.pushWidget(CanvasImportPreviewPage(files));
///     }
///     //处理完之后, 清空
///     $receiveIntent.fileStream.add(null);
///   }
/// });
/// ```
///
class ReceiveIntent {
  /// [ReceiveSharingIntentPlus.getInitialMedia]
  /// [SharedMediaFile]
  final LiveStreamController<List<SharedMediaFile>?> mediaFileStream =
      LiveStreamController(null);

  /// [ReceiveSharingIntentPlus.getInitialText]
  final LiveStreamController<String?> textStream = LiveStreamController(null);

  /// [ReceiveSharingIntentPlus.getInitialTextAsUri]
  final LiveStreamController<Uri?> uriStream = LiveStreamController(null);

  /// 监听文件流,用来处理不同的文件
  /// 合并了[mediaFileStream]和[uriStream]的通知, 只返回对应的文件对象
  final LiveStreamController<List<File>?> fileStream =
      LiveStreamController(null);

  /// 自定义标签数据, 标识属性
  @flagProperty
  dynamic tag;

  ReceiveIntent._() {
    // 首次打开软件时, 检查平台分享数据
    ReceiveSharingIntentPlus.getInitialMedia().get((value, _) {
      if (value is List<SharedMediaFile> && value.isNotEmpty) {
        assert(() {
          l.i('Initial Shared Media[${value.size()}]:${value.map((f) => f.path).join(',') ?? ''}');
          return true;
        }());
        mediaFileStream.add(value);
        fileStream.add(value.map((f) => File(f.path)).toList());
      }
    });
    ReceiveSharingIntentPlus.getInitialText().get((value, _) {
      if (value is String) {
        assert(() {
          l.i('Initial Shared Text:$value');
          return true;
        }());
        textStream.add(value);
      }
    });
    ReceiveSharingIntentPlus.getInitialTextAsUri().get((value, _) {
      if (value is Uri) {
        assert(() {
          l.i('Initial Shared Uri[${value.runtimeType}]:$value');
          return true;
        }());
        uriStream.add(value);
        _handleUri(value);
      }
    });
    // 监听平台分享数据
    ReceiveSharingIntentPlus.getMediaStream().listen((value) {
      assert(() {
        //Shared Media:/data/user/0/com.angcyo.flutter3.abc/cache/PXL_20230627_030415927.jpg

        //Shared Media:/data/user/0/com.angcyo.flutter3.abc/cache/PXL_20230627_030415927.jpg,/data/user/0/com.angcyo.flutter3.abc/cache/IMG_20230417152853656.jpg
        l.i('Shared Media:${value.map((f) => f.path).join(',') ?? ''}');
        return true;
      }());
      mediaFileStream.add(value);
      fileStream.add(value.map((f) => File(f.path)).toList());
    });
    ReceiveSharingIntentPlus.getTextStream().listen((value) {
      assert(() {
        //[String]Shared Text:content://com.tencent.mobileqq.fileprovider/external_files/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/Menlo-Italic.ttf
        l.i('Shared Text:$value');
        return true;
      }());
      textStream.add(value);
    });
    ReceiveSharingIntentPlus.getTextStreamAsUri().listen((value) {
      assert(() {
        //Shared Uri[_SimpleUri][content]:content://com.tencent.mobileqq.fileprovider/external_files/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/test-xlsx.xlsx
        //[String]Shared Uri[_SimpleUri][content]:content://com.tencent.mobileqq.fileprovider/external_files/storage/emulated/0/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/Menlo-Italic.ttf
        l.i('Shared Uri[${value.runtimeType}][${value.scheme}]:$value');
        return true;
      }());
      uriStream.add(value);
      _handleUri(value);
    });
  }

  /// 处理[Uri]
  void _handleUri(Uri uri) {
    if (uri.scheme == "content") {
      uri_to_file.toFile("$uri").get((file, _) {
        if (file is File) {
          fileStream.add([file]);
        }
      });
    } else {
      try {
        final file = File.fromUri(uri);
        fileStream.add([file]);
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
  }
}

/// 接收平台数据
@initialize
final ReceiveIntent $receiveIntent = ReceiveIntent._();
