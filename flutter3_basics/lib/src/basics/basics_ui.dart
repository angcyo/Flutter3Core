part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

//region 帧相关

/// 立即安排一帧
void scheduleFrame() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.scheduleFrame();
}

/// 一帧后回调, 只会触发一次. 不会请求新的帧
void postFrameCallback(FrameCallback callback) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback(callback);
}

/// 每一帧都会回调
/// @return id
int scheduleFrameCallback(FrameCallback callback, {bool rescheduling = false}) {
  WidgetsFlutterBinding.ensureInitialized();
  return WidgetsBinding.instance
      .scheduleFrameCallback(callback, rescheduling: rescheduling);
}

extension FrameCallbackEx on int {
  /// 取消帧回调
  cancelFrameCallbackWithId() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.cancelFrameCallbackWithId(this);
  }
}

//endregion 帧相关

//region 界面相关

typedef WidgetList = List<Widget>;

extension WidgetListEx on WidgetList {
  /// 将当前的小部件集合, 包裹在一个[Wrap]中
  /// [alignment] 主轴对齐方式
  /// [crossAxisAlignment] 交叉轴对齐方式
  Widget wrap({
    double spacing = 8,
    double runSpacing = 8,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      direction: direction,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      children: this,
    );
  }
}

extension WidgetEx on Widget {
  //region ---Padding---

  /// 将当前的小部件, 包裹在一个[Padding]中
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget paddingLTRB(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        left,
        top,
        right,
        bottom,
      ),
      child: this,
    );
  }

  /// 对称
  Widget paddingSymmetric({double vertical = 0, double horizontal = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: vertical,
        horizontal: horizontal,
      ),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

/*Widget paddingFromWindowPadding() {
    return Padding(
      padding: EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio),
      child: this,
    );
  }*/

  //endregion ---Padding---

  //region ---Flexible---

  /// 占满剩余空间的多少比例, 弹性系数
  /// [Flex]
  ///  - [Row]
  ///  - [Column]
  /// [Flexible]
  ///  - [Expanded]
  /// [Spacer] 空白占位 `const SizedBox.shrink()`
  Widget expanded({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(
      flex: flex,
      fit: fit,
      child: this,
    );
  }

  //endregion ---Flexible---

  //region ---SafeArea---

  /// 将当前的小部件, 包裹在一个[SafeArea]中
  Widget safeArea({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: this,
    );
  }

  //endregion ---SafeArea---

  /// 忽略小部件内的所有手势
  Widget ignorePointer({bool ignoring = true}) {
    return IgnorePointer(
      ignoring: ignoring,
      child: this,
    );
  }

  /// 消耗小部件内的所有手势
  Widget absorbPointer({bool absorbing = true}) {
    return AbsorbPointer(
      absorbing: absorbing,
      child: this,
    );
  }

  /// 圆角
  Widget radiusAll(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  /// 添加一个高度
  /// [PhysicalModel]
  Widget elevation(double elevation, {Color? color, Color? shadowColor}) {
    return PhysicalModel(
      color: color ?? Colors.transparent,
      shadowColor: shadowColor ?? const Color(0xFF000000),
      elevation: elevation,
      child: this,
    );
  }
}

extension StateEx on State {
  void updateState() {
    setState(() {});
  }
}

/// [ConditionalElementVisitor] 返回false 可以停止遍历
/// [depth] 从0开始的递归深度
typedef ConditionalElementVisitorDepth = bool Function(
    Element element, int depth, int childIndex);

extension ContextEx on BuildContext {
  /// 请求焦点, 传null, 可以收起键盘
  requestFocus([FocusNode? node]) {
    FocusScope.of(this).requestFocus(node ?? FocusNode());
  }

  /// 显示一个 [SnackBar]
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      SnackBar snackBar) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// 遍历所有的子元素
  /// [visitor] 返回false 可以停止遍历
  eachVisitChildElements(
    ConditionalElementVisitorDepth visitor, {
    int depth = 0,
  }) {
    if (owner == null || debugDoingBuild) {
      return;
    }
    int childIndex = 0;
    visitChildElements((element) {
      bool interrupt = !visitor(element, depth, childIndex++);
      if (!interrupt) {
        element.eachVisitChildElements(visitor, depth: depth + 1);
      }
    });
  }
}

extension RenderObjectEx on RenderObject {
  /// 获取RenderObject的大小
  Size? getSizeOrNull() {
    if (this is RenderBox) {
      return (this as RenderBox).size;
    }
    return null;
  }

  /// 获取RenderObject的全局绘制位置和坐标大小
  Rect? getRenderObjectBounds([RenderObject? ancestor]) {
    var offset = getOffsetOrNull(ancestor);
    var size = getSizeOrNull();
    if (offset != null && size != null) {
      return offset & size;
    }
    return null;
  }

  /// 获取RenderObject的位置
  Offset? getOffsetOrNull([RenderObject? ancestor]) {
    if (this is RenderBox) {
      final Offset location =
          (this as RenderBox).localToGlobal(Offset.zero, ancestor: ancestor);
      return location;
    }
    return null;
  }
}

extension ElementEx on Element {}

//endregion 界面相关

//region 导航相关

/// 导航扩展
///使用 ModalRoute.of(context).settings.arguments; 获取参数
extension NavigatorEx on BuildContext {
  /// 推送一个路由
  Future<T?> push<T extends Object?>(Route<T> route) {
    return Navigator.of(this).push(route);
  }

  Future<T?> pushWidget<T extends Object?>(Widget route) {
    dynamic targetRoute = MaterialPageRoute(builder: (context) => route);
    return push(targetRoute);
  }

  /// 推送一个路由, 并且移除之前的路由
  Future<T?> pushReplacement<T extends Object?>(Route<T> route) {
    return Navigator.of(this).pushReplacement(route);
  }

  Future<T?> pushReplacementWidget<T extends Object?>(Widget route) {
    dynamic targetRoute = MaterialPageRoute(builder: (context) => route);
    return pushReplacement(targetRoute);
  }
}

//endregion 导航相关

//region 渐变相关

/// 返回一个线性渐变的小部件
Widget linearGradientWidget(
  List<Color> colors, {
  Widget? child,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  Key? key,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
}) {
  return Container(
    key: key,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
        tileMode: tileMode,
        transform: transform,
      ),
    ),
    child: child,
  );
}

//endregion 渐变相关
