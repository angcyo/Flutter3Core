part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 渐变滑块轨道Shape
/// [RoundedRectSliderTrackShape]
/// [RoundedRectRangeSliderTrackShape]
class GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  /// 渐变颜色
  final List<Color>? colors;
  final List<double>? colorStops;

  const GradientSliderTrackShape(
    this.colors, {
    this.colorStops,
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

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
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
    activePaint.shader = linearGradientShader(
      colors,
      colorStops: colorStops,
      rect: trackRect,
    );
    //--

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius =
        Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

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
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );

    final bool showSecondaryTrack = (secondaryOffset != null) &&
        ((textDirection == TextDirection.ltr)
            ? (secondaryOffset.dx > thumbCenter.dx)
            : (secondaryOffset.dx < thumbCenter.dx));

    if (showSecondaryTrack) {
      final ColorTween secondaryTrackColorTween = ColorTween(
          begin: sliderTheme.disabledSecondaryActiveTrackColor,
          end: sliderTheme.secondaryActiveTrackColor);
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

/// 中心滑块轨道Shape
class CenteredRectangularSliderTrackShape extends RectangularSliderTrackShape {
  /// 渐变颜色
  final List<Color>? colors;
  final List<double>? colorStops;

  /// 额外的轨道高度
  final double additionalActiveTrackHeight;

  const CenteredRectangularSliderTrackShape({
    this.colors,
    this.colorStops,
    this.additionalActiveTrackHeight = 0,
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
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
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
    final Size thumbSize =
        sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete);
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
          trackRect.top - (additionalActiveTrackHeight / 2),
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom + (additionalActiveTrackHeight / 2));

      if (!leftTrackSegment.isEmpty) {
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
          colors,
          colorStops: colorStops,
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
          trackRect.top - (additionalActiveTrackHeight / 2),
          trackRect.right,
          trackRect.bottom + (additionalActiveTrackHeight / 2));
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else if (trackCenter.dx > thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
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
          colors?.reversed.toList(),
          colorStops: colorStops?.reversed.toList(),
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
        trackRect.top - (additionalActiveTrackHeight / 2),
        trackRect.right,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
      );

      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else {
      final Rect leftTrackSegment = Rect.fromLTRB(
          trackRect.left,
          trackRect.top - (additionalActiveTrackHeight / 2),
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom + (additionalActiveTrackHeight / 2));
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.top - (additionalActiveTrackHeight / 2),
          trackRect.right,
          trackRect.bottom + (additionalActiveTrackHeight / 2));
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    }
  }
}
