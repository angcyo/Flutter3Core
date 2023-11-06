part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023-11-6
///

/// https://github.com/best-flutter/flutter_page_indicator
/// ```
/// PageIndicator(
///   layout: PageIndicatorLayout.SLIDE,
///   size: 20.0,
///   controller: YOUR_PAGE_CONTROLLER,
///   space: 5.0,
///   count: 4,
/// )
/// ```
///

class PageIndicator extends StatefulWidget {
  /// size of the dots
  final double size;

  /// space between dots.
  final double space;

  /// count of dots
  final int count;

  /// active color
  final Color activeColor;

  /// normal color
  final Color color;

  /// layout of the dots,default is [PageIndicatorLayout.slide]
  final PageIndicatorLayout layout;

  // Only valid when layout==PageIndicatorLayout.scale
  final double scale;

  // Only valid when layout==PageIndicatorLayout.drop
  final double dropHeight;

  final PageController controller;

  final double activeSize;

  const PageIndicator({
    super.key,
    required this.count,
    required this.controller,
    this.layout = PageIndicatorLayout.warm,
    this.size = 20.0,
    this.space = 5.0,
    this.activeSize = 20.0,
    this.scale = 0.6,
    this.dropHeight = 20.0,
    this.color = Colors.white30,
    this.activeColor = Colors.white,
  });

  @override
  State<StatefulWidget> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  /// 当前的索引
  int index = 0;
  final Paint _paint = Paint();

  /// 根据对应的布局类型, 创建对应的[BasePainter]
  /// [CustomPainter]
  BasePainter _createPainter() {
    switch (widget.layout) {
      case PageIndicatorLayout.none:
        return _NonePainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      case PageIndicatorLayout.slide:
        return _SlidePainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      case PageIndicatorLayout.warm:
        return _WarmPainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      case PageIndicatorLayout.color:
        return _ColorPainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      case PageIndicatorLayout.scale:
        return _ScalePainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      case PageIndicatorLayout.drop:
        return _DropPainter(
            widget, widget.controller.page ?? 0.0, index, _paint);
      default:
        throw Exception("Not a valid layout");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.count * widget.size + (widget.count - 1) * widget.space,
      height: widget.size,
      child: CustomPaint(
        painter: _createPainter(),
      ),
    );

    if (widget.layout == PageIndicatorLayout.scale ||
        widget.layout == PageIndicatorLayout.color) {
      child = ClipRect(
        child: child,
      );
    }

    return IgnorePointer(
      child: child,
    );
  }

  void _onController() {
    double page = widget.controller.page ?? 0.0;
    index = page.floor();

    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_onController);
    super.initState();
  }

  @override
  void didUpdateWidget(PageIndicator oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }
}

/// 指示器的布局方式
enum PageIndicatorLayout {
  /// 正常布局,
  none,

  /// 滑动布局,
  slide,

  /// 渐变宽度布局,
  warm,

  /// 渐变颜色布局,
  color,

  /// 缩放布局,
  scale,

  /// 水滴布局, 跳动,
  drop,
}

///----具体的画笔---

class _WarmPainter extends BasePainter {
  _WarmPainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double distance = size + space;
    double start = index * (size + space);

    if (progress > 0.5) {
      double right = start + size + distance;
      //progress=>0.5-1.0
      //left:0.0=>distance

      double left = index * distance + distance * (progress - 0.5) * 2;
      canvas.drawRRect(
          RRect.fromLTRBR(left, 0.0, right, size, Radius.circular(radius)),
          _paint);
    } else {
      double right = start + size + distance * progress * 2;

      canvas.drawRRect(
          RRect.fromLTRBR(start, 0.0, right, size, Radius.circular(radius)),
          _paint);
    }
  }
}

class _DropPainter extends BasePainter {
  _DropPainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double dropHeight = widget.dropHeight;
    double rate = (0.5 - progress).abs() * 2;
    double scale = widget.scale;

    //lerp(begin, end, progress)

    canvas.drawCircle(
        Offset(radius + ((page) * (size + space)),
            radius - dropHeight * (1 - rate)),
        radius * (scale + rate * (1.0 - scale)),
        _paint);
  }
}

class _NonePainter extends BasePainter {
  _NonePainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    if (progress > 0.5) {
      canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
    } else {
      canvas.drawCircle(
          Offset(radius + (index * (size + space)), radius), radius, _paint);
    }
  }
}

class _SlidePainter extends BasePainter {
  _SlidePainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    canvas.drawCircle(
        Offset(radius + (page * (size + space)), radius), radius, _paint);
  }
}

class _ScalePainter extends BasePainter {
  _ScalePainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    for (int i = 0, c = widget.count; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(Offset(i * (size + space) + radius, radius),
          radius * widget.scale, _paint);
    }

    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    double progress = page - index;
    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //last
    canvas.drawCircle(Offset(radius + (index * (size + space)), radius),
        lerp(radius, radius * widget.scale, progress), _paint);
    //first
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(Offset(secondOffset, radius),
        lerp(radius * widget.scale, radius, progress), _paint);
  }
}

class _ColorPainter extends BasePainter {
  _ColorPainter(
    super.widget,
    super.page,
    super.index,
    super.paint,
  );

  // 连续的两个点，含有最后一个和第一个
  @override
  bool _shouldSkip(int i) {
    if (index == widget.count - 1) {
      return i == 0 || i == index;
    }
    return (i == index || i == index + 1);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double secondOffset = index == widget.count - 1
        ? radius
        : radius + ((index + 1) * (size + space));

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //left
    canvas.drawCircle(
        Offset(radius + (index * (size + space)), radius), radius, _paint);
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
  }
}

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;

  BasePainter(
    this.widget,
    this.page,
    this.index,
    this._paint,
  );

  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  void draw(Canvas canvas, double space, double size, double radius);

  bool _shouldSkip(int index) {
    return false;
  }

  //double secondOffset = index == widget.count-1 ? radius : radius + ((index + 1) * (size + space));

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    for (int i = 0, c = widget.count; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
          Offset(i * (size + space) + radius, radius), radius, _paint);
    }

    double page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) => oldDelegate.page != page;
}
