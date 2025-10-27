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

  /// 调用了更新操作之后, 输出的元素边界
  /// - [updateNewX]
  /// - [updateNewY]
  /// - [updateNewW]
  /// - [updateNewH]
  @output
  Rect? get outputBounds {
    if (x == null || y == null || w == null || h == null) {
      return null;
    }
    return Rect.fromLTWH(x ?? 0, y ?? 0, w ?? 0, h ?? 0);
  }

  /// 一定输出dp单位的坐标
  @dp
  @output
  Rect? get outputBoundsDp {
    if (_unit == null || _unit is DpUnit) {
      return outputBounds;
    }
    if (x == null || y == null || w == null || h == null) {
      return null;
    }
    return Rect.fromLTWH(
      x?.toDpFromUnit(_unit) ?? 0,
      y?.toDpFromUnit(_unit) ?? 0,
      w?.toDpFromUnit(_unit) ?? 0,
      h?.toDpFromUnit(_unit) ?? 0,
    );
  }

  //--

  /// 初始化数据
  /// - [painter] 可以使用元素初始化, 后续会自动操作元素
  /// - [elementsBounds] 也可以直接使用坐标初始化,
  /// - [unit] 当前画布的单位, 不指定则默认dp
  @api
  void initFrom({
    ElementPainter? painter,
    @dp Rect? elementsBounds,
    IUnit? unit,
  }) {
    _targetPainter = painter ?? _targetPainter;
    _unit = unit ?? _unit;

    //角度
    angle = _targetPainter?.paintProperty?.angle.jd.round();

    @dp
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
    @unit num? newX, {
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
      }
      x = newX.toDouble();
    }
  }

  /// 更新新的[y]坐标
  @api
  void updateNewY(
    @unit num? newY, {
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
      }
      y = newY.toDouble();
    }
  }

  /// 更新新的[w]宽度
  @api
  void updateNewW(
    @unit num? newW, {
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
        //debugger();
        controlManager.updateElementSize(
          painter,
          width: newW.toDpFromUnit(_unit),
          height: null,
        );
      }
      w = newW.toDouble();
    }
  }

  /// 更新新的[h]宽度
  @api
  void updateNewH(
    @unit num? newH, {
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
          /*debugLabel: "test",*/
        );
      }
      h = newH.toDouble();
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
      }
      //angle = newAngle as double?;
    }
  }
}
