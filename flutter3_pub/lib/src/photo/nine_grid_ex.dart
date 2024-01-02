part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/02
/// 九宫格图片显示
extension NineGridEx on Iterable<String> {
  /// 九宫格显示
  /// ```
  /// [https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/app/images/7aa81b92-873e-05f8-f93d-2e3263d6b595.png?w=329&h=1491&,
  /// https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/app/images/afee70e4-93e7-1a92-5120-be915d8d9042.png?w=782&h=528&,
  /// https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/app/images/5932d014-0c38-0611-ab33-739543570e59.png?w=900&h=941&, https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/app/images/46446dd0-32f3-3a77-c330-597102692134.png?w=800&h=913&]
  /// ```
  /// [padding] 网格部件内边距
  /// [margin] 网格部件外边距
  /// [space] 网格间隙
  NineGridView nineGrid({
    NineGridType type = NineGridType.normal,
    AlignmentGeometry? alignment = Alignment.topLeft,
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets margin = EdgeInsets.zero,
    double space = 5,
    String wKey = "w",
    String hKey = "h",
  }) {
    final list = this;
    final count = list.length;
    final isBigImage = count == 1;
    double? bigImageWidth;
    double? bigImageHeight;
    if (isBigImage) {
      //单图, 显示原图
      final uri = list.first.toUri();
      bigImageWidth = uri?.queryParameters[wKey]?.toDoubleOrNull();
      bigImageHeight = uri?.queryParameters[hKey]?.toDoubleOrNull();
    }
    return NineGridView(
      type: type,
      alignment: alignment,
      itemCount: count,
      itemBuilder: (context, index) {
        final url = list.elementAt(index);
        return url
            .toImageWidget(
                fit: isBigImage ? BoxFit.fitWidth : BoxFit.cover,
                memCacheWidth: isBigImage ? null : (screenWidth / 3).ceil())
            .hero(url.baseRawUrl)
            .click(() {
          //大图预览
          context.showPhotoPage(
              initialIndex: index,
              imageProviders: list.mapToList(
                  (url) => (url as String).baseRawUrl.toImageProvider()));
        });
      },
      bigImageWidth: bigImageWidth?.ceil(),
      bigImageHeight: bigImageHeight?.ceil(),
      space: space,
      margin: margin,
      padding: padding,
    );
  }
}
