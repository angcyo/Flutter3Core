part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/21
///
/// 专门用来处理元素[ElementPainter]的x y w h数据的类
class PainterSizeHandler {
  /// 按照[IUnit]输出的坐标数据
  @output
  @unit
  double? x;
  String? xString;

  @output
  @unit
  double? y;
  String? yString;

  @output
  @unit
  double? w;
  String? wString;

  @output
  @unit
  double? h;
  String? hString;

  /// 旋转的角度
  int? angle;

  //--

  @configProperty
  bool showSuffix = false;
  @configProperty
  int? fractionDigits;
  @configProperty
  bool removeZero = false;
  @configProperty
  bool ensureInt = false;
  @configProperty
  String space = "";

  //--

  /// 目标需要控制操作的元素
  @property
  ElementPainter? _targetPainter;
  @property
  IUnit? _unit;

  //--

  /// 初始化数据
  /// - [painter] 可以使用元素初始化, 后续会自动操作元素
  /// - [elementsBounds] 也可以直接使用坐标初始化,
  /// - [axisUnit] 当前画布的单位, 不指定则默认dp
  @api
  void initFrom({
    ElementPainter? painter,
    @dp Rect? elementsBounds,
    IUnit? axisUnit,
  }) {
    _targetPainter = painter ?? _targetPainter;
    _unit = axisUnit ?? _unit;

    //角度
    angle = _targetPainter?.paintProperty?.angle.jd.round();

    final bounds = _targetPainter?.elementsBounds ?? elementsBounds;
    if (bounds == null) {
      return;
    }

    //w/h
    final Size size = bounds.size;
    final width = _unit?.toUnit(size.width.toPixelFromDp()) ?? size.width;
    final widthString =
        _unit?.format(
          width,
          showSuffix: showSuffix,
          removeZero: removeZero,
          ensureInt: ensureInt,
          space: space,
        ) ??
        width.toDigits(
          digits: fractionDigits ?? 2,
          removeZero: removeZero,
          ensureInt: ensureInt,
        );
    w = width;
    wString = widthString;

    final height = _unit?.toUnit(size.height.toPixelFromDp()) ?? size.height;
    final heightString =
        _unit?.format(
          height,
          showSuffix: showSuffix,
          removeZero: removeZero,
          ensureInt: ensureInt,
          space: space,
        ) ??
        height.toDigits(
          digits: fractionDigits ?? 2,
          removeZero: removeZero,
          ensureInt: ensureInt,
        );
    h = height;
    hString = heightString;

    //x/y
    final Offset location = bounds.lt;
    final x = _unit?.toUnit(location.dx.toPixelFromDp()) ?? location.dx;
    final xString =
        _unit?.format(
          x,
          showSuffix: showSuffix,
          removeZero: removeZero,
          ensureInt: ensureInt,
          space: space,
        ) ??
        x.toDigits(
          digits: fractionDigits ?? 2,
          removeZero: removeZero,
          ensureInt: ensureInt,
        );
    this.x = x;
    this.xString = xString;

    final y = _unit?.toUnit(location.dy.toPixelFromDp()) ?? location.dy;
    final yString =
        _unit?.format(
          y,
          showSuffix: showSuffix,
          removeZero: removeZero,
          ensureInt: ensureInt,
          space: space,
        ) ??
        y.toDigits(
          digits: fractionDigits ?? 2,
          removeZero: removeZero,
          ensureInt: ensureInt,
        );
    this.y = y;
    this.yString = yString;
  }

  /// 更新新的[x]坐标
  @api
  void updateNewX(
    num? newX, {
    CanvasDelegate? canvasDelegate,
    CanvasElementControlManager? controlManager,
    //--
    ElementPainter? painter,
  }) {
    if (newX != null) {
      controlManager ??=
          canvasDelegate?.canvasElementManager.canvasElementControlManager;
      painter ??= _targetPainter;
      if (controlManager != null && painter != null) {
        controlManager.translateElement(
          painter,
          dx: (newX - x!).toDpFromUnit(_unit),
          dy: null,
        );
        //x = newX as double?;
      } else {
        assert(() {
          l.w("操作被忽略, 请检查对象[CanvasDelegate].[CanvasElementControlManager]");
          return true;
        }());
      }
    }
  }

  /// 更新新的[y]坐标
  @api
  void updateNewY(
    num? newY, {
    CanvasDelegate? canvasDelegate,
    CanvasElementControlManager? controlManager,
    //--
    ElementPainter? painter,
  }) {
    if (newY != null) {
      controlManager ??=
          canvasDelegate?.canvasElementManager.canvasElementControlManager;
      painter ??= _targetPainter;
      if (controlManager != null && painter != null) {
        controlManager.translateElement(
          painter,
          dx: null,
          dy: (newY - y!).toDpFromUnit(_unit),
        );
        //y = newY as double?;
      } else {
        assert(() {
          l.w("操作被忽略, 请检查对象[CanvasDelegate].[CanvasElementControlManager]");
          return true;
        }());
      }
    }
  }

  /// 更新新的[w]宽度
  @api
  void updateNewW(
    num? newW, {
    CanvasDelegate? canvasDelegate,
    CanvasElementControlManager? controlManager,
    //--
    ElementPainter? painter,
  }) {
    if (newW != null) {
      controlManager ??=
          canvasDelegate?.canvasElementManager.canvasElementControlManager;
      painter ??= _targetPainter;
      if (controlManager != null && painter != null) {
        debugger();
        controlManager.updateElementSize(
          painter,
          width: newW.toDpFromUnit(_unit),
          height: null,
        );
        //w = newW as double?;
      } else {
        assert(() {
          l.w("操作被忽略, 请检查对象[CanvasDelegate].[CanvasElementControlManager]");
          return true;
        }());
      }
    }
  }

  /// 更新新的[h]宽度
  @api
  void updateNewH(
    num? newH, {
    CanvasDelegate? canvasDelegate,
    CanvasElementControlManager? controlManager,
    //--
    ElementPainter? painter,
  }) {
    if (newH != null) {
      controlManager ??=
          canvasDelegate?.canvasElementManager.canvasElementControlManager;
      painter ??= _targetPainter;
      if (controlManager != null && painter != null) {
        controlManager.updateElementSize(
          painter,
          width: null,
          height: newH.toDpFromUnit(_unit),
        );
        //h = newH as double?;
      } else {
        assert(() {
          l.w("操作被忽略, 请检查对象[CanvasDelegate].[CanvasElementControlManager]");
          return true;
        }());
      }
    }
  }

  /// 更新新的[angle]角度
  @api
  void updateNewAngle(
    num? newAngle, {
    CanvasDelegate? canvasDelegate,
    CanvasElementControlManager? controlManager,
    //--
    ElementPainter? painter,
  }) {
    if (newAngle != null) {
      controlManager ??=
          canvasDelegate?.canvasElementManager.canvasElementControlManager;
      painter ??= _targetPainter;
      if (controlManager != null && painter != null) {
        final angle = painter.paintProperty?.angle.jd.round() ?? 0;
        final r = newAngle.hd - angle.hd;
        //debugger();
        controlManager.rotateElement(painter, r, refTargetRadians: newAngle.hd);
        //angle = newAngle as double?;
      } else {
        assert(() {
          l.w("操作被忽略, 请检查对象[CanvasDelegate].[CanvasElementControlManager]");
          return true;
        }());
      }
    }
  }
}
