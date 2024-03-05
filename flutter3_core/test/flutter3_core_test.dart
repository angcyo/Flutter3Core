import 'dart:io';

import 'package:flutter3_core/flutter3_core.dart';

void main() async {
  /*test('adds one to input values', () {
    String hex = "0x2febff";
    hex.toColor();
  });*/
  /*print(currentDirPath);
  final result = await runCommand("git --version", []);
  print(result.stdout);
  final result2 = await runCommand("cmd --version", [], runInShell: false);
  print(result2.stdout);*/

  //final clone = await gitCloneOrRebase('git@github.com:angcyo/empty.git');
  //print(clone);

  print(Platform.operatingSystem);
  await printIps();
}

Future<bool> gitCloneOrRebase(String repo, {String? dir}) async {
  dir ??= currentDirPath;
  ProcessResult pr = await runCommand(
    "git",
    ['clone', repo],
    throwOnError: false,
    processWorkingDir: dir,
  );
  final error = "${pr.stderr}";
  if (error.contains('already exists')) {
    //提取文本'x'中的字符
    //使用正则提取字符串
    final path = dir.join(error.matchList(r"(?<=').+(?=')").first);
    pr = await runCommand(
      "git",
      ['rebase'],
      throwOnError: false,
      processWorkingDir: path,
    );
  }
  return pr.exitCode == 0;
}

Future<bool> isGitDir(Directory dir) async {
  assert(dir.existsSync());

// using rev-parse because it will fail in many scenarios
// including if the directory provided is a bare repository
  final pr = await runCommand(
    "git",
    ['rev-parse'],
    throwOnError: false,
    processWorkingDir: dir.path,
  );

  return pr.exitCode == 0;
}

/// 获取本机ip
/// == Interface: LetsTAP ==
/// 26.26.26.1  false [26, 26, 26, 1] IPv4
/// == Interface: 以太网 ==
/// 192.168.2.233  false [192, 168, 2, 233] IPv4
Future printIps() async {
  print(InternetAddress.anyIPv4);
  print(InternetAddress.anyIPv6);
  for (var interface in await NetworkInterface.list()) {
    print('== Interface: ${interface.name} ==');
    for (var addr in interface.addresses) {
      print(
          'address:${addr.address} host:${addr.host} rawAddress:${addr.rawAddress} type:${addr.type.name} '
          ':${addr.isLoopback} :${addr.isLinkLocal} :${addr.isMulticast}');
    }
  }
}
