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
  String? currentLoadPath;

  @override
  void initState() {
    super.initState();
    /*fileDirectory().get((value, error) {
      rootFolderPath = (value as Directory?)?.path;
    });*/
    if (widget.initPath == null) {
      fileDirectory().getValue((value, error) {
        l.d(value);
        currentLoadPath = value?.path;
        updateState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return buildScaffold(context, children: [
      for (var path in currentLoadPath?.folder.listSync() ?? [])
        DebugFileTile(
          path: path.path,
          onTap: _loadPath,
        ),
    ]);
  }

  /// 加载指定路径
  void _loadPath(String path) {
    currentLoadPath = path;
    updateState();
  }
}
