part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/11
///
/// dio 下载文件混入
mixin DioDownloadMixin {
  /// 用来取消下载
  CancelToken? downloadTokenMixin;

  /// 下载的状态
  DownloadState downloadStateMixin = .none;

  /// 下载进度[0~1]
  double downloadProgressMixin = 0;

  String downloadFilePathCacheMixin = "";

  //MARK: - api

  /// 尝试更新状态, 如果可以
  /// [StateEx.updateState]
  @api
  void tryUpdateState() {
    final state = this;
    if (state is State) {
      (state as State).updateState();
    }
  }

  /// 开始下载
  /// `/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/cache/AutoCalibrate-2.4.0_apk_release_app.apk`
  /// @return 下载成功返回本地路径
  @api
  Future<String?> startDownloadMixin(String url) async {
    downloadTokenMixin?.cancel();
    downloadTokenMixin = CancelToken();

    downloadProgressMixin = 0;
    downloadStateMixin = .downloading;
    final name = url.fileName();
    final filePath = await cacheFilePath(name);
    downloadFilePathCacheMixin = filePath;
    await url
        .download(
          savePath: filePath,
          overwrite: isDebug,
          cancelToken: downloadTokenMixin,
          onReceiveProgress: (count, total) {
            if (total > 0) {
              //l.d("下载进度:$count/$total ${count.toSizeStr()}/${total.toSizeStr()} ${(count / total * 100).toDigits(digits: 2)}% \n[$url]->[$filePath]");
              downloadProgressMixin = count / total;
              tryUpdateState();
            } else {
              //l.d("下载进度:$count ${count.toSizeStr()} \n[$url]->[$filePath]");
              downloadProgressMixin = 0;
            }
          },
        )
        .get((response, error) {
          if (response != null) {
            downloadStateMixin = .downloaded;
            tryUpdateState();
            onDownloadSuccess(filePath);
            //l.d("下载完成:$filePath");
          } else if (error != null) {
            if (downloadProgressMixin == -1) {
              downloadProgressMixin = 0;
            }
            downloadStateMixin = .downloadFailed;
            tryUpdateState();
          }
        });
    return filePath;
  }

  /// 取消下载
  @api
  void cancelDownloadMixin() {
    downloadTokenMixin?.cancel();
    downloadStateMixin = .none;
    downloadProgressMixin = 0;
    tryUpdateState();
  }

  /// 下载成功后的回调
  @overridePoint
  void onDownloadSuccess(String filePath) {}

  //MARK: - build

  /// 构建下载进度小部件
  Widget? buildProgressWidget(BuildContext context) {
    double progress = downloadProgressMixin;
    if (downloadStateMixin == .none) {
      return null;
    }
    //debugger();
    return ProgressBar(
      progress: progress == -1 ? 1 : progress,
      enableFlowProgressAnimate: downloadStateMixin == .downloading,
    ).size(height: 6).insets(vertical: kL);
  }
}
