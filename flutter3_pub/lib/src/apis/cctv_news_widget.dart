import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';

import '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/02
///
///
/// 显示[CCTVNewsItemBean]数据结构的小部件
///
class CctvNewsItemWidget extends StatefulWidget {
  /// 显示的数据
  final CCTVNewsItemBean? cctvNewsItemBean;

  const CctvNewsItemWidget({super.key, required this.cctvNewsItemBean});

  @override
  State<CctvNewsItemWidget> createState() => _CctvNewsItemWidgetState();
}

class _CctvNewsItemWidgetState extends State<CctvNewsItemWidget> {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final bean = widget.cctvNewsItemBean;
    /*assert(() {
      l.d("build $bean");
      return true;
    }());*/
    return [
      bean?.image?.toImageWidget(size: 120).click(() {
        buildContext?.showWidgetDialog(
          SinglePhotoDialog(
            imageProvider: bean.image?.toCacheNetworkImageProvider(),
          ),
        );
      }),
      [
            bean?.title?.text(
              selectable: true,
              bold: true,
              style: globalTheme.textTitleStyle,
            ),
            bean?.focusDate?.text(
              selectable: true,
              style: globalTheme.textDesStyle,
            ),
            bean?.brief?.text(selectable: true),
          ]
          .column(crossAxisAlignment: .start, gap: kL)
          ?.insets(nTop: kX)
          .expanded(),
    ].row(crossAxisAlignment: .start)!.click(() {
      openWebUrl(bean?.url);
    });
  }
}
