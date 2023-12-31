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
/// [postFrameCallback]
/// [postCallback]
/// [postDelayCallback]
/// [delayCallback]
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
typedef WidgetNullList = List<Widget?>;

/// 通过[Builder]小部件, 获取当前元素的[BuildContext]
/// 然后当前[BuildContext]更新只会影响其子元素, 父元素不会受到影响
Widget builder(
  WidgetBuilder builder, [
  Key? key,
]) =>
    Builder(
      builder: builder,
      key: key,
    );

/// 将当前的小部件, 包裹在一个[Padding]中
/// 根据html的padding属性, 生成padding
EdgeInsets? edgeInsets([double? v1, double? v2, double? v3, double? v4]) {
  //如果是4个参数
  if (v1 != null && v2 != null && v3 != null && v4 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v4);
  }
  //如果是3个参数
  if (v1 != null && v2 != null && v3 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v3, v2);
  }
  //如果是2个参数
  if (v1 != null && v2 != null) {
    return EdgeInsets.fromLTRB(v1, v2, v1, v2);
  }
  //如果是1个参数
  if (v1 != null) {
    return EdgeInsets.all(v1);
  }
  return null;
}

extension WidgetListEx on WidgetNullList {
  /// 将当前的小部件集合, 包裹在一个[Wrap]中
  /// [alignment] 主轴对齐方式
  /// [crossAxisAlignment] 交叉轴对齐方式
  Widget? wrap({
    double spacing = kH,
    double runSpacing = kH,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
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
      children: list,
    );
  }

  /// 使用[Column]包裹
  /// [gap] 间隙
  Widget? column({
    MainAxisAlignment? mainAxisAlignment,
    MainAxisSize? mainAxisSize,
    CrossAxisAlignment? crossAxisAlignment,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
  }) {
    WidgetList list = filterNull();
    WidgetList children = list;
    if (gap != null || gapWidget != null) {
      children = <Widget>[];
      for (var i = 0; i < length; i++) {
        children.add(list[i]);
        if (i < length - 1) {
          if (gapWidget != null) {
            children.add(gapWidget);
          } else {
            children.add(Empty.width(gap!));
          }
        }
      }
    }
    if (isNullOrEmpty(children)) {
      return null;
    }
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: mainAxisSize ?? MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      textBaseline: textBaseline,
      children: children,
    );
  }

  /// 使用[Row]包裹
  /// [mainAxisAlignment] 主轴对齐方式, 水平方向, 水平左对齐, 水平居中, 水平右对齐
  /// [mainAxisSize] 主轴尺寸, 是要用最大尺寸, 还是要最小尺寸
  /// [crossAxisAlignment] 交叉轴对齐方式, 垂直方向, 垂直顶部对齐, 垂直居中对齐, 垂直底部对齐
  /// [gap] 间隙
  Widget? row({
    MainAxisAlignment? mainAxisAlignment,
    MainAxisSize? mainAxisSize,
    CrossAxisAlignment? crossAxisAlignment,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
    double? gap,
    Widget? gapWidget,
  }) {
    WidgetList list = filterNull();
    WidgetList children = list;
    if (gap != null || gapWidget != null) {
      children = <Widget>[];
      for (var i = 0; i < length; i++) {
        children.add(list[i]);
        if (i < length - 1) {
          if (gapWidget != null) {
            children.add(gapWidget);
          } else {
            children.add(Empty.width(gap!));
          }
        }
      }
    }
    if (isNullOrEmpty(children)) {
      return null;
    }
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      textBaseline: textBaseline,
      children: children,
    );
  }

  /// [Stack]
  Widget? stack({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    return Stack(
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: list,
    );
  }

  /// [SingleChildScrollView]
  /// [scroll]
  /// [WidgetEx.scroll]
  Widget? scroll({
    Axis scrollDirection = Axis.horizontal,
    ScrollPhysics? physics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    double? gap,
    Widget? gapWidget,
  }) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    Widget body;
    if (scrollDirection == Axis.vertical) {
      body = list.column(
        mainAxisSize: MainAxisSize.min,
        gap: gap,
        gapWidget: gapWidget,
      )!;
    } else {
      body = list.row(
        mainAxisSize: MainAxisSize.min,
        gap: gap,
        gapWidget: gapWidget,
      )!;
    }
    return body.scroll(
      scrollDirection: scrollDirection,
      physics: physics,
      controller: controller,
      padding: padding,
      primary: primary,
    );
  }

  /// 绘制边界
  /// https://docs.flutter.dev/tools/devtools/inspector#highlight-repaints
  /// [WidgetEx.repaintBoundary]
  /// [debugRepaintRainbowEnabled]
  WidgetList repaintBoundary() => RepaintBoundary.wrapAll(filterNull());
}

