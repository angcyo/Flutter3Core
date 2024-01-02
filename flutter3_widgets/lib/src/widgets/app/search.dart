part of flutter3_widgets;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/29
///

const double kSearchBarHeight = 60;

class SearchFieldWidget extends StatelessWidget implements PreferredSizeWidget {
  /// 大小
  final Size size;

  /// 输入框控制
  final TextFieldConfig searchFieldConfig;

  /// 内边距
  final EdgeInsets padding;

  /// 输入框内边距
  final EdgeInsets contentPadding;

  const SearchFieldWidget({
    super.key,
    this.size = const Size(double.infinity, kSearchBarHeight),
    required this.searchFieldConfig,
    this.padding = const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: kX, vertical: kH),
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return Container(
      width: size.width,
      height: size.height,
      padding: padding,
      alignment: Alignment.center,
      //color: Colors.red,
      child: SingleInputWidget(
        config: searchFieldConfig,
        contentPadding: contentPadding,
        textInputAction: TextInputAction.search,
        fillColor: globalTheme.whiteBgColor,
        borderColor: Colors.transparent,
        borderRadius: 25,
        /*decoration: InputDecoration(
          filled: true,
          fillColor: Colors.redAccent,
          //borderRadius: BorderRadius.circular(kDefaultBorderRadiusXX),
        ),*/
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  ui.Size get preferredSize => size;
}
