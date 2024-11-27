part of '../flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/27
///
/// [Path]仿真
class PathSimulationBuilder {
  //region--数据收集--

  /// 上一次的数据
  double lastX = 0;
  double lastY = 0;
  double lastI = 0;
  double lastJ = 0;
  double lastR = 0;

  @entryPoint
  void onStart() {}

  @entryPoint
  void onMoveTo(double x, double y) {
    if (x.notEqualTo(lastX) || y.notEqualTo(lastY)) {
      _generateSimulationInfo(PathSimulationType.move);
      //
      _currentInfo?.path?.moveTo(lastX, lastY);
      _currentInfo?.path?.lineTo(x, y);
      //
      lastX = x;
      lastY = y;
    }
  }

  @entryPoint
  void onLineTo(double x, double y) {
    if (x.notEqualTo(lastX) || y.notEqualTo(lastY)) {
      if (_currentInfo?.type != PathSimulationType.line) {
        _generateSimulationInfo(PathSimulationType.line);
        _currentInfo?.path?.moveTo(lastX, lastY);
      }
      //
      _currentInfo?.path?.lineTo(x, y);
      //
      lastX = x;
      lastY = y;
    }
  }

  /// [startAngle].[sweepAngle]角度单位
  @entryPoint
  void onArcTo(
    double left,
    double top,
    double right,
    double bottom,
    double startAngle,
    double sweepAngle,
  ) {
    assert(() {
      l.w('请注意,暂不支持的操作!');
      return true;
    }());
  }

  @entryPoint
  void onEnd() {
    onEndLoop();
  }

  //endregion--数据收集--

  //region--循环次数--

  /// 循环次数0和1都表示不循环
  int _loopCount = 0;

  /// 循环收集数据的栈结构
  final StackList<List<PathSimulationPart>> _loopStack = StackList();

  /// 开始内部循环
  @entryPoint
  void onStartLoop(int count) {
    _appendLast();
    _loopStack.push([]);
    _loopCount = count;
  }

  /// 结束内部循环
  @entryPoint
  void onEndLoop() {
    _appendLast();
    final last = _loopStack.popOrNull();
    if (last != null) {
      final count = max(_loopCount, 1);
      final list = _operateList;
      for (var i = 1; i <= count; i++) {
        //循环复制
        for (final info in last) {
          list.add(info.copyWith());
        }
      }
      if (list != _result) {
        _result.addAll(list);
      }
    }
    _loopCount = 0;
  }

  /// 当前操作的数据列表
  List<PathSimulationPart> get _operateList => _loopStack.lastOrNull ?? _result;

  //endregion--循环次数--

  //region--辅助输出--

  /// 仿真数据输出的结果
  final List<PathSimulationPart> _result = [];

  PathSimulationPart? _currentInfo;

  /// 新的一段数据收集
  void _generateSimulationInfo(PathSimulationType type) {
    _appendLast();
    _currentInfo = PathSimulationPart(type: type)..start();
  }

  /// 最后一段数据
  void _appendLast() {
    if (_currentInfo?.path != null) {
      _currentInfo!.end();
      if (_currentInfo!.length > 0) {
        _operateList.add(_currentInfo!);
      }
    }
    _currentInfo = null;
  }

  @output
  PathSimulationInfo build() => PathSimulationInfo(_result);

//endregion--辅助输出--
}

/// 仿真数据, 包含每一段的数据
class PathSimulationInfo {
  /// 所有段的集合
  final List<PathSimulationPart> partList;

  //--

  /// 路径的总长度
  double length = 0;

  /// 路径的边界
  Rect? bounds;

  //region--get--

  /// 合并所有路径, 用来测试
  Path get mergePath {
    final path = Path();
    for (final element in partList) {
      if (element.path != null) {
        path.addPath(element.path!, Offset.zero);
      }
    }
    return path;
  }

  //endregion--get--

  PathSimulationInfo(this.partList) {
    length = 0;
    //--
    for (final part in partList) {
      length += part.length;
      //--
      final partBounds = part.bounds;
      if (partBounds != null) {
        if (bounds == null) {
          bounds = partBounds;
        } else {
          bounds = bounds?.expandToInclude(partBounds);
        }
      }
    }
  }
}

/// 仿真一段一段数据
class PathSimulationPart {
  /// 路径类型
  /// 决定绘制时的颜色
  final PathSimulationType type;

  /// 路径, 用来绘制
  Path? path;

  /// 绘制[path]时的颜色, 不指定则根据[type]自动设置
  Color? color;

  //--

  /// [path]的边界, 用来计算外包裹框
  Rect? bounds;

  /// [path]的长度, 用来计算长度
  double length = 0;

  PathSimulationPart({required this.type});

  //--

  /// 开始收集相同类型的路径
  @callPoint
  void start() {
    path = Path();
  }

  /// 结束收集路径
  @callPoint
  void end() {
    if (path != null) {
      bounds = path!.getExactBounds();
      length = path!.length;
    }
  }

  ///copyWith
  PathSimulationPart copyWith({
    PathSimulationType? type,
    Path? path,
    double? length,
    Color? color,
    Rect? bounds,
  }) {
    return PathSimulationPart(type: type ?? this.type)
      ..path = path ?? this.path
      ..length = length ?? this.length
      ..bounds = bounds ?? this.bounds
      ..color = color ?? this.color;
  }
}

/// 当前的路径类型
enum PathSimulationType {
  ///数据之间的空走
  @implementation
  empty,

  ///数据内移动
  move,

  ///数据移动
  line,
  ;
}
