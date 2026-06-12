import 'dart:io';

import 'package:path/path.dart' as p;

import '_script_common.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/12
///
/// 测试脚本
void main() async {
  final isccPath = await _findISCCPath();
  //print(isccPath);
  if (isccPath != null) {
    await runCommand(
      isccPath,
      args: [
        /*"/Qp",*/
        /*"/F\"TestOutputFileName\"",*/
        '/DMyAppVersion=2.0.0',
        r"E:\projects\flutter\LaserabcTools\apps\LaserabcFactoryTools\.inno_setup\Laserabc Factory Tools v1.0.0.iss",
      ],
    );
  }
}

/// 通过注册表查找本地安装的`ISCC.exe`的路径
Future<String?> _findISCCPath() async {
  for (final key in [
    r"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
    r"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
  ]) {
    final result = await runCommand(
      "reg",
      args: ["query", key],
      printLog: false,
    );
    if (result.exitCode != 0) {
      continue;
    }
    final output = result.stdout;
    if (output is String) {
      for (final line
          in output
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)) {
        //print("行->" + line);
        final subKey = line;
        final subOutput = await runCommand(
          "reg",
          args: ["query", subKey],
          printLog: false,
        );
        if (subOutput.exitCode != 0) {
          continue;
        }
        //print("subKey:" + subKey + " -> " + subOutput.stdout);
        final path = _findInnoSetupPath(subOutput.stdout);
        if (path != null) {
          final isccPath = p.join(path, 'ISCC.exe');
          if (File(isccPath).existsSync()) {
            return isccPath;
          }
        }
      }
    }
  }
  return null;
}

/// 查找`Inno Setup`的安装路径内
String? _findInnoSetupPath(String output) {
  // reg query 的输出格式通常为：
  //     (Default)    REG_SZ    C:\Program Files (x86)\Inno Setup 6\ISCC.exe
  // Inno Setup: App Path    REG_SZ    D:\Inno Setup 7
  final lines = output.split('\n');
  for (final line in lines) {
    if (line.contains("Inno Setup: App Path") && line.contains('REG_SZ')) {
      // 以 REG_SZ 作为切分点，取后面的部分并修剪空格
      final parts = line.split('REG_SZ');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
  }
  return null;
}
