import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';

import 'idiom_api.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/29
///
/// 显示[IdiomBean]数据结构的小部件
class IdiomWidget extends StatelessWidget {
  /// 显示的成语数据
  final IdiomBean? idiomBean;

  /// 错误信息
  final Object? error;

  /// 是否显示简要信息
  final bool isBrief;

  const IdiomWidget({
    super.key,
    required this.idiomBean,
    this.isBrief = true,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final bean = idiomBean;
    final body = error != null
        ? "成语获取失败".text(textAlign: .center).insets(all: kX)
        : bean == null
        ? globalConfig
              .loadingIndicatorBuilder(context, this, null, null)
              .align(Alignment.center)
              .paddingOnly(all: kXx)
        : [
                bean.pronounce.text(
                  style: globalTheme.textPlaceStyle,
                  fontSize: 9,
                ),
                bean.name.text(),
                if (!isBrief)
                  bean.des
                      .text(style: globalTheme.textDesStyle)
                      .paddingOnly(top: kL),
                if (!isBrief)
                  bean.sample
                      .text(style: globalTheme.textSubStyle)
                      .paddingOnly(top: kL),
              ]
              .column(crossAxisAlignment: .start)!
              .paddingOnly(all: kH)
              .ink(
                () {
                  //idiomBean!.url.launch();
                  openWebUrl(bean.url, context);
                },
                enable: !isNil(bean.url),
                useDisableCursorStyle: false,
              );
    return body.animatedSize(alignment: .topCenter).card();
  }
}

/// 随机获取一个成语并显示
class RandomIdiomWidget extends StatefulWidget {
  const RandomIdiomWidget({super.key});

  @override
  State<RandomIdiomWidget> createState() => _RandomIdiomWidgetState();
}

class _RandomIdiomWidgetState extends State<RandomIdiomWidget> {
  /// 随机获取到的成语
  IdiomBean? _idiomBean;

  /// 错误信息
  Object? _error;

  /// 鼠标是否进入
  bool _isHover = false;

  /// 是否正在获取数据
  bool _isFetch = false;

  @override
  void initState() {
    _fetchIdiom();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IdiomWidget(idiomBean: _idiomBean, isBrief: !_isHover, error: _error)
        .frameOf(
          Icon(Icons.refresh, color: Colors.grey)
              .rotateAnimation(enable: _isFetch)
              .paddingOnly(all: kX)
              .inkWellCircle(() {
                _fetchIdiom();
              }, cursor: SystemMouseCursors.click)
              .align(.topRight)
              .material(),
        )
        .mouse(
          onMouseAction: (event, enter) {
            _isHover = enter;
            updateState();
          },
        );
  }

  /// 获取一个成语
  void _fetchIdiom() {
    _isFetch = true;
    updateState();
    $idiomApi.getRandomIdiom(throwError: true).get((data, error) {
      if (data == null) {
        $idiomApi.getRandomIdiomFromChineseXinhua(throwError: true).get((
          data,
          error,
        ) {
          _idiomBean = data;
          _error = error;
          _isFetch = false;
          updateState();
        });
      } else {
        _idiomBean = data;
        _error = error;
        _isFetch = false;
        updateState();
      }
    });
  }
}
