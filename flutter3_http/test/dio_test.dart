import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_http/flutter3_http.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/06
///

void main() {
  test('test dio', () async {
    const url = "http://www.baidu.com";
    final string = await url.dioGetString().then((value) {
      //print(value);
      consoleLog('请求成功:${value?.length.toSizeStr()}');
    });
    //consoleLog(string);
    consoleLog('...end');
    return true;
  });
}
