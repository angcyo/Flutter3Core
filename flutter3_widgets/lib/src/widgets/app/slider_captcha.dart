part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a> \
/// @date 2025/06/14
///
/// 滑块验证码
/// https://dun.163.com/trial/jigsaw
class SliderCaptchaWidget extends StatefulWidget {
  /// 滑动滑块完成的回调
  /// @return true:验证成功, false:验证失败
  final Future<bool> Function(double moveRadio)? onSliderFinish;

  const SliderCaptchaWidget({
    super.key,
    this.onSliderFinish,
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

  /// 正在滑动
  moving,

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

  /// 当前滑块移动的比例
  double _moveRadio = 0.0;

  /// 当前滑块的状态
  SliderCaptchaState _sliderState = SliderCaptchaState.normal;

  /// 浮子状态颜色
  Color? getThumbStateColor(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return switch (_sliderState) {
      SliderCaptchaState.success => globalTheme.successColor,
      SliderCaptchaState.fail => globalTheme.errorColor,
      SliderCaptchaState.moving => globalTheme.accentColor,
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
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return Column(
      spacing: kX,
      children: [
        //图片
        ScaleMatrixContainerLayout(
          aspectRatio: 590 / 360,
          children: [
            Image.network(
                "http://192.168.31.76:8888/slider_captcha_background.png"),
            ScaleMatrixParentDataWidget(
                childOffset: Offset(0, 126),
                childOffsetRadio: Offset(_moveRadio, 0),
                child: Image.network(
                    "http://192.168.31.76:8888/slider_captcha_active.png")),
          ],
        ),
        //滑块
        ScaleMatrixContainerLayout(
          onHandlePointerEvent: (render, event, tx, ty) {
            if (event.isPointerDown &&
                _sliderState == SliderCaptchaState.normal) {
              if (render.hitTestChild(thumbTag, event.localPosition)) {
                _sliderState = SliderCaptchaState.moving;
                updateState();
              }
            } else if (event.isPointerFinish &&
                _sliderState == SliderCaptchaState.moving) {
              //开始校验验证码
              final onSliderFinish = widget.onSliderFinish;
              if (onSliderFinish == null) {
                //_sliderState = SliderCaptchaState.fail;
                //updateState();
                _animateThumbTo(0);
              } else {
                onSliderFinish.call(_moveRadio).then((value) {
                  if (value) {
                    _sliderState = SliderCaptchaState.success;
                    updateState();
                  } else {
                    _sliderState = SliderCaptchaState.fail;
                    _animateThumbTo(0);
                  }
                });
              }
            }
            if (_sliderState == SliderCaptchaState.moving) {
              _moveRadio =
                  clampDouble(tx / (render.size.width - _trackHeight), 0, 1);
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
                  (size.width - _trackHeight) * _moveRadio + _trackHeight,
                  size.height);
              _drawTrackRect(canvas, rect2, getThumbStateColor(context));
            }),
            ScaleMatrixParentDataWidget(
              tag: thumbTag,
              childOffsetRadio: Offset(_moveRadio, 0),
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
          ],
        ).size(height: _trackHeight)
      ],
    ).paddingOnly(all: kX);
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
    startValueAnimation(_moveRadio, value, this, (value, isCompleted) {
      _moveRadio = value;
      if (isCompleted) {
        _sliderState = SliderCaptchaState.normal;
      }
      updateState();
    });
  }
}
