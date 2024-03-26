/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsPngGen {
  const $AssetsPngGen();

  /// File path: assets/png/core_file_icon_7z.png
  AssetGenImage get coreFileIcon7z =>
      const AssetGenImage('assets/png/core_file_icon_7z.png');

  /// File path: assets/png/core_file_icon_apk.png
  AssetGenImage get coreFileIconApk =>
      const AssetGenImage('assets/png/core_file_icon_apk.png');

  /// File path: assets/png/core_file_icon_audio.png
  AssetGenImage get coreFileIconAudio =>
      const AssetGenImage('assets/png/core_file_icon_audio.png');

  /// File path: assets/png/core_file_icon_emptyfile.png
  AssetGenImage get coreFileIconEmptyfile =>
      const AssetGenImage('assets/png/core_file_icon_emptyfile.png');

  /// File path: assets/png/core_file_icon_folder.png
  AssetGenImage get coreFileIconFolder =>
      const AssetGenImage('assets/png/core_file_icon_folder.png');

  /// File path: assets/png/core_file_icon_font.png
  AssetGenImage get coreFileIconFont =>
      const AssetGenImage('assets/png/core_file_icon_font.png');

  /// File path: assets/png/core_file_icon_log.png
  AssetGenImage get coreFileIconLog =>
      const AssetGenImage('assets/png/core_file_icon_log.png');

  /// File path: assets/png/core_file_icon_picture.png
  AssetGenImage get coreFileIconPicture =>
      const AssetGenImage('assets/png/core_file_icon_picture.png');

  /// File path: assets/png/core_file_icon_rar.png
  AssetGenImage get coreFileIconRar =>
      const AssetGenImage('assets/png/core_file_icon_rar.png');

  /// File path: assets/png/core_file_icon_text.png
  AssetGenImage get coreFileIconText =>
      const AssetGenImage('assets/png/core_file_icon_text.png');

  /// File path: assets/png/core_file_icon_unknown.png
  AssetGenImage get coreFileIconUnknown =>
      const AssetGenImage('assets/png/core_file_icon_unknown.png');

  /// File path: assets/png/core_file_icon_video.png
  AssetGenImage get coreFileIconVideo =>
      const AssetGenImage('assets/png/core_file_icon_video.png');

  /// File path: assets/png/core_file_icon_xml.png
  AssetGenImage get coreFileIconXml =>
      const AssetGenImage('assets/png/core_file_icon_xml.png');

  /// File path: assets/png/core_file_icon_zip.png
  AssetGenImage get coreFileIconZip =>
      const AssetGenImage('assets/png/core_file_icon_zip.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        coreFileIcon7z,
        coreFileIconApk,
        coreFileIconAudio,
        coreFileIconEmptyfile,
        coreFileIconFolder,
        coreFileIconFont,
        coreFileIconLog,
        coreFileIconPicture,
        coreFileIconRar,
        coreFileIconText,
        coreFileIconUnknown,
        coreFileIconVideo,
        coreFileIconXml,
        coreFileIconZip
      ];
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/file_browse_delete.svg
  String get fileBrowseDelete => 'assets/svg/file_browse_delete.svg';

  /// File path: assets/svg/file_browse_home.svg
  String get fileBrowseHome => 'assets/svg/file_browse_home.svg';

  /// File path: assets/svg/file_browse_open.svg
  String get fileBrowseOpen => 'assets/svg/file_browse_open.svg';

  /// File path: assets/svg/file_browse_share.svg
  String get fileBrowseShare => 'assets/svg/file_browse_share.svg';

  /// File path: assets/svg/keyboard_backspace.svg
  String get keyboardBackspace => 'assets/svg/keyboard_backspace.svg';

  /// File path: assets/svg/keyboard_pack_up.svg
  String get keyboardPackUp => 'assets/svg/keyboard_pack_up.svg';

  /// List of all assets
  List<String> get values => [
        fileBrowseDelete,
        fileBrowseHome,
        fileBrowseOpen,
        fileBrowseShare,
        keyboardBackspace,
        keyboardPackUp
      ];
}

class Assets {
  Assets._();

  static const $AssetsPngGen png = $AssetsPngGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
