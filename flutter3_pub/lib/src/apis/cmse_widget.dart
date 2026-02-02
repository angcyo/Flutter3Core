import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/31
///
/// 显示[CmseFXRWItemBean]数据结构的小部件
///
class CmseItemWidget extends StatefulWidget {
  /// 显示的飞天任务数据
  final CmseFXRWItemBean? cmseItemBean;

  const CmseItemWidget({super.key, required this.cmseItemBean});

  @override
  State<CmseItemWidget> createState() => _CmseItemWidgetState();
}

class _CmseItemWidgetState extends State<CmseItemWidget> {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final bean = widget.cmseItemBean;
    /*assert(() {
      l.d("build $bean");
      return true;
    }());*/
    return [
      bean?.imgUrl?.toImageWidget(size: 120).click(() {
        buildContext?.showWidgetDialog(
          SinglePhotoDialog(
            imageProvider: bean.imgUrl?.toCacheNetworkImageProvider(),
          ),
        );
      }),
      [
            bean?.title?.text(selectable: true),
            ...?bean?.infoItemList?.map(
              (e) => [
                e.$1?.text(selectable: true),
                e.$2?.text(selectable: true).expanded(),
              ].row(crossAxisAlignment: .start),
            ),
          ]
          .column(crossAxisAlignment: .start, gap: kL)
          ?.insets(nTop: kX)
          .expanded(),
    ].row(crossAxisAlignment: .start)!;
  }
}
