part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a> \
/// @date 2025/06/14
///
/// 滑块验证码
/// https://dun.163.com/trial/jigsaw
class SliderCaptchaWidget extends StatefulWidget {
  /// 验证码的状态
  final SliderCaptchaState state;

  /// 滑动滑块完成的回调
  /// @return true:验证成功, false:验证失败
  final Future<bool> Function(double moveRadio)? onSliderFinish;

  /// 滑块横纵比, 影响滑块小部件的宽高比例
  final double? aspectRatio;

  /// 验证码背景图片url
  final String? backgroundImageUrl;

  /// [backgroundImageUrl]背景图的宽高
  final Size? backgroundImageSize;

  /// 验证的的图片url
  final String? activeImageUrl;

  /// [activeImageUrl]背景图的宽高
  final Size? activeImageSize;

  /// [activeImageUrl]图片在[backgroundImageUrl]背景中的Y偏移量(像素偏移量)
  final double activeImageOffsetY;

  /// 验证码背景右上角的活动按钮
  final Widget? action;

  const SliderCaptchaWidget({
    super.key,
    this.onSliderFinish,
    this.state = SliderCaptchaState.loading,
    this.aspectRatio,
    this.backgroundImageUrl,
    this.backgroundImageSize,
    this.activeImageUrl,
    this.activeImageSize,
    this.activeImageOffsetY = 0,
    this.action,
  });

  @override
  State<SliderCaptchaWidget> createState() => _SliderCaptchaWidgetState();
}

/// 当前滑块的状态
enum SliderCaptchaState {
  /// 默认状态
  normal,

  /// 加载中...
  loading,

  /// 验证成功
  success,

  /// 验证失败
  fail,
  ;
}

