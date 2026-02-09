import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';

import '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/09
///
/// 显示[SppNewsItemBean]数据结构的小部件
///
class SppNewsWidget extends StatefulWidget {
  /// 需要显示的数据结构
  final SppNewsItemBean? sppNewsItemBean;

  const SppNewsWidget({super.key, required this.sppNewsItemBean});

  @override
  State<SppNewsWidget> createState() => _SppNewsWidgetState();
}

class _SppNewsWidgetState extends State<SppNewsWidget> {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final bean = widget.sppNewsItemBean;
    /*assert(() {
      l.d("build $bean");
      return true;
    }());*/
    return [
      bean?.title?.text(bold: true, selectable: true).expanded(),
      bean?.time?.text(style: globalTheme.textDesStyle, selectable: true),
    ].row(crossAxisAlignment: .center)!.click(() {
      openWebUrl(bean?.url);
    });
  }
}
