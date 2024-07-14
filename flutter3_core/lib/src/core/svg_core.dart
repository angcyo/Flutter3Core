part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///
/// 优先从app的资产中读取svg, 然后降级到lib的资产中读取
class AppPackageAssetsSvgWidget extends StatefulWidget {
  //--package

  /// 资产在app中的全路径key
  final String? appKey;

  /// 资产在lib中的全路径key
  final String? libKey;

  /// 不指定[libKey]时, 可以单独指定[libPackage]
  final String? libPackage;

  /// 资源的key, 优先使用此key在app中加载, 然后再在lib中加载
  /// 全路径是[libPackage]+[resKey]
  final String? resKey;

  //--svg

  final Color? tintColor;
  final UiColorFilter? colorFilter;
  final BoxFit fit;

  final double? size;
  final double? width;
  final double? height;

  const AppPackageAssetsSvgWidget({
    super.key,
    this.appKey,
    this.libKey,
    this.libPackage,
    this.resKey,
    //--svg
    this.tintColor,
    this.colorFilter,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<AppPackageAssetsSvgWidget> createState() =>
      _AppPackageAssetsSvgWidgetState();
}

class _AppPackageAssetsSvgWidgetState extends State<AppPackageAssetsSvgWidget> {
  /// 正在加载的资源key
  String? loadResKey;

  @override
  void initState() {
    _checkOrLoadResKey();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppPackageAssetsSvgWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkOrLoadResKey(true);
  }

  @override
  Widget build(BuildContext context) {
    return isNil(loadResKey)
        ? empty
        : loadAssetSvgWidget(
            loadResKey!,
            package: null,
            tintColor: widget.tintColor,
            colorFilter: widget.colorFilter,
            size: widget.size,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
  }

  /// 检查[widget.appKey]是否存在, 如果不存在, 则使用[widget.libKey]
  Future _checkOrLoadResKey([bool update = false]) async {
    //debugger();

    final libPackagePath =
        isNil(widget.libPackage) ? "" : "packages/${widget.libPackage}/";

    final appKey = widget.appKey ??
        widget.resKey?.replaceAll(libPackagePath, "").ensurePackagePrefix();
    final libKey =
        widget.libKey ?? widget.resKey?.ensurePackagePrefix(widget.libPackage);

    final old = loadResKey;
    if (isNil(appKey)) {
      //如果未指定app key, 则直接使用lib key加载
      loadResKey = libKey;
      if (loadResKey != old) {
        if (update) {
          updateState();
        }
      }
      return;
    }
    loadResKey = appKey; //先给界面加载
    //1:检查app key是否有资源
    final exists = await isAssetKeyExists(appKey);
    if (!exists) {
      //不存在
      loadResKey = libKey; //使用lib key加载
      if (update) {
        updateState();
      }
    }
  }
}

//region Asset

/// [loadAssetImageWidget]
/// [package] 如果资源不在当前项目中, 需要指定package才能访问
SvgPicture loadAssetSvgWidget(
  String key, {
  Color? tintColor,
  String? prefix = kDefAssetsSvgPrefix,
  String? package,
  double? size, //同时设置[width][height]
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  ColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.asset(
      key.ensurePackagePrefix(package, prefix),
      semanticsLabel: key,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: size ?? width,
      height: size ?? height,
      fit: fit,
      placeholderBuilder: placeholderBuilder,
    );

SvgPicture loadHttpSvgWidget(
  String url, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.network(
      url,
      semanticsLabel: url,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: size ?? width,
      height: size ?? height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: size ?? width,
                height: size ?? height,
              ),
    );

SvgPicture loadFileSvgWidget(
  String path, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.file(
      path.file(),
      semanticsLabel: path,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: size ?? width,
      height: size ?? height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: size ?? width,
                height: size ?? height,
              ),
    );

SvgPicture loadStringSvgWidget(
  String string, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.string(
      string,
      semanticsLabel: string,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: size ?? width,
      height: size ?? height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: size ?? width,
                height: size ?? height,
              ),
    );

//endregion Asset