class _SliderCaptchaWidgetState extends State<SliderCaptchaWidget>
    with TickerProviderStateMixin {
  /// 浮子
  final thumbTag = "thumb";

  /// 轨道高度
  final _trackHeight = 40.0;

  /// 圆角
  final _radius = 2.0;

  /// 当前滑块左边移动的比例
  double _leftMoveRadio = 0.0;

  /// 手势移动在整体范围中的比例
  double _moveRadio = 0.0;

  /// 是否正在移动滑块
  bool _isMoving = false;

  /// 当前滑块的状态
  SliderCaptchaState get _sliderState => widget.state;

  /// 浮子状态颜色
  Color? getThumbStateColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    if (_isMoving) {
      return globalTheme.accentColor;
    }
    return switch (_sliderState) {
      SliderCaptchaState.success => globalTheme.successColor,
      SliderCaptchaState.fail => globalTheme.errorColor,
      _ => null,
    };
  }

  /// 浮子状态的图标
  IconData getThumbStateIcon(BuildContext context) {
    return switch (_sliderState) {
      SliderCaptchaState.success => Icons.check,
      SliderCaptchaState.fail => Icons.close,
      _ => Icons.arrow_forward,
    };
  }

  @override
  void didUpdateWidget(covariant SliderCaptchaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sliderState == SliderCaptchaState.loading) {
      _isMoving = false;
      _animateThumbTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lRes = libRes(context);
    final globalTheme = GlobalTheme.of(context);
    //debugger();
    final leftMoveRadio = _leftMoveRadio;
    return Column(
      spacing: kX,
      children: [
        //图片
        ScaleMatrixContainerLayout(
          aspectRatio: widget.aspectRatio,
          refChildIndex: _sliderState == SliderCaptchaState.loading ? null : 0,
          children: [
            if (_sliderState == SliderCaptchaState.loading)
              ScaleMatrixParentDataWidget(
                ignoreTransform: true,
                childConstraints: LayoutBoxConstraints.matchParent(),
                child: buildLoadingWidget(context)
                    .size(size: 50)
                    .backgroundColor(globalTheme.lineDarkColor),
              ),
            if (_sliderState != SliderCaptchaState.loading &&
                widget.backgroundImageUrl != null)
              ScaleMatrixParentDataWidget(
                childConstraints: widget.backgroundImageSize == null
                    ? null
                    : LayoutBoxConstraints.fixedSize(
                        widget.backgroundImageSize!.width,
                        widget.backgroundImageSize!.height,
                      ),
                child: Image.network(widget.backgroundImageUrl!),
              ),
            if (_sliderState != SliderCaptchaState.loading &&
                widget.activeImageUrl != null)
              ScaleMatrixParentDataWidget(
                  childOffset: Offset(0, widget.activeImageOffsetY),
                  childOffsetRadio: Offset(leftMoveRadio, 0),
                  childConstraints: widget.activeImageSize == null
                      ? null
                      : LayoutBoxConstraints.fixedSize(
                          widget.activeImageSize!.width,
                          widget.activeImageSize!.height,
                        ),
                  child: Image.network(widget.activeImageUrl!)),
          ],
        ).stackOf(widget.action, alignment: Alignment.topRight),
        //滑块
        ScaleMatrixContainerLayout(
          onHandlePointerEvent: (render, event, tx, ty) {
            if (event.isPointerDown &&
                _sliderState == SliderCaptchaState.normal) {
              if (render.hitTestChild(thumbTag, event.localPosition)) {
                //_sliderState = SliderCaptchaState.moving;
                _isMoving = true;
                updateState();
              }
            } else if (event.isPointerFinish && _isMoving) {
              //开始校验验证码
              final onSliderFinish = widget.onSliderFinish;
              if (onSliderFinish == null) {
                //_sliderState = SliderCaptchaState.fail;
                //updateState();
                _animateThumbTo(0);
              } else {
                onSliderFinish.call(_moveRadio).then((value) {
                  /*if (value) {
                    _sliderState = SliderCaptchaState.success;
                    updateState();
                  } else {
                    _sliderState = SliderCaptchaState.fail;
                    _animateThumbTo(0);
                  }*/
                });
              }
            }
            if (_isMoving) {
              _leftMoveRadio =
                  clampDouble(tx / (render.size.width - _trackHeight), 0, 1);
              _moveRadio = clampDouble(tx / render.size.width, 0, 1);
              //l.d("tx:$tx ${render.size.width} _moveRadio: $_moveRadio");
              updateState();
            }
          },
          children: [
            paintWidget((canvas, size) {
              final rect = Rect.fromLTWH(0, 0, size.width, size.height);
              final color = Color(0xffe5e7eb);
              _drawTrackRect(canvas, rect, color);

              //--
              final rect2 = Rect.fromLTWH(
                  0,
                  0,
                  (size.width - _trackHeight) * leftMoveRadio + _trackHeight,
                  size.height);
              _drawTrackRect(canvas, rect2, getThumbStateColor(context));
            }),
            ScaleMatrixParentDataWidget(
              tag: thumbTag,
              childOffsetRadio: Offset(leftMoveRadio, 0),
              child: Icon(
                getThumbStateIcon(context),
                size: 16,
                color: globalTheme.textPrimaryStyle.color,
              ).backgroundDecoration(paintDecoration((canvas, size) {
                final rect = Rect.fromLTWH(0, 0, size.width, size.height);
                canvas.drawRRect(
                    rect.inflate(-1).toRRect(_radius),
                    Paint()
                      ..color = getThumbStateColor(context) ?? Colors.white
                      ..style = PaintingStyle.fill);
              })).size(size: _trackHeight),
            ),
            if (_sliderState == SliderCaptchaState.loading)
              ScaleMatrixParentDataWidget(
                ignoreTransform: true,
                childConstraints: LayoutBoxConstraints.matchParent(),
                child: lRes?.libLoading.text().center() ?? empty,
              ),
          ],
        ).size(height: _trackHeight)
      ],
    ).paddingOnly(all: kX);
  }

  //--

  /// 获取加载中...的小部件
  Widget buildLoadingWidget(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    return globalConfig.loadingIndicatorBuilder(context, null, null, null);
  }

  //--

  /// 绘制轨道
  void _drawTrackRect(Canvas canvas, Rect rect, Color? color) {
    if (color == null) {
      return;
    }
    canvas.drawRRect(
        rect.toRRect(_radius),
        Paint()
          ..color = color.withOpacityRatio(0.2)
          ..style = PaintingStyle.fill);
    canvas.drawRRect(
        rect.toRRect(_radius),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke);
  }

  /// 动画的方式移动滑块
  void _animateThumbTo(double value) {
    startValueAnimation(_leftMoveRadio, value, this, (value, isCompleted) {
      _leftMoveRadio = value;
      if (isCompleted) {
        //_sliderState = SliderCaptchaState.normal;
      }
      updateState();
    });
  }
}