extension WidgetEx on Widget {
  /// [Tooltip] 提示
  Widget tooltip(String? tip, {InlineSpan? richMessage}) => Tooltip(
        message: tip,
        richMessage: richMessage,
        child: this,
      );

  /// [Hero]
  Widget hero(Object? tag) => tag == null ? this : Hero(tag: tag, child: this);

  /// 点击事件
  /// [GestureDetector] 多个手势识别器, 才会有手势竞争
  /// [Listener] 监听手势, 不会有手势竞争
  /// [GestureRecognizer] 手势识别器base
  /// [TapGestureRecognizer] 单击手势识别器
  /// [DoubleTapGestureRecognizer] 双击手势识别器
  /// [LongPressGestureRecognizer] 长按手势识别器
  /// [DragGestureRecognizer] 拖动手势识别器
  /// [ScaleGestureRecognizer] 缩放手势识别器
  /// [PanGestureRecognizer] 拖动手势识别器
  /// [MultiTapGestureRecognizer] 多击手势识别器
  /// [EagerGestureRecognizer] 急切手势识别器
  /// [RotateGestureRecognizer] 旋转手势识别
  ///
  Widget click(GestureTapCallback? onTap) => onTap == null
      ? this
      : GestureDetector(
          onTap: onTap,
          child: this,
        );

  /// 双击事件
  Widget doubleClick(GestureTapCallback? onDoubleTap) => onDoubleTap == null
      ? this
      : GestureDetector(
          onDoubleTap: onDoubleTap,
          child: this,
        );

  /// [CustomPaint]
  /// [paint] 背景绘制
  /// [foregroundPaint] 前景绘制
  /// [isComplex] 是否是复杂的
  /// [willChange] 是否会在下一帧改变
  CustomPaint paint(
    PaintFn paint, {
    PaintFn? foregroundPaint,
    Size size = Size.zero,
    bool isComplex = false,
    bool willChange = false,
  }) =>
      CustomPaint(
        painter: CustomPaintWrap(paint),
        foregroundPainter:
            foregroundPaint == null ? null : CustomPaintWrap(foregroundPaint),
        size: size,
        isComplex: isComplex,
        willChange: willChange,
        child: this,
      );

  /// 监听一个通知
  /// [ContextEx.postNotification]
  /// [Notification]
  Widget listenerNotification<T extends Notification>({
    required NotificationListenerCallback<T> onNotification,
    bool? Function(T)? shouldNotify,
  }) =>
      NotificationListener<T>(
        onNotification: onNotification,
        child: this,
      );

  /// 为[child]小部件提供一个数据
  Widget dataProvider([Object? data]) => DataProviderScope(
        data: data,
        child: this,
      );

  //region ---Padding---

  /// 将当前的小部件, 包裹在一个[Padding]中
  /// 根据html的padding属性, 生成padding
  Widget padding([double? v1, double? v2, double? v3, double? v4]) {
    final insets = edgeInsets(v1, v2, v3, v4);
    return insets == null
        ? this
        : Padding(
            padding: insets,
            child: this,
          );
  }

