part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///

class CustomRoundedRectSliderTrackShape extends RoundedRectSliderTrackShape {
  /// 激活的滑块额外高度
  final double? additionalActiveTrackHeight;

  const CustomRoundedRectSliderTrackShape({this.additionalActiveTrackHeight});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight:
          this.additionalActiveTrackHeight ?? additionalActiveTrackHeight,
    );
  }
}

/// 渐变滑块轨道Shape
/// [RoundedRectSliderTrackShape]
/// [RoundedRectRangeSliderTrackShape]
class GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  /// 不活跃的渐变颜色, 通常背景
  final List<Color>? inactiveColors;
  final List<double>? inactiveColorStops;

  /// 活跃的渐变颜色, 通常是进度
  final List<Color>? activeColors;
  final List<double>? activeColorStops;

  /// 激活的滑块额外高度
  final double? additionalActiveTrackHeight;

  const GradientSliderTrackShape({
    this.activeColors,
    this.activeColorStops,
    this.inactiveColors,
    this.inactiveColorStops,
    this.additionalActiveTrackHeight,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    //--
    additionalActiveTrackHeight =
        this.additionalActiveTrackHeight ?? additionalActiveTrackHeight;

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    //--2024-5-24
    leftTrackPaint.shader = linearGradientShader(
      activeColors,
      colorStops: activeColorStops,
      rect: trackRect,
    );
    //--

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(
      (trackRect.height + additionalActiveTrackHeight) / 2,
    );

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );

    //--2024-6-17
    if (isNil(inactiveColors)) {
      //无渐变, 则走原来的绘制
      context.canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
            thumbCenter.dx,
            (textDirection == TextDirection.rtl)
                ? trackRect.top - (additionalActiveTrackHeight / 2)
                : trackRect.top,
            trackRect.right,
            (textDirection == TextDirection.rtl)
                ? trackRect.bottom + (additionalActiveTrackHeight / 2)
                : trackRect.bottom,
          ),
          topRight: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
          bottomRight: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
        ),
        rightTrackPaint,
      );
    } else {
      //背景有渐变, 则走新的
      final rightTrackRect = Rect.fromLTRB(
        trackRect.left,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
      );
      rightTrackPaint.shader = linearGradientShader(
        inactiveColors,
        colorStops: inactiveColorStops,
        rect: rightTrackRect,
      );
      context.canvas.drawRRect(
        RRect.fromRectAndCorners(
          rightTrackRect,
          topLeft: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
          topRight: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
          bottomRight: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
          bottomLeft: (textDirection == TextDirection.rtl)
              ? activeTrackRadius
              : trackRadius,
        ),
        rightTrackPaint,
      );
    }

    final bool showSecondaryTrack =
        (secondaryOffset != null) &&
        ((textDirection == TextDirection.ltr)
            ? (secondaryOffset.dx > thumbCenter.dx)
            : (secondaryOffset.dx < thumbCenter.dx));

    if (showSecondaryTrack) {
      final ColorTween secondaryTrackColorTween = ColorTween(
        begin: sliderTheme.disabledSecondaryActiveTrackColor,
        end: sliderTheme.secondaryActiveTrackColor,
      );
      final Paint secondaryTrackPaint = Paint()
        ..color = secondaryTrackColorTween.evaluate(enableAnimation)!;
      if (textDirection == TextDirection.ltr) {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            thumbCenter.dx,
            trackRect.top,
            secondaryOffset.dx,
            trackRect.bottom,
            topRight: trackRadius,
            bottomRight: trackRadius,
          ),
          secondaryTrackPaint,
        );
      } else {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            secondaryOffset.dx,
            trackRect.top,
            thumbCenter.dx,
            trackRect.bottom,
            topLeft: trackRadius,
            bottomLeft: trackRadius,
          ),
          secondaryTrackPaint,
        );
      }
    }
  }
}

/// 中心点向左右滑动的滑块轨道Shape
class CenteredRectangularSliderTrackShape extends RectangularSliderTrackShape {
  /// 不活跃的渐变颜色, 通常背景
  final List<Color>? inactiveColors;
  final List<double>? inactiveColorStops;

  /// 活跃的渐变颜色, 通常是进度
  final List<Color>? activeColors;
  final List<double>? activeColorStops;

  /// 有效轨道, 额外的高度
  /// 在[RoundedRectRangeSliderTrackShape].[RoundedRectSliderTrackShape].[GradientSliderTrackShape]中, 这个值是2.
  final double additionalActiveTrackHeight;

