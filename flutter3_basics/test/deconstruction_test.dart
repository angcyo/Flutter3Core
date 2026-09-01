///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/01
///
/// 解构测试
void main() {
  final m1 = {"a": 1, "b": null};

  final m2 = {"a": null, "b": 2};
  
  final m3 = {"c": 3};

  print({...m1, ...m2, ...m3});

  print("...end");
}