  Widget paddingCss([double? v1, double? v2, double? v3, double? v4]) =>
      padding(v1, v2, v3, v4);

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
  /// [paddingSymmetric]
  Widget paddingItem({double vertical = kXh / 2, double horizontal = kXh}) {
    return paddingSymmetric(
      vertical: vertical,
      horizontal: horizontal,
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
  Widget expanded({
    int flex = 1,
    FlexFit fit = FlexFit.tight,
    bool enable = true,
  }) {
    if (!enable) {
      return this;
    }
    return Flexible(
      flex: flex,
      fit: fit,
      child: this,
    );
  }

  /// 对齐
  /// [Align]
  /// [Center]
  Widget align({
    AlignmentGeometry alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
    double? minWidth,
    double? minHeight,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    ).constrainedMin(
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }

  /// 居中对齐
  /// [Align]
  /// [Center]
  Widget center({
    double? widthFactor,
    double? heightFactor,
  }) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  /// [Positioned]
  /// [PositionedDirectional]
  /// [AnimatedPositioned]
  Widget position({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: this,
    );
  }

  /// 旋转元素
  /// [angle] 旋转角度, 顺时针为正, 弧度单位
  Widget rotate(
    double angle, {
    AlignmentGeometry alignment = Alignment.center,
    Offset? origin,
    bool transformHitTests = true,
  }) {
    return Transform.rotate(
      alignment: alignment,
      angle: angle,
      origin: origin,
      transformHitTests: transformHitTests,
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
    bool? bottom,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom ?? maintainBottomViewPadding,
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
  Widget clip({
    BorderRadiusGeometry? borderRadius,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipper: clipper,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// 圆角
  Widget clipRadius({
    double radius = kDefaultBorderRadiusXX,
    BorderRadiusGeometry? borderRadius,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) =>
      clip(
        borderRadius: borderRadius ??
            BorderRadius.all(
              Radius.circular(radius),
            ),
        clipper: clipper,
        clipBehavior: clipBehavior,
      );

  /// 椭圆形
  Widget clipOval({
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return ClipOval(
      clipper: clipper,
      clipBehavior: clipBehavior,
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
      shadowColor: shadowColor ?? Colors.black12,
      elevation: elevation,
      child: this,
    );
  }

  /// 使用一个容器包裹当前的小部件
  /// [Container]
  /// [color] 背景颜色
  /// [borderColor] 边框颜色, 如果有
  /// [borderWidth] 边框宽度
  /// [radius] 圆角, 决定[BorderRadius]
  /// [borderRadius] 圆角, 决定[decoration]
  /// [decoration] 背景装饰
  /// [shadowBlurRadius] 阴影模糊半径, 同时决定是否启用阴影 推荐值[kDefaultBlurRadius]
  /// [shadowColor] 阴影颜色
  /// [shadowSpreadRadius] 阴影扩散半径
  /// [decorationImage] 背景装饰图片
  /// [fillDecoration]
  Widget container({
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? radius,
    BorderRadius? borderRadius,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
    Color? borderColor,
    double borderWidth = 1,
    BoxShape shape = BoxShape.rectangle,
    double? shadowBlurRadius,
    Color? shadowColor,
    double shadowSpreadRadius = 1,
    DecorationImage? decorationImage,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
  }) {
    borderRadius ??= radius == null ? null : BorderRadius.circular(radius);
    decoration ??= borderRadius == null
        ? null
        : BoxDecoration(
            borderRadius: borderRadius,
            color: color,
            shape: shape,
            gradient: gradient,
            boxShadow: boxShadow ??
                (shadowBlurRadius == null
                    ? null
                    : [
                        BoxShadow(
                            color: shadowColor ?? Colors.grey.withOpacity(0.1),
                            offset: const Offset(2, 2), //阴影y轴偏移量
                            blurRadius: shadowBlurRadius, //阴影模糊程度
                            spreadRadius: shadowSpreadRadius //阴影扩散程度
                            ),
                      ]),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor, width: borderWidth),
            image: decorationImage,
          );
    return Container(
      alignment: alignment,
      padding: padding,
      color: decoration == null ? color : null,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// [Card]
  /// [elevation] 阴影的高度, 默认1.0
  /// [CardTheme]
  /// [ThemeData.cardTheme]
  Widget card({
    Color? color,
    Color? shadowColor,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior = Clip.antiAlias,
  }) =>
      Card(
        color: color,
        shadowColor: shadowColor,
        elevation: elevation,
        shape: shape,
        margin: margin,
        clipBehavior: clipBehavior,
        child: this,
      );

  /// 圆形阴影包裹
  /// [shadowColor] 阴影颜色
  /// [shadowBlurRadius] 阴影模糊半径
  /// [shadowOffset] 阴影偏移
  /// [shadowSpreadRadius] 阴影扩散半径
  Widget circleShadow({
    bool clipContent = true,
    Color? decorationColor = Colors.white,
    Color shadowColor = Colors.black12,
    double shadowBlurRadius = kDefaultBlurRadius,
    double shadowSpreadRadius = kS,
    Offset shadowOffset = Offset.zero,
    Color? color,
    AlignmentGeometry? alignment = Alignment.center,
    EdgeInsetsGeometry? padding,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
  }) {
    return (clipContent ? clipOval() : this).container(
      alignment: alignment,
      padding: padding,
      color: color,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: decorationColor,
        boxShadow: [
          BoxShadow(
            offset: shadowOffset,
            color: shadowColor,
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
          ),
        ],
      ),
    );
  }

  /// 圆角矩形阴影包裹
  /// [clipContent] 是否裁剪内容
  Widget radiusShadow({
    bool clipContent = true,
    Color? decorationColor = Colors.white,
    Color shadowColor = Colors.black12,
    double blurRadius = kDefaultBlurRadius,
    BorderRadiusGeometry? borderRadius,
    Color? color,
    AlignmentGeometry? alignment = Alignment.center,
    EdgeInsetsGeometry? padding,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    double? width,
    double? height,
  }) {
    borderRadius ??=
        const BorderRadius.all(Radius.circular(kDefaultBorderRadiusXXX));
    return (clipContent ? clip(borderRadius: borderRadius) : this).container(
      alignment: alignment,
      padding: padding,
      color: color,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      width: width,
      height: height,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        color: decorationColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
          ),
        ],
      ),
    );
  }

  /// 模糊背景
  /// [ColorFiltered]
  Widget blur({
    double? sigma = kM,
    UiImageFilter? filter,
    BlendMode blendMode = BlendMode.srcOver,
  }) =>
      (sigma ?? 0) > 0 || filter != null
          ? BackdropFilter(
              filter: filter ??
                  ui.ImageFilter.blur(
                    sigmaX: sigma!,
                    sigmaY: sigma,
                    tileMode: TileMode.clamp,
                  ),
              blendMode: blendMode,
              child: this,
            )
          : this;

  /// 可以实现灰度效果,灰度化app
  /// [ColorFiltered]
  Widget colorFiltered({
    ColorFilter? colorFilter,
    Color color = Colors.grey,
    BlendMode blendMode = BlendMode.saturation,
  }) =>
      ColorFiltered(
        colorFilter: colorFilter ?? ColorFilter.mode(color, blendMode),
        child: this,
      );

  /// 绘制边界
  /// https://docs.flutter.dev/tools/devtools/inspector#highlight-repaints
  /// [WidgetListEx.repaintBoundary]
  /// [debugRepaintRainbowEnabled]
  Widget repaintBoundary({int? childIndex}) => childIndex == null
      ? RepaintBoundary(
          child: this,
        )
      : RepaintBoundary.wrap(
          this,
          childIndex,
        );

  /// 文本样式包裹
  /// [DefaultTextStyle]
  Widget wrapTextStyle({
    TextStyle? style,
    TextAlign? textAlign,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    ui.TextHeightBehavior? textHeightBehavior,
  }) {
    TextStyle def = GlobalConfig.def.themeData.primaryTextTheme.bodyMedium ??
        const TextStyle();
    return DefaultTextStyle(
      style: def,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      child: this,
    );
  }

  /// 拦截路由的弹出, 返回键.
  /// [PopScope]
  /// [WillPopScope.onWillPop]
  Widget willPop([WillPopCallback? onWillPop]) {
    return WillPopScope(
      onWillPop: onWillPop ?? () async => false,
      child: this,
    );
  }

  /// 取消父组件对子组件的约束信息
  /// [UnconstrainedBox]
  Widget unconstrained({
    TextDirection? textDirection,
    AlignmentGeometry alignment = Alignment.center,
    Axis? constrainedAxis,
    Clip clipBehavior = Clip.none,
  }) {
    return UnconstrainedBox(
      textDirection: textDirection,
      alignment: alignment,
      constrainedAxis: constrainedAxis,
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// 约束当前小部件的大小
  /// [ConstrainedBox]
  /// [constrainedMin]
  /// [constrainedMax]
  Widget constrainedBox(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: constraints,
      child: this,
    );
  }

  /// 固定大小约束
  /// [constrainedBox]
  Widget constrainedFixed(Size size) {
    return constrainedBox(BoxConstraints.tight(size));
  }

  /// 约束最小宽高
  /// [constrainedBox]
  Widget constrainedMin({
    double? minWidth,
    double? minHeight,
  }) {
    if (minWidth == null && minHeight == null) {
      return this;
    }
    return constrainedBox(BoxConstraints(
      minWidth: minWidth ?? 0,
      minHeight: minHeight ?? 0,
    ));
  }

  /// 约束最大宽高
  /// [constrainedBox]
  Widget constrainedMax({
    double? maxWidth,
    double? maxHeight,
  }) {
    if (maxWidth == null && maxHeight == null) {
      return this;
    }
    return constrainedBox(BoxConstraints(
      maxWidth: maxWidth ?? double.infinity,
      maxHeight: maxHeight ?? double.infinity,
    ));
  }

  /// 指定大小
  /// [SizedBox]
  Widget size({
    double? width,
    double? height,
  }) {
    if (width == null && height == null) {
      return this;
    }
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }

  /// 首选大小
  /// [PreferredSizeWidget]
  /// [PreferredSize]
  /// [TabBar]
  PreferredSizeWidget sizePreferred({
    double? width,
    double? height = kTabHeight,
  }) {
    return PreferredSize(
      preferredSize: Size(width ?? double.infinity, height ?? double.infinity),
      child: this,
    );
  }

  /// 比例box [AspectRatio]
  /// 纵横比表示为宽度与高度的比率。例如，16:9宽高比的值为16.0/9.0。
  Widget ratio(double aspectRatio) => AspectRatio(
        aspectRatio: aspectRatio,
        child: this,
      );

  /// [Material]
  Widget material({
    ShapeBorder? shape,
    Color? color = Colors.transparent,
    Color? shadowColor,
    Color? surfaceTintColor,
    double elevation = 0,
    MaterialType type = MaterialType.canvas,
    Clip clipBehavior = Clip.none,
    BorderRadiusGeometry? borderRadius,
    TextStyle? textStyle,
  }) =>
      Material(
        borderOnForeground: true,
        color: color,
        shadowColor: shadowColor,
        elevation: elevation,
        type: type,
        surfaceTintColor: surfaceTintColor,
        clipBehavior: clipBehavior,
        borderRadius: borderRadius,
        textStyle: textStyle,
        shape: shape,
        child: this,
      );

  /// 支持圆角波纹效果, 有的时候可能需要包裹在[Material]部件中才有预期效果
  /// [radius] 背景/波纹圆角大小, 圆角足够大时, 可以实现圆形效果. [kDefaultBorderRadiusXXX]
  /// [shape] 形状, [BoxShape.circle]并不能实现圆形效果, 需要设置圆角[radius].
  /// [backgroundColor] 背景颜色, 此时波纹依旧有效. 用[container]的背景颜色则波纹效果无效.
  /// [highlightColor] 高亮的颜色, 波纹扩散结束之后可见的颜色
  /// [splashColor] 波纹颜色, 动画扩散时的颜色
  /// [decoration] 强行指定装饰
  Widget ink({
    GestureTapCallback? onTap,
    double radius = 0,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Decoration? decoration,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    Color? highlightColor,
    Color? splashColor,
  }) {
    var isCircle = shape == BoxShape.circle;
    var bRadius = borderRadius ??
        (isCircle ? null : BorderRadius.all(Radius.circular(radius)));
    decoration ??= BoxDecoration(
      shape: shape,
      color: backgroundColor,
      borderRadius: bRadius,
    );
    return Ink(
      padding: padding,
      decoration: decoration,
      width: width,
      height: height,
      child: inkWell(
        borderRadius: bRadius,
        customBorder: isCircle ? const CircleBorder() : null,
        highlightShape: shape,
        onTap: onTap,
        highlightColor: highlightColor,
        splashColor: splashColor,
      ),
    );
  }

  /// 使用涟漪动画包裹, 无法控制背景颜色, 波纹会超出范围. [ink]
  /// https://api.flutter.dev/flutter/material/InkWell-class.html
  /// [splashColor] 涟漪颜色
  /// [highlightColor] 高亮颜色
  /// [InkWell]
  /// [InkResponse]
  /// [CircleBorder]
  Widget inkWell({
    GestureTapCallback? onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    BoxShape highlightShape = BoxShape.rectangle,
    double? radius,
    ShapeBorder? customBorder,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: radius,
      splashColor: splashColor,
      highlightColor: highlightColor,
      //overlayColor: MaterialStateProperty.all(Colors.blue),
      borderRadius: borderRadius,
      customBorder: customBorder,
      //边框裁剪
      highlightShape: highlightShape,
      containedInkWell: true,
      child: this,
    );
  }

  /// [ink]
  /// [inkWell]
  /// [InkWell]
  Widget inkWellCircle({
    GestureTapCallback? onTap,
    Color? splashColor,
    Color? highlightColor,
    double? radius,
  }) =>
      inkWell(
        onTap: onTap,
        //borderRadius: BorderRadius.circular(999),
        customBorder: const CircleBorder(),
        splashColor: splashColor,
        highlightColor: highlightColor,
        highlightShape: BoxShape.rectangle,
        radius: radius,
      );

  /// 将[this]和[child] 使用[Column]包裹
  Widget? columnOf(
    Widget? child, {
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize? mainAxisSize,
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
  }) =>
      [
        this,
        if (child != null) child,
      ].column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
      );

  /// 将[this]和[child] 使用[Row]包裹
  Widget? rowOf(
    Widget? child, {
    MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize? mainAxisSize,
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection? verticalDirection,
    TextBaseline? textBaseline,
  }) =>
      [
        this,
        if (child != null) child,
      ].row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
      );

  /// 简单的滚动小组件[SingleChildScrollView]
  /// [WidgetListEx.scroll]
  /// [padding] 滚动小部件内边距
  /// [reverse] 是否反向滚动
  Widget scroll({
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
  }) =>
      SingleChildScrollView(
        scrollDirection: scrollDirection,
        physics: physics,
        controller: controller,
        padding: padding,
        primary: primary,
        reverse: reverse,
        child: this,
      );

  /// 控制当前的[Widget]可见性
  /// [AnimatedContainer]
  /// [AnimatedOpacity]
  Widget visible({required bool visible, bool anim = false}) {
    var result = Visibility(
      visible: visible,
      child: this,
    );
    if (anim) {
      return AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: kDefaultAnimationDuration,
        child: result,
      );
    }
    return result;
  }

  //--theme---

  /// [ButtonStyle]
  /// [FilledButton]
  /// [FilledButtonTheme]
  Widget filledButtonTheme({
    ButtonStyle? style,
    FilledButtonThemeData? theme,
  }) =>
      FilledButtonTheme(
        data: theme ?? FilledButtonThemeData(style: style),
        child: this,
      );

  /// [ElevatedButton]
  Widget elevatedButtonTheme({
    ButtonStyle? style,
    ElevatedButtonThemeData? theme,
  }) =>
      ElevatedButtonTheme(
        data: theme ?? ElevatedButtonThemeData(style: style),
        child: this,
      );

  /// [OutlinedButton]
  Widget outlinedButtonTheme({
    ButtonStyle? style,
    OutlinedButtonThemeData? theme,
  }) =>
      OutlinedButtonTheme(
        data: theme ?? OutlinedButtonThemeData(style: style),
        child: this,
      );

  /// [TextButton]
  Widget textButtonTheme({
    ButtonStyle? style,
    TextButtonThemeData? theme,
  }) =>
      TextButtonTheme(
        data: theme ?? TextButtonThemeData(style: style),
        child: this,
      );
}

extension StateEx on State {
  /// 标记当前状态脏, 会在下一帧重建
  /// [Element.markNeedsBuild]
  /// [ContextEx.tryUpdateState]
  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// [ConditionalElementVisitor] 返回false 可以停止遍历
/// [depth] 从0开始的递归深度
typedef ConditionalElementVisitorDepth = bool Function(
    Element element, int depth, int childIndex);

/// [BuildContext.findRenderObject]
/// [RenderObject.showOnScreen]
extension ContextEx on BuildContext {
  /// 尝试更新状态, 如果可以
  /// [StateEx.updateState]
  void tryUpdateState() {
    if (this is Element) {
      var element = this as Element;
      if (element.mounted) {
        element.markNeedsBuild();
      }
    }
  }

  /// 当前语言环境
  /// [Locale.languageCode] zh
  /// [Locale.countryCode] CN
  /// [Locale.scriptCode] Hans
  Locale get locale => Localizations.localeOf(this);

  /// 分发一个通知, 可以通过[NotificationListener]小部件接收通知
  /// [dispatchNotification]
  void postNotification(Notification notification) =>
      notification.dispatch(this);

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
  /// [visitor] 返回值表示是否继续遍历; true: 继续深度遍历; false: 停止深度遍历;
  /// ```
  /// The BuildContext.visitChildElements() method can't be called during build because the child list is
  /// still being updated at that point, so the children might not be constructed yet, or might be old
  /// children that are going to be replaced.
  /// ```
  eachVisitChildElements(
    ConditionalElementVisitorDepth visitor, {
    int depth = 0,
  }) {
    if (owner == null || debugDoingBuild) {
      return;
    }
    int childIndex = 0;
    //此方法不能再build期间调用
    visitChildElements((element) {
      bool interrupt = !visitor(element, depth, childIndex++);
      if (!interrupt) {
        element.eachVisitChildElements(visitor, depth: depth + 1);
      }
    });
  }

  /// 通过指定的[Widget]类型查找对应的[Element]
  Element? findElementOfWidget<T extends Widget>() {
    Element? result;
    eachVisitChildElements((element, depth, childIndex) {
      if (element.widget is T) {
        result = element;
        return false;
      }
      return true;
    });
    return result;
  }
}

extension RenderObjectEx on RenderObject {
  /// 获取[RenderObject]的大小
  Size? getSizeOrNull() {
    if (this is RenderBox) {
      if ((this as RenderBox).hasSize) {
        return (this as RenderBox).size;
      }
    }
    return null;
  }

  /// 获取[RenderObject]的全局绘制位置和坐标大小
  /// [RenderBox.localToGlobal]
  Rect? getGlobalBounds([RenderObject? ancestor, Offset point = Offset.zero]) {
    var offset = getGlobalOffset(ancestor, point);
    var size = getSizeOrNull();
    if (offset != null && size != null) {
      return offset & size;
    }
    return null;
  }

  /// 获取[RenderObject]的位置
  /// [RenderBox.localToGlobal]
  /// ```
  /// Scrollable.of(context).context.findRenderObject();
  /// ```
  Offset? getGlobalOffset(
      [RenderObject? ancestor, Offset point = Offset.zero]) {
    if (this is RenderBox) {
      final Offset location =
          (this as RenderBox).localToGlobal(point, ancestor: ancestor);
      return location;
    }
    return null;
  }
}

extension ElementEx on Element {}

//endregion 界面相关

//region 导航相关

/// 路由动画
enum TranslationType {
  /// [MaterialPageRoute]
  material,

  /// [CupertinoPageRoute]
  cupertino,

  /// [FadePageRoute]
  fade,

  /// [SlidePageRoute]
  slide,

  /// [ScalePageRoute]
  scale,

  /// [TranslationPageRoute]
  translation,

  /// [TranslationPageRoute]
  translationFade,
}

extension RouteWidgetEx on Widget {
  /// [MaterialPageRoute]
  /// [CupertinoPageRoute]
  Route<T> toRoute<T>({
    RouteSettings? settings,
    TranslationType? type,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) {
    dynamic targetRoute;
    switch (type) {
      case TranslationType.cupertino:
        targetRoute = CupertinoPageRoute(
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.fade:
        targetRoute = FadePageRoute(
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.slide:
        targetRoute = SlidePageRoute(
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.scale:
        targetRoute = ScalePageRoute(
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.translation:
        targetRoute = TranslationPageRoute(
          fade: false,
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.translationFade:
        targetRoute = TranslationPageRoute(
          fade: true,
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      default:
        targetRoute = MaterialPageRoute(
          builder: (context) => this,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
    }
    return targetRoute;
  }
}

/// 导航扩展
///使用 ModalRoute.of(context).settings.arguments; 获取参数
extension NavigatorEx on BuildContext {
  //---Route↓

  /// [Route]
  /// [OverlayRoute]
  /// [TransitionRoute]
  /// [ModalRoute]
  ModalRoute? get modalRoute => ModalRoute.of(this);

  RouteSettings? get routeSettings => modalRoute?.settings;

  /// 路由处于活跃状态
  bool get isRouteActive => modalRoute?.isActive ?? false;

  /// 是否是第一个路由
  bool get isRouteFirst => modalRoute?.isFirst ?? false;

  /// 是否是最上面的路由
  bool get isRouteCurrent => modalRoute?.isCurrent ?? false;

  /// 是否要显示返回按键
  bool get isAppBarDismissal => modalRoute?.impliesAppBarDismissal ?? false;

  /// 获取一个导航器[NavigatorState]
  NavigatorState navigatorOf([bool rootNavigator = false]) => Navigator.of(
        this,
        rootNavigator: rootNavigator,
      );

  /// 获取导航中的所有页面
  List<Page<dynamic>>? getRoutePages({
    bool rootNavigator = false,
  }) {
    return navigatorOf(rootNavigator).widget.pages;
  }

  //---push↓

  /// 推送一个路由
  Future<T?> push<T extends Object?>(
    Route<T> route, {
    bool rootNavigator = false,
  }) {
    return navigatorOf(rootNavigator).push(route);
  }

  /// 支持路由动画
  /// [push]
  Future<T?> pushWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    bool rootNavigator = false,
  }) {
    return push(page.toRoute(type: type), rootNavigator: rootNavigator);
  }

  /// 推送一个路由, 并且移除之前的路由
  Future<T?> pushReplacement<T extends Object?>(
    Route<T> route, {
    bool rootNavigator = false,
  }) {
    return navigatorOf(rootNavigator).pushReplacement(route);
  }

  /// [pushReplacement]
  Future<T?> pushReplacementWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    bool rootNavigator = false,
  }) {
    return pushReplacement(page.toRoute(type: type),
        rootNavigator: rootNavigator);
  }

  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRootWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    RoutePredicate? predicate,
    bool rootNavigator = false,
  }) {
    var root = ModalRoute.withName('/');
    return navigatorOf(rootNavigator).pushAndRemoveUntil(
      page.toRoute(type: type),
      predicate ?? root,
    );
  }

  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRoot<T extends Object?>(
    Route<T> route, {
    RoutePredicate? predicate,
    bool rootNavigator = false,
  }) {
    var root = ModalRoute.withName('/');
    return navigatorOf(rootNavigator).pushAndRemoveUntil(
      route,
      predicate ?? root,
    );
  }

  //---pop↓

  /// 是否可以弹出一个路由
  bool canPop([
    bool rootNavigator = false,
  ]) =>
      navigatorOf(rootNavigator).canPop();

  /// 弹出一个路由
  void pop<T extends Object?>([
    T? result,
    bool rootNavigator = false,
  ]) {
    navigatorOf(rootNavigator).pop(result);
  }

  /// 尝试弹出一个路由
  Future<bool> maybePop<T extends Object?>([
    T? result,
    bool rootNavigator = false,
  ]) {
    return navigatorOf(rootNavigator).maybePop(result);
  }

  void popUntil<T extends Object?>(
    RoutePredicate predicate, [
    bool rootNavigator = false,
  ]) {
    navigatorOf(rootNavigator).popUntil(predicate);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return navigatorOf(rootNavigator).popAndPushNamed(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 弹出所有非指定的路由
  /// [RoutePredicate]
  void popToRoot([
    RoutePredicate? predicate,
    bool rootNavigator = false,
  ]) {
    var root = ModalRoute.withName('/');
    return navigatorOf(rootNavigator).popUntil(root);
  }
}

//endregion 导航相关

//region 渐变相关

/// 线性渐变 [Shader]
UiGradient linearGradientShader(
  List<Color> colors, {
  Rect? rect,
  Offset? from,
  Offset? to,
}) =>
    UiGradient.linear(
      from ?? rect?.lt ?? Offset.zero,
      to ?? rect?.rt ?? Offset.zero,
      colors,
    );

/// 径向渐变 [Shader]
UiGradient radialGradientShader(
  double radius,
  List<Color> colors, {
  Rect? rect,
  Offset? center,
}) =>
    UiGradient.radial(
      center ?? rect?.center ?? Offset.zero,
      radius,
      colors,
    );

/// 扫描渐变 [Shader]
UiGradient sweepGradientShader(
  List<Color> colors, {
  Rect? rect,
  Offset? center,
}) =>
    UiGradient.sweep(
      center ?? rect?.center ?? Offset.zero,
      colors,
    );

/// [Gradient]
/// [UiGradient]
Gradient linearGradient(
  List<Color> colors, {
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
}) =>
    LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      tileMode: tileMode,
      transform: transform,
    );

/// 返回一个线性渐变的小部件
/// [colors] 渐变颜色, 必须要2个颜色
Widget linearGradientWidget(
  List<Color> colors, {
  Key? key,
  Widget? child,
  AlignmentGeometry begin = Alignment.centerLeft,
  AlignmentGeometry end = Alignment.centerRight,
  TileMode tileMode = TileMode.clamp,
  GradientTransform? transform,
}) {
  if (colors.length == 1) {
    colors = [...colors, ...colors];
  }
  return Container(
    key: key,
    decoration: BoxDecoration(
      gradient: linearGradient(
        colors,
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
