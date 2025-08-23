part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/25
///
/// https://pub.dev/packages/animate_gradient
/// https://github.com/Vikaskumar75/Animated-Gradient
/// 动画渐变, 内部使用[AnimatedBuilder]+[BoxDecoration]+[LinearGradient]实现
class AnimateGradient extends StatefulWidget {
  const AnimateGradient({
    super.key,
    required this.primaryColors,
    required this.secondaryColors,
    this.child,
    this.primaryBegin = Alignment.topLeft,
    this.primaryEnd = Alignment.topRight,
    this.secondaryBegin = Alignment.bottomLeft,
    this.secondaryEnd = Alignment.bottomRight,
    this.primaryBeginGeometry,
    this.primaryEndGeometry,
    this.secondaryBeginGeometry,
    this.secondaryEndGeometry,
    this.textDirectionForGeometry = TextDirection.ltr,
    this.controller,
    this.duration = const Duration(seconds: 4),
    this.animateAlignments = true,
    this.reverse = true,
  }) : assert(primaryColors.length >= 2),
       assert(primaryColors.length == secondaryColors.length);

  /// [controller]: pass this to have a fine control over the [Animation]
  final AnimationController? controller;

  /// [duration]: Time to switch between [Gradient].
  /// By default its value is [Duration(seconds:4)]
  final Duration duration;

  /// [primaryColors]: These will be the starting colors of the [Animation].
  final List<Color> primaryColors;

  /// [secondaryColors]: These Colors are those in which the [primaryColors] will transition into.
  final List<Color> secondaryColors;

  /// [primaryBegin]: This is begin [Alignment] for [primaryColors].
  /// By default its value is [Alignment.topLeft]
  final Alignment primaryBegin;

  /// [primaryBegin]: This is end [Alignment] for [primaryColors].
  /// By default its value is [Alignment.topRight]
  final Alignment primaryEnd;

  /// [secondaryBegin]: This is begin [Alignment] for [secondaryColors].
  /// By default its value is [Alignment.bottomLeft]
  final Alignment secondaryBegin;

  /// [secondaryEnd]: This is end [Alignment] for [secondaryColors].
  /// By default its value is [Alignment.bottomRight]
  final Alignment secondaryEnd;

  /// Alternatively you can use [primaryBeginGeometry] over [primaryBegin] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [primaryBeginGeometry] will have higher priority than [primaryBegin]
  final AlignmentGeometry? primaryBeginGeometry;

  /// Alternatively you can use [primaryEndGeometry] over [primaryEnd] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [primaryEndGeometry] will have higher priority than [primaryEnd]
  final AlignmentGeometry? primaryEndGeometry;

  /// Alternatively you can use [secondaryBeginGeometry] over [secondaryBegin] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [secondaryBeginGeometry] will have higher priority than [secondaryBegin]
  final AlignmentGeometry? secondaryBeginGeometry;

  /// Alternatively you can use [secondaryEndGeometry] over [secondaryEnd] for better control over alignments
  /// These are really useful for when you are builing an [rtl] app.
  /// [secondaryEndGeometry] will have higher priority than [secondaryEnd]
  final AlignmentGeometry? secondaryEndGeometry;

  /// This is the [TextDirection] which is gonna be used to resolve [AlignmentGeometry] passed through
  /// [primaryBeginGeometry], [primaryEndGeometry], [secondaryBeginGeometry], [secondaryEndGeometry]
  final TextDirection textDirectionForGeometry;

  /// [animateAlignments]: set to false if you don't want to animate the alignments.
  /// This can provide you way cooler animations
  final bool animateAlignments;

  /// [reverse]: set it to false if you don't want to reverse the animation.
  /// using that it will go into one direction only
  final bool reverse;

  final Widget? child;

  @override
  State<AnimateGradient> createState() => _AnimateGradientState();
}

class _AnimateGradientState extends State<AnimateGradient>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  late List<ColorTween> _colorTween;

  late AlignmentTween begin;
  late AlignmentTween end;
  List<Color> primaryColors = [];
  List<Color> secondaryColors = [];

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    _initialize();
    super.didUpdateWidget(oldWidget);
  }

  void _initialize() {
    primaryColors = widget.primaryColors;
    secondaryColors = widget.secondaryColors;
    _colorTween = _getColorTweens();
    if (widget.animateAlignments) _setAlignmentTweens();
    _setAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.animateAlignments
                  ? begin.evaluate(_animation)
                  : widget.primaryBegin,
              end: widget.animateAlignments
                  ? end.evaluate(_animation)
                  : widget.primaryEnd,
              colors: _evaluateColors(_animation),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  List<ColorTween> _getColorTweens() {
    if (widget.primaryColors.length != widget.secondaryColors.length) {
      throw Exception('primaryColors.length != secondaryColors.length');
    }

    final List<ColorTween> colorTweens = [];

    for (int i = 0; i < primaryColors.length; i++) {
      colorTweens.add(
        ColorTween(begin: primaryColors[i], end: secondaryColors[i]),
      );
    }

    return colorTweens;
  }

  List<Color> _evaluateColors(Animation<double> animation) {
    final List<Color> colors = [];
    for (int i = 0; i < _colorTween.length; i++) {
      colors.add(_colorTween[i].evaluate(animation)!);
    }
    return colors;
  }

  void _setAlignmentTweens() {
    final primaryBeginGeometry = widget.primaryBeginGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final primaryEndGeometry = widget.primaryEndGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final secondaryBeginGeometry = widget.secondaryBeginGeometry?.resolve(
      widget.textDirectionForGeometry,
    );
    final secondaryEndGeometry = widget.secondaryEndGeometry?.resolve(
      widget.textDirectionForGeometry,
    );

    begin = AlignmentTween(
      begin: primaryBeginGeometry ?? widget.primaryBegin,
      end: primaryEndGeometry ?? widget.primaryEnd,
    );
    end = AlignmentTween(
      begin: secondaryBeginGeometry ?? widget.secondaryBegin,
      end: secondaryEndGeometry ?? widget.secondaryEnd,
    );
  }

  void _setAnimations() {
    _controller =
        widget.controller ??
              AnimationController(vsync: this, duration: widget.duration)
          ..repeat(reverse: widget.reverse);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}
