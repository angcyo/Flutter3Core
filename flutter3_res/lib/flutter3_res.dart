library flutter3_res;

import 'dart:io';
import 'dart:ui';

import 'package:bidi/bidi.dart' as bidi;
import 'package:intl/intl.dart' as intl;

import 'l10n/generated/intl/messages_en.dart' as messages_en;
import 'l10n/generated/intl/messages_zh.dart' as messages_zh;

export 'l10n/generated/l10n.dart';

part 'intl_ex.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/02
///
/// 一些公共资源存放
/// 1:国际化翻译资源
///
/// 当有多个res语言资源库时, 需要合并到一个map中, 才可能正常使用
/// 在主的[messages]中添加所有子模块的资源即可
/// ```
/// /// 合并国际化资源
/// @initialize
/// void mergeIntl() {
///   messages_en.messages.messages
///     ..addAll(lpResEnMessages)
///     ..addAll(libResZhMessages);
///   messages_zh.messages.messages
///     ..addAll(lpResZhMessages)
///     ..addAll(libResZhMessages);
/// }
/// ```

Map<String, dynamic> get libResEnMessages => messages_en.messages.messages;

Map<String, dynamic> get libResZhMessages => messages_zh.messages.messages;
