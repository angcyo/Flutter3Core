part of transformer_page_view;

///
/// [TransformerPageView]
/// https://github.com/best-flutter/transformer_page_view
///
class AccordionTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0.0;
    if (position < 0.0) {
      return Transform.scale(
        scale: 1 + position,
        alignment: Alignment.topRight,
        child: child,
      );
    } else {
      return Transform.scale(
        scale: 1 - position,
        alignment: Alignment.bottomLeft,
        child: child,
      );
    }
  }
}

class ThreeDTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;
    double height = info.height ?? 0;
    double width = info.width ?? 0;
    double pivotX = 0.0;
    if (position < 0 && position >= -1) {
      // left scrolling
      pivotX = width;
    }
    return Transform(
      transform: Matrix4.identity()
        ..rotate(Vector3(0.0, 2.0, 0.0), position * 1.5),
      origin: Offset(pivotX, height / 2),
      child: child,
    );
  }
}

class ZoomInPageTransformer extends PageTransformer {
  static const double ZOOM_MAX = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;
    double width = info.width ?? 0;
    if (position > 0 && position <= 1) {
      return Transform.translate(
        offset: Offset(-width * position, 0.0),
        child: Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}

class ZoomOutPageTransformer extends PageTransformer {
  static const double MIN_SCALE = 0.85;
  static const double MIN_ALPHA = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;
    double pageWidth = info.width ?? 0;
    double pageHeight = info.height ?? 0;

    if (position < -1) {
      // [-Infinity,-1)
      // This page is way off-screen to the left.
      //view.setAlpha(0);
    } else if (position <= 1) {
      // [-1,1]
      // Modify the default slide transition to
      // shrink the page as well
      double scaleFactor = Math.max(MIN_SCALE, 1 - position.abs());
      double vertMargin = pageHeight * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      // Scale the page down (between MIN_SCALE and 1)
      double opacity = MIN_ALPHA +
          (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA);

      return Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(dx, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    } else {
      // (1,+Infinity]
      // This page is way off-screen to the right.
      // view.setAlpha(0);
    }

    return child;
  }
}

class DepthPageTransformer extends PageTransformer {
  DepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;
    if (position <= 0) {
      return Opacity(
        opacity: 1.0,
        child: Transform.translate(
          offset: Offset.zero,
          child: Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    } else if (position <= 1) {
      const double minScale = 0.75;
      // Scale the page down (between MIN_SCALE and 1)
      double scaleFactor = minScale + (1 - minScale) * (1 - position);

      return Opacity(
        opacity: 1.0 - position,
        child: Transform.translate(
          offset: Offset(info.width! * -position, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double? _scale;
  final double? _fade;

  ScaleAndFadeTransformer({double? fade = 0.3, double? scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;
    Widget result = child;

    //scale
    if (_scale != null) {
      double scaleFactor = (1 - position.abs()) * (1 - _scale!);
      double scale = _scale! + scaleFactor;
      result = Transform.scale(
        scale: scale,
        child: child,
      );
    }

    //fade
    if (_fade != null) {
      double fadeFactor = (1 - position.abs()) * (1 - _fade!);
      double opacity = _fade! + fadeFactor;
      result = Opacity(
        opacity: opacity,
        child: result,
      );
    }

    return result;
  }
}
