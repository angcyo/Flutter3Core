library flutter3_app;

import 'package:package_info_plus/package_info_plus.dart';

export 'package:flutter3_basics/flutter3_basics.dart';
export 'package:flutter3_core/flutter3_core.dart';
export 'package:flutter3_pub/flutter3_pub.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:package_info_plus/package_info_plus.dart';

///
/// ...
/// //Be sure to add this line if `PackageInfo.fromPlatform()` is called before runApp()
/// WidgetsFlutterBinding.ensureInitialized();
/// ...
/// String appName = packageInfo.appName;
/// String packageName = packageInfo.packageName;
/// String version = packageInfo.version;
/// String buildNumber = packageInfo.buildNumber;
Future<PackageInfo> get packageInfo async => await PackageInfo.fromPlatform();
