// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class LibRes {
  LibRes();

  static LibRes? _current;

  static LibRes get current {
    assert(
      _current != null,
      'No instance of LibRes was loaded. Try to initialize the LibRes delegate before accessing LibRes.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<LibRes> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = LibRes();
      LibRes._current = instance;

      return instance;
    });
  }

  static LibRes of(BuildContext context) {
    final instance = LibRes.maybeOf(context);
    assert(
      instance != null,
      'No instance of LibRes present in the widget tree. Did you add LibRes.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static LibRes? maybeOf(BuildContext context) {
    return Localizations.of<LibRes>(context, LibRes);
  }

  /// `只有中文[zh]翻译资源`
  String get testOnlyZhKey {
    return Intl.message(
      '只有中文[zh]翻译资源',
      name: 'testOnlyZhKey',
      desc: '当前key[testOnlyZhKey]只有中文[zh]资源',
      args: [],
    );
  }

  /// `testResKey翻译资源`
  String get testResKey {
    return Intl.message(
      'testResKey翻译资源',
      name: 'testResKey',
      desc: '当前key[testResKey]都有',
      args: [],
    );
  }

  /// `占位资源{value}`
  String testPlaceholderKey(String value) {
    return Intl.message(
      '占位资源$value',
      name: 'testPlaceholderKey',
      desc: '',
      args: [value],
    );
  }

  /// `暂无数据`
  String get libAdapterNoData {
    return Intl.message(
      '暂无数据',
      name: 'libAdapterNoData',
      desc: '列表加载暂无数据',
      args: [],
    );
  }

  /// `~已经到底啦~`
  String get libAdapterNoMoreData {
    return Intl.message(
      '~已经到底啦~',
      name: 'libAdapterNoMoreData',
      desc: '列表无更多数据加载',
      args: [],
    );
  }

  /// `加载失败, 点击重试`
  String get libAdapterLoadMoreError {
    return Intl.message(
      '加载失败, 点击重试',
      name: 'libAdapterLoadMoreError',
      desc: '列表加载更多数据失败',
      args: [],
    );
  }

  /// `刷新`
  String get libRefresh {
    return Intl.message('刷新', name: 'libRefresh', desc: '', args: []);
  }

  /// `完成`
  String get libFinish {
    return Intl.message('完成', name: 'libFinish', desc: '', args: []);
  }

  /// `返回`
  String get libBack {
    return Intl.message('返回', name: 'libBack', desc: '', args: []);
  }

  /// `添加`
  String get libAdd {
    return Intl.message('添加', name: 'libAdd', desc: '', args: []);
  }

  /// `编辑`
  String get libEdit {
    return Intl.message('编辑', name: 'libEdit', desc: '', args: []);
  }

  /// `确定`
  String get libConfirm {
    return Intl.message('确定', name: 'libConfirm', desc: '', args: []);
  }

  /// `取消`
  String get libCancel {
    return Intl.message('取消', name: 'libCancel', desc: '', args: []);
  }

  /// `继续`
  String get libContinue {
    return Intl.message('继续', name: 'libContinue', desc: '', args: []);
  }

  /// `请选择`
  String get libChoose {
    return Intl.message('请选择', name: 'libChoose', desc: '', args: []);
  }

  /// `警告`
  String get libWarn {
    return Intl.message('警告', name: 'libWarn', desc: '', args: []);
  }

  /// `提示`
  String get libTips {
    return Intl.message('提示', name: 'libTips', desc: '', args: []);
  }

  /// `删除`
  String get libDelete {
    return Intl.message('删除', name: 'libDelete', desc: '', args: []);
  }

  /// `删除后无法恢复，确认删除吗？`
  String get libDeleteTip {
    return Intl.message(
      '删除后无法恢复，确认删除吗？',
      name: 'libDeleteTip',
      desc: '',
      args: [],
    );
  }

  /// `下一步`
  String get libNext {
    return Intl.message('下一步', name: 'libNext', desc: '', args: []);
  }

  /// `打开`
  String get libOpen {
    return Intl.message('打开', name: 'libOpen', desc: '', args: []);
  }

  /// `分享`
  String get libShare {
    return Intl.message('分享', name: 'libShare', desc: '', args: []);
  }

  /// `请稍等...`
  String get libWaitTip {
    return Intl.message('请稍等...', name: 'libWaitTip', desc: '', args: []);
  }

  /// `有效范围`
  String get libValidRangeTip {
    return Intl.message('有效范围', name: 'libValidRangeTip', desc: '', args: []);
  }

  /// `我知道了`
  String get libKnown {
    return Intl.message('我知道了', name: 'libKnown', desc: '', args: []);
  }

  /// `保存`
  String get libSave {
    return Intl.message('保存', name: 'libSave', desc: '', args: []);
  }

  /// `保存成功`
  String get libSaveSuccessful {
    return Intl.message('保存成功', name: 'libSaveSuccessful', desc: '', args: []);
  }

  /// `保存失败`
  String get libSaveFailure {
    return Intl.message('保存失败', name: 'libSaveFailure', desc: '', args: []);
  }

  /// `是`
  String get libYes {
    return Intl.message('是', name: 'libYes', desc: '', args: []);
  }

  /// `否`
  String get libNo {
    return Intl.message('否', name: 'libNo', desc: '', args: []);
  }

  /// `重命名`
  String get libRename {
    return Intl.message('重命名', name: 'libRename', desc: '', args: []);
  }

  /// `复制`
  String get libCopy {
    return Intl.message('复制', name: 'libCopy', desc: '', args: []);
  }

  /// `外部分享`
  String get libExternalShare {
    return Intl.message('外部分享', name: 'libExternalShare', desc: '', args: []);
  }

  /// `加载中...`
  String get libLoading {
    return Intl.message('加载中...', name: 'libLoading', desc: '', args: []);
  }

  /// `下载中...`
  String get libDownloading {
    return Intl.message('下载中...', name: 'libDownloading', desc: '', args: []);
  }

  /// `发现新版本`
  String get libNewReleases {
    return Intl.message('发现新版本', name: 'libNewReleases', desc: '', args: []);
  }

  /// `下次再说`
  String get libNextTime {
    return Intl.message('下次再说', name: 'libNextTime', desc: '', args: []);
  }

  /// `前往下载`
  String get libGoDownload {
    return Intl.message('前往下载', name: 'libGoDownload', desc: '', args: []);
  }

  /// `立即下载`
  String get libDownloadNow {
    return Intl.message('立即下载', name: 'libDownloadNow', desc: '', args: []);
  }

  /// `点击重试`
  String get libClickRetry {
    return Intl.message('点击重试', name: 'libClickRetry', desc: '', args: []);
  }

  /// `立即安装`
  String get libInstallNow {
    return Intl.message('立即安装', name: 'libInstallNow', desc: '', args: []);
  }

  /// `开始升级`
  String get libUpgradeNow {
    return Intl.message('开始升级', name: 'libUpgradeNow', desc: '', args: []);
  }

  /// `更新失败`
  String get libUpgradeFailure {
    return Intl.message('更新失败', name: 'libUpgradeFailure', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<LibRes> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<LibRes> load(Locale locale) => LibRes.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
