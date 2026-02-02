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

  /// 是否显示简要信息
  final bool isBrief;

  const IdiomWidget({super.key, required this.idiomBean, this.isBrief = true});

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final body = idiomBean == null
        ? globalConfig
              .loadingIndicatorBuilder(context, this, null, null)
              .align(Alignment.center)
              .paddingOnly(all: kXx)
        : [
                idiomBean!.pronounce.text(
                  style: globalTheme.textPlaceStyle,
                  fontSize: 9,
                ),
                idiomBean!.name.text(),
                if (!isBrief)
                  idiomBean!.des
                      .text(style: globalTheme.textDesStyle)
                      .paddingOnly(top: kL),
                if (!isBrief)
                  idiomBean!.sample
                      .text(style: globalTheme.textSubStyle)
                      .paddingOnly(top: kL),
              ]
              .column(crossAxisAlignment: CrossAxisAlignment.start)!
              .paddingOnly(all: kH)
              .ink(() {
                //idiomBean!.url.launch();
                openWebUrl(idiomBean!.url, context);
              });
    return body.animatedSize(alignment: Alignment.topCenter).card();
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
    return IdiomWidget(idiomBean: _idiomBean, isBrief: !_isHover)
        .frameOf(
          Icon(Icons.refresh, color: Colors.grey)
              .rotateAnimation(enable: _isFetch)
              .paddingOnly(all: kX)
              .inkWellCircle(() {
                _fetchIdiom();
              })
              .align(Alignment.topRight)
              .material(),
        )
        .mouse(
          onMouseAction: (enter) {
            _isHover = enter;
            updateState();
          },
        );
  }

  /// 获取一个成语
  void _fetchIdiom() {
    _isFetch = true;
    updateState();
    $idiomApi.getRandomIdiom().get((data, error) {
      _idiomBean = data;
      _isFetch = false;
      updateState();
    });
  }
}
