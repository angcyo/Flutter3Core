part of '../../flutter3_basics.dart';

///
/// 分帧加载
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/05
///

mixin FrameSplitLoad<T extends StatefulWidget> on State<T> {
  /// 是否启用分帧加载
  bool enableFrameLoad = false;

  /// 一帧需要加载多少个小部件
  int frameSplitCount = 1;

  /// 多久后加载下一帧
  Duration frameSplitDuration = const Duration(milliseconds: 16);

  /// 当前加载了多少帧
  @protected
  int frameLoadCount = 0;

  ///分帧加载
  /// [originChildren] 原始的需要加载的小部件集合
  @callPoint
  List<Widget> frameLoad(List<Widget> originChildren) {
    if (!enableFrameLoad) {
      return originChildren;
    }
    final maxCount = originChildren.length;
    if (frameLoadCount >= maxCount) {
      frameLoadCount = maxCount;
      return originChildren;
    }
    final loadCount = math.min(frameLoadCount + frameSplitCount, maxCount);
    final result = <Widget>[];
    for (var i = 0; i < loadCount; i++) {
      result.add(originChildren[i]);
    }
    frameLoadCount = loadCount;

    if (frameLoadCount < originChildren.length) {
      _frameLoad?.cancel();
      _frameLoad = postDelayCallback(() {
        _frameLoad = null;
        if (!_isDisposed) {
          updateState();
        }
      }, frameSplitDuration);
    }

    return result;
  }

  bool _isDisposed = false;
  Timer? _frameLoad;

  @override
  void initState() {
    _isDisposed = false;
    frameLoadCount = 0;
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _frameLoad?.cancel();
    _frameLoad = null;
    super.dispose();
  }
}
