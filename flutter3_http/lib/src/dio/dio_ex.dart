part of flutter3_http;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

class DioScope extends InheritedWidget {
  final RDio rDio;

  const DioScope({
    super.key,
    required super.child,
    required this.rDio,
  });

  @override
  bool updateShouldNotify(DioScope oldWidget) => rDio != oldWidget.rDio;
}

extension DioEx on String {
  ///
  Future<Response<T>> get<T>() async {
    final response = await rDio.dio.get<T>(this);
    //debugger();
    return response;
  }
}
