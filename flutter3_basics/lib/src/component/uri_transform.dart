part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/08
///
/// 用于转换http请求的url
/// 用于转换[AssetBundle]加载资源的key
abstract class UriTransform {
  /// 用于转换http请求的url
  static final List<TransformAction> _urlTransformAction = [];

  /// 用于转换[AssetBundle]加载资源的key
  static final List<TransformAction> _keyTransformAction = [];

  static TransformAction addUrlTransformAction(TransformAction action) {
    _urlTransformAction.add(action);
    return action;
  }

  static void removeUrlTransformAction(TransformAction action) {
    _urlTransformAction.remove(action);
  }

  /// 请求[url]移花接木
  static String transformUrl(String url) {
    String oldUrl = url;
    for (final action in _urlTransformAction) {
      url = action(url);
    }
    if (oldUrl != url) {
      l.w("UriTransform(url移花接木):$oldUrl->$url");
    }
    return url;
  }

  //--

  static TransformAction addKeyTransformAction(TransformAction action) {
    _keyTransformAction.add(action);
    return action;
  }

  static void removeKeyTransformAction(TransformAction action) {
    _keyTransformAction.remove(action);
  }

  /// 请求[key]偷梁换柱
  static String transformKey(String key) {
    String oldKey = key;
    for (final action in _keyTransformAction) {
      key = action(key);
    }
    if (oldKey != key) {
      l.w("UriTransform(key偷梁换柱):$oldKey->$key");
    }
    return key;
  }
}

typedef TransformAction = String Function(String uri);

extension UriTransformEx on String {
  /// [UriTransform]
  String transformUrl() => UriTransform.transformUrl(this);

  /// [UriTransform]
  String transformKey() => UriTransform.transformKey(this);

  //---

  /// 直接将[this]->[newUrl]
  TransformAction transformUrlTo(String newUrl) {
    return UriTransform.addUrlTransformAction((url) {
      if (this == url) {
        return newUrl;
      }
      return url;
    });
  }

  /// 直接将[this]->[newKey]
  TransformAction transformKeyTo(String newKey) {
    return UriTransform.addKeyTransformAction((key) {
      if (this == key) {
        return newKey;
      }
      return key;
    });
  }
}
