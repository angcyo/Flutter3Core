part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/25
///
/// 文件列表浏览界面
class DebugFileFragment extends StatefulWidget {
  /// 初始化的路径, 不指定则使用默认的
  final String? initPath;

  const DebugFileFragment({super.key, this.initPath});

  @override
  State<DebugFileFragment> createState() => _DebugFileFragmentState();
}

class _DebugFileFragmentState extends State<DebugFileFragment>
    with AbsScrollPage {
  final ScrollController _pathScrollController = ScrollController();

  /// 当前加载的路径
  String? currentLoadPath;

  /// 加载出来的文件列表, 如果为null, 则表示正在加载中
  List<FileSystemEntity>? _fileList;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: [
        loadCoreAssetSvgPicture(
          Assets.assetsCore.svg.fileBrowseHome,
          width: 25,
          height: 25,
        )?.inkWellCircle(onTap: () {
          _reload();
        }),
        currentLoadPath
            ?.text(style: globalTheme.textTitleStyle)
            .scroll(
                scrollDirection: Axis.horizontal,
                controller: _pathScrollController)
            .paddingSymmetric(horizontal: kX)
            .ink(onTap: () {
          _loadPath(currentLoadPath?.parentPath);
        }).expanded(),
      ].row()!.paddingAll(kX).safeArea(),
    );
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  /// 重新加载
  void _reload() {
    if (widget.initPath == null) {
      fileDirectory().getValue((value, error) {
        //l.d(value);
        _loadPath(value?.path);
        postCallback(() {
          _pathScrollController.scrollToBottom();
        });
      });
    } else {
      _loadPath(widget.initPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildPathWidget(context, currentLoadPath);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      return _buildPathWidget(context, _beforePath);
    }
  }

  Widget _buildPathWidget(BuildContext context, String? path) {
    final globalConfig = GlobalConfig.of(context);
    return buildScaffold(context, children: [
      if (_fileList == null)
        globalConfig
            .loadingIndicatorBuilder(context, null)
            .align(Alignment.center)
            .sliverExpand(),
      if (_fileList?.isEmpty == true) "No Data".text().align(Alignment.center),
      if (_fileList != null)
        for (var path in _fileList!)
          DebugFileTile(
            path: path.path,
            onTap: _loadPath,
          ),
    ]);
  }

  String? _beforePath;

  /// 加载指定路径
  void _loadPath(String? path) {
    assert(() {
      l.d('准备加载路径:$path');
      return true;
    }());
    _fileList = null;
    _beforePath = currentLoadPath;
    currentLoadPath = path;
    _pathScrollController.scrollToBottom();
    updateState();

    /*compute<String?, List<FileSystemEntity>?>(
            (message) => message?.folder.listFilesSync(), path)
        .getValue((value, error) {
      _fileList = value;
      updateState();
    });*/

    io(path, (message) => message?.folder.listFilesSync())
        .getValue((value, error) {
      _fileList = value;
      updateState();
    });
  }
}