  const CenteredRectangularSliderTrackShape({
    this.activeColors,
    this.activeColorStops,
    this.inactiveColors,
    this.inactiveColorStops,
    this.additionalActiveTrackHeight = 2,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final trackCenter = trackRect.center;
    final Size thumbSize = sliderTheme.thumbShape!.getPreferredSize(
      isEnabled,
      isDiscrete,
    );
    // final Rect leftTrackSegment = Rect.fromLTRB(
    //     trackRect.left + trackRect.height / 2,
    //     trackRect.top,
    //     thumbCenter.dx - thumbSize.width / 2,
    //     trackRect.bottom);
    // if (!leftTrackSegment.isEmpty)
    //   context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    // final Rect rightTrackSegment = Rect.fromLTRB(
    //     thumbCenter.dx + thumbSize.width / 2,
    //     trackRect.top,
    //     trackRect.right,
    //     trackRect.bottom);
    // if (!rightTrackSegment.isEmpty)
    //   context.canvas.drawRect(rightTrackSegment, rightTrackPaint);

    if (trackCenter.dx < thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
        trackRect.bottom,
      );

      if (!leftTrackSegment.isEmpty) {
        inactivePaint.shader = linearGradientShader(
          inactiveColors?.reversed.toList(),
          colorStops: inactiveColorStops?.reversed.toList(),
          rect: leftTrackSegment,
        );
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final activeRect = Rect.fromLTRB(
        trackCenter.dx,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
      );
      if (!activeRect.isEmpty) {
        activePaint.shader = linearGradientShader(
          activeColors,
          colorStops: activeColorStops,
          rect: Rect.fromLTRB(
            activeRect.left,
            activeRect.top,
            trackRect.right,
            trackRect.bottom,
          ),
        );
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      );
      if (!rightTrackSegment.isEmpty) {
        inactivePaint.shader = linearGradientShader(
          inactiveColors,
          colorStops: inactiveColorStops,
          rect: rightTrackSegment,
        );
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else if (trackCenter.dx > thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.bottom,
      );
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final activeRect = Rect.fromLTRB(
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.top - (additionalActiveTrackHeight / 2),
        trackRect.center.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
      );
      if (!activeRect.isEmpty) {
        activePaint.shader = linearGradientShader(
          activeColors?.reversed.toList(),
          colorStops: activeColorStops?.reversed.toList(),
          rect: Rect.fromLTRB(
            trackRect.left,
            trackRect.top,
            activeRect.right,
            activeRect.bottom,
          ),
        );
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
        max(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      );

      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else {
      final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
        trackRect.bottom,
      );
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
        min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      );
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    }
  }
}

/// 描边+填充的浮子shape
/// [SliderComponentShape]->[RoundSliderThumbShape]
/// [RangeSliderTrackShape]->[RoundRangeSliderThumbShape]
/// [SliderThemeData]
class StrokeSliderThumbShape extends RoundSliderThumbShape {
  /// 描边宽度
  final double strokeWidth;

  /// 描边颜色
  final Color? strokeColor;

  /// 填充颜色
  final Color? fillColor;

  /// 是否绘制slider的数值
  final bool paintValue;

  const StrokeSliderThumbShape({
    super.enabledThumbRadius,
    super.disabledThumbRadius,
    super.elevation,
    super.pressedElevation,
    this.strokeWidth = 2,
    this.fillColor,
    this.paintValue = true,
    this.strokeColor = const Color(0xff333333),
  });

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  @override
  void paint(
    PaintingContext context,
    ui.Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required ui.TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required ui.Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final double radius = radiusTween.evaluate(enableAnimation);
    final paint = Paint()..strokeWidth = strokeWidth;
    if (fillColor != null) {
      paint
        ..style = PaintingStyle.fill
        ..color = fillColor!;
      canvas.drawCircle(center, radius, paint);
    }
    if (strokeColor != null) {
      paint
        ..style = PaintingStyle.stroke
        ..color = strokeColor!;
      canvas.drawCircle(center, radius, paint);
    }
    if (paintValue) {
      canvas.withColor(() {
        labelPainter.paint(
          canvas,
          center -
              labelPainter.size.center(Offset.zero) *
                  (textDirection == TextDirection.ltr ? 1 : -1) +
              ui.Offset(0, radius + labelPainter.size.height / 2),
        );
      }, tintColor: strokeColor);
    }
  }
}

/// 描边+填充的浮子shape, 范围滑块没有label的绘制
/// [SliderComponentShape]->[RoundSliderThumbShape]
/// [RangeSliderTrackShape]->[RoundRangeSliderThumbShape]
/// [SliderThemeData]
class StrokeRangeSliderThumbShape extends RoundRangeSliderThumbShape {
  /// 描边宽度
  final double strokeWidth;

  /// 描边颜色
  final Color? strokeColor;

  /// 填充颜色
  final Color? fillColor;

  /// 是否绘制slider的数值
  @implementation
  final bool paintValue;

  const StrokeRangeSliderThumbShape({
    super.enabledThumbRadius,
    super.disabledThumbRadius,
    super.elevation,
    super.pressedElevation,
    this.strokeWidth = 2,
    this.fillColor,
    this.paintValue = true,
    this.strokeColor = const Color(0xff333333),
  });

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  @override
  void paint(
    PaintingContext context,
    ui.Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    ui.TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      isOnTop: isOnTop,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      thumb: thumb,
      isPressed: isPressed,
    );

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final double radius = radiusTween.evaluate(enableAnimation);
    final paint = Paint()..strokeWidth = strokeWidth;
    if (fillColor != null) {
      paint
        ..style = PaintingStyle.fill
        ..color = fillColor!;
      canvas.drawCircle(center, radius, paint);
    }
    if (strokeColor != null) {
      paint
        ..style = PaintingStyle.stroke
        ..color = strokeColor!;
      canvas.drawCircle(center, radius, paint);
    }
  }
}
