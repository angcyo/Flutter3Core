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
  void onMoveTo(double x, double y, {PathSimulationType? type}) {
    if (x.notEqualTo(lastX) || y.notEqualTo(lastY)) {
      _generateSimulationInfo(type ?? PathSimulationType.move);
      //
      _currentInfo?.startPoint(lastX, lastY, isMovePoint: true);
      _currentInfo?.addPoint(x, y, isMovePoint: true);
      //
      lastX = x;
      lastY = y;
    }
  }

  @entryPoint
  void onLineTo(
    double x,
    double y, {
    double? powerRatio,
  }) {
    if (x.notEqualTo(lastX) || y.notEqualTo(lastY)) {
      if (_currentInfo?.type != PathSimulationType.line) {
        _generateSimulationInfo(PathSimulationType.line);
        _currentInfo?.powerRatio = powerRatio;
        /*assert(() {
          l.d('powerRatio->$powerRatio');
          return true;
        }());*/
        _currentInfo?.startPoint(lastX, lastY, isMovePoint: true);
      }
      //
      _currentInfo?.addPoint(x, y);
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
    double sweepAngle, {
    double? powerRatio,
  }) {
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
    final lastPartList = _loopStack.popOrNull();
    if (lastPartList != null) {
      final count = max(_loopCount, 1);
      final list = _operateList;

      //循环的上一次的终点位置, 就是下一次循环的起始位置
      double? endPointX;
      double? endPointY;
      for (var i = 1; i <= count; i++) {
        //循环复制
        lastPartList.forEachIndexed((partIndex, part) {
          final newPart = part.copyWith();
          if (partIndex == 0 && i > 1) {
            //多次循环, 第一段需要移动到上一次的终点位置
            //并且要创建一条移动part
            list.add(PathSimulationPart(type: PathSimulationType.empty)
              ..startPoint(endPointX, endPointY)
              ..addPoint(newPart._lastMovePointX, newPart._lastMovePointY)
              ..build());

            //--
            newPart.build(
              newStartPointX: newPart.endPointX,
              newStartPointY: newPart.endPointY,
            );
          }
          endPointX = newPart.endPointX;
          endPointY = newPart.endPointY;
          list.add(newPart);
        });
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
    _currentInfo = PathSimulationPart(type: type);
  }

  /// 最后一段数据
  void _appendLast() {
    if (_currentInfo != null) {
      _currentInfo!.build();
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

  /// 路径, 用来绘制. 请不要直接使用此属性操作数据
  /// 点位数据应该先存到[_points]中, 然后通过[build]方法构建数据
  Path? path;

  /// 绘制[path]时的颜色, 不指定则根据[type]自动设置
  Color? color;

  /// 功率比例, 比例越大说明当前段使用的功率越大
  double? powerRatio;

  /// [powerRatio]对应的灰度值
  int? get _grey => powerRatio == null
      ? null
      : (255 * (1.0 - powerRatio!)).round().clamp(0, 255);

  /// 绘制时的颜色
  Color? get paintColor =>
      color ??
      (_grey == null ? null : Color.fromARGB(255, _grey!, _grey!, _grey!));

  //--

  /// [path]的边界, 用来计算外包裹框
  Rect? bounds;

  /// [path]的长度, 用来计算长度
  double length = 0;

  //--

  /// 开始的位置
  double? _startPointX;
  double? _startPointY;

  /// 一直空移动的最后一个点
  double? _lastMovePointX;
  double? _lastMovePointY;

  /// 存储路径的点位数据
  /// [path]
  final List<Offset> _points = [];

  /// 获取最后一个点的坐标
  /// 在下次循环[PathSimulationPart]时, 应该将最后一次的点坐标赋值给[_startPointX].[_startPointY]
  double? get endPointX => _points.lastOrNull?.dx;

  double? get endPointY => _points.lastOrNull?.dy;

  PathSimulationPart({required this.type});

  //--

  /// 开始收集相同类型的路径
  @callPoint
  void startPoint(
    double? x,
    double? y, {
    bool? isMovePoint,
  }) {
    _startPointX = x;
    _startPointY = y;
    if (isMovePoint == true) {
      _lastMovePointX = x;
      _lastMovePointY = y;
    }
  }

  /// [isMovePoint]是否是move产生的点
  @callPoint
  void addPoint(
    double? x,
    double? y, {
    bool? isMovePoint,
  }) {
    if (x != null && y != null) {
      _points.add(Offset(x, y));
    }
    if (isMovePoint == true) {
      _lastMovePointX = x;
      _lastMovePointY = y;
    }
  }

  /// 结束点位收集, 并构建路径
  @callPoint
  void build({
    double? newStartPointX,
    double? newStartPointY,
  }) {
    _startPointX = newStartPointX ?? _startPointX;
    _startPointY = newStartPointY ?? _startPointY;
    //--
    final path = Path();
    if (_startPointX != null && _startPointY != null) {
      path.moveTo(_startPointX!, _startPointY!);
    }
    for (final point in _points) {
      path.lineTo(point.dx, point.dy);
    }
    //--
    bounds = path.getExactBounds();
    length = path.length;
    this.path = path;
  }

  ///copyWith
  PathSimulationPart copyWith({
    PathSimulationType? type,
    Path? path,
    double? length,
    Color? color,
    Rect? bounds,
    double? startPointX,
    double? startPointY,
    double? lastMovePointX,
    double? lastMovePointY,
    List<Offset>? points,
  }) {
    return PathSimulationPart(type: type ?? this.type)
      ..path = path ?? this.path
      ..length = length ?? this.length
      ..bounds = bounds ?? this.bounds
      ..color = color ?? this.color
      .._startPointX = startPointX ?? _startPointX
      .._startPointY = startPointY ?? _startPointY
      .._lastMovePointX = lastMovePointX ?? _lastMovePointX
      .._lastMovePointY = lastMovePointY ?? _lastMovePointY
      .._points.addAll(points ?? _points);
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
