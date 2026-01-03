part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/03
///
/// 日志文件混入
mixin DebugFileListStateMixin<T extends StatefulWidget> on State<T> {
  /// 当前加载的文件夹路径
  /// - 文件夹
  String? currentLoadFolderPath;

  /// 选中的文件路径
  /// - 文件
  String? selectFilePath;

  /// 加载出错时的数据
  @output
  dynamic loadError;

  /// 加载出来的文件列表, 如果为null, 则表示正在加载中
  @output
  List<FileSystemEntity>? loadFileList;

  //--

  /// 之前加载的文件夹路径
  @output
  String? beforeLoadFolderPath;

  //MARK: - build

  /// 构建文件列表
  @callPoint
  WidgetList buildFileListWidget(BuildContext context) {
    return [
      if (!isNil(loadFileList))
        for (final path in loadFileList!)
          DebugFileTile(
            path: path.path,
            onTap: loadPathMixin,
            isSelected: path.path == selectFilePath,
            onDeleteAction: () {
              loadPathMixin(currentLoadFolderPath);
            },
          ),
    ];
  }

  //MARK: - api

  /// 加载指定路径
  @api
  void loadPathMixin(String? path) {
    assert(() {
      l.d('准备加载路径:$path');
      return true;
    }());
    if (path?.isFileSync() == true) {
      selectFilePath = path;
      updateState();
      return;
    }

    loadError = null;
    loadFileList = null;
    beforeLoadFolderPath = currentLoadFolderPath;
    currentLoadFolderPath = path;
    onSelfLoadPath(path);

    /*compute<String?, List<FileSystemEntity>?>(
            (message) => message?.folder.listFilesSync(), path)
        .getValue((value, error) {
      _fileList = value;
      updateState();
    });*/

    io(
      path,
      (message) => message?.folder.listFilesSync(throwError: true),
    ).getValue((value, error) {
      assert(() {
        l.d('加载[$path]->$value $error');
        return true;
      }());
      loadFileList = value;
      loadError = error;
      onSelfDidLoadPath(path);
    });
  }

  //MARK: - override

  /// 开始加载[path]的回调
  /// - [currentLoadFolderPath]
  @overridePoint
  void onSelfLoadPath(String? path) {
    //_pathScrollController.scrollToBottom();
    updateState();
  }

  /// 文件夹加载结束之后的回调
  /// - [loadFileList]
  /// - [loadError]
  @overridePoint
  void onSelfDidLoadPath(String? path) {
    //_pathScrollController.scrollToBottom();
    updateState();
  }
}

/// 用来显示文件列表的界面
/// - 直接使用 [DebugFilePage]
@implementation
class DebugFileListWidget extends StatefulWidget {
  /// 文件夹路径
  final String? folderPath;

  const DebugFileListWidget({super.key, this.folderPath});

  @override
  State<DebugFileListWidget> createState() => _DebugFileListWidgetState();
}

class _DebugFileListWidgetState extends State<DebugFileListWidget>
    with DebugFileListStateMixin {
  @override
  void initState() {
    super.initState();
    loadPathMixin(widget.folderPath);
  }

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return [
          if (loadFileList?.isEmpty == true)
            globalConfig
                .emptyPlaceholderBuilder(
                  context,
                  LibRes.maybeOf(context)?.libAdapterNoData ?? "暂无数据",
                )
                .align(Alignment.center)
                .insets(top: 40),
          ...buildFileListWidget(context),
        ].scrollVertical() ??
        "loading...".text().insets(all: kX);
  }
}
