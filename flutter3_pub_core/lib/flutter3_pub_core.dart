library flutter3_pub_core;

import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:watch_it/watch_it.dart';

export 'package:get_it/get_it.dart';
export 'package:rxdart/rxdart.dart';
export 'package:watch_it/watch_it.dart';
export 'package:easy_refresh/easy_refresh.dart';
export 'package:el_tooltip/el_tooltip.dart';

part 'src/refresh/easy_refresh_ex.dart';
part 'src/tooltip/el_tooltip_ex.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/5
///
/// get it
/// ```
/// $get.registerSingleton<AppModel>(AppModel());
/// $get<AppModel>();
/// ```
final $get = GetIt.instance;

/// watch it
/// ```
/// class MyWidget extends StatelessWidget with WatchItMixin {
///   @override
///   Widget build(BuildContext context) {
///     String country = watchValue((Model x) => x.country);
///     ...
///   }
/// }
/// ```
///
/// [WatchItMixin]
/// [WatchItStatefulWidgetMixin]
final $di = di;

void _test(){

}