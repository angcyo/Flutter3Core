///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///
/// https://dev.to/schultek/useless-tips-for-dart-you-probably-never-need-part-1-4kg1
/// - [Symbol]
/// - [Never]
/// - [Function]
///   - [Function.apply]
///   - [Function.call] 所有函数都默认拥有 call 方法。
/// ```
/// // instead of
/// foo(1, 2, 3, f: 4, g: 5)
/// // do this
/// Function.apply(foo, [1, 2, 3], {#f: 4, #g: 5});
/// ```
void main() {
  //MARK: symbol
  final symbol = #abc;
  print(symbol.runtimeType.toString()); // Symbol
  print(#abc == symbol); // true
  print(#abc == "abc"); // false
  //print(symbol. == "abc"); // false
  print(#abc.name); // false

  //MARK: never

  //MARK: function
  //Function.apply()

  //MARK: void

  var myString = "Hello World";
  void myVoidVr = myString;
  // what to do with myVoidVar?
  //print(myVoidVr); // Error: This expression has type 'void' and can't be used.

  print("...symbol");
}
