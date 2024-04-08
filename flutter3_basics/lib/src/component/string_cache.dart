part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/08
///

/// 全局字符串缓存
final GlobalStringCache globalString = GlobalStringCache._();

class GlobalStringCache {
  GlobalStringCache._();

  final StringCache cache = StringCache();
}

/// The cache for decoded SVGs.
class StringCache {
  final Map<Object, Future<String>> _pending = <Object, Future<String>>{};
  final Map<Object, String> _cache = <Object, String>{};

  /// Maximum number of entries to store in the cache.
  ///
  /// Once this many entries have been cached, the least-recently-used entry is
  /// evicted when adding a new entry.
  int get maximumSize => _maximumSize;
  int _maximumSize = 100;

  /// Changes the maximum cache size.
  ///
  /// If the new size is smaller than the current number of elements, the
  /// extraneous elements are evicted immediately. Setting this to zero and then
  /// returning it to its original value will therefore immediately clear the
  /// cache.
  set maximumSize(int value) {
    assert(value != null); // ignore: unnecessary_null_comparison
    assert(value >= 0);
    if (value == maximumSize) {
      return;
    }
    _maximumSize = value;
    if (maximumSize == 0) {
      clear();
    } else {
      while (_cache.length > maximumSize) {
        _cache.remove(_cache.keys.first);
      }
    }
  }

  /// Evicts all entries from the cache.
  ///
  /// This is useful if, for instance, the root asset bundle has been updated
  /// and therefore new images must be obtained.
  void clear() {
    _cache.clear();
  }

  /// Evicts a single entry from the cache, returning true if successful.
  bool evict(Object key) {
    return _cache.remove(key) != null;
  }

  /// Evicts a single entry from the cache if the `oldData` and `newData` are
  /// incompatible.
  ///
  /// For example, if the theme has changed the current color and the picture
  /// uses current color, [evict] will be called.
  bool maybeEvict(Object key, StringTheme oldData, StringTheme newData) {
    return evict(key);
  }

  /// Returns the previously cached [PictureStream] for the given key, if available;
  /// if not, calls the given callback to obtain it first. In either case, the
  /// key is moved to the "most recently used" position.
  ///
  /// The arguments must not be null. The `loader` cannot return null.
  Future<String> putIfAbsent(
    Object key,
    Future<String> Function() loader,
  ) {
    assert(key != null); // ignore: unnecessary_null_comparison
    assert(loader != null); // ignore: unnecessary_null_comparison
    Future<String>? pendingResult = _pending[key];
    if (pendingResult != null) {
      return pendingResult;
    }

    String? result = _cache[key];
    if (result != null) {
      // Remove the provider from the list so that we can put it back in below
      // and thus move it to the end of the list.
      _cache.remove(key);
    } else {
      pendingResult = loader();
      _pending[key] = pendingResult;
      pendingResult.then((String data) {
        _pending.remove(key);
        _add(key, data);
        result = data; // in case it was a synchronous future.
      });
    }
    if (result != null) {
      _add(key, result!);
      return SynchronousFuture<String>(result!);
    }
    assert(_cache.length <= maximumSize);
    return pendingResult!;
  }

  void _add(Object key, String result) {
    if (maximumSize > 0) {
      if (_cache.containsKey(key)) {
        _cache.remove(key); // update LRU.
      } else if (_cache.length == maximumSize && maximumSize > 0) {
        _cache.remove(_cache.keys.first);
      }
      assert(_cache.length < maximumSize);
      _cache[key] = result;
    }
    assert(_cache.length <= maximumSize);
  }

  /// The number of entries in the cache.
  int get count => _cache.length;
}

@immutable
class StringTheme {
  final dynamic data;

  const StringTheme({
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is StringTheme && data == other.data;
  }

  @override
  int get hashCode => Object.hash(data, null);

  @override
  String toString() => 'StringTheme(data: $data)';
}

@immutable
class StringCacheKey {
  /// See [SvgCacheKey].
  const StringCacheKey({
    required this.keyData,
    this.theme,
  });

  final StringTheme? theme;

  final Object keyData;

  @override
  int get hashCode => Object.hash(theme, keyData);

  @override
  bool operator ==(Object other) {
    return other is StringCacheKey &&
        other.theme == theme &&
        other.keyData == keyData;
  }
}

//region ---StringLoader---

@immutable
abstract class BaseStringLoader {
  /// Const constructor to allow subtypes to be const.
  const BaseStringLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<String> loadString(BuildContext? context);

  /// Create an object that can be used to uniquely identify this asset
  /// and loader combination.
  ///
  /// For most [BytesLoader] subclasses, this can safely return the same
  /// instance. If the loader looks up additional dependencies using the
  /// [context] argument of [loadString], then those objects should be
  /// incorporated into a new cache key.
  Object cacheKey(BuildContext? context) => this;
}

/// [SvgLoader]
abstract class StringLoader<T> extends BaseStringLoader {
  const StringLoader({this.theme});

  final StringTheme? theme;

  /// 根据[message]提供一个字符串
  @protected
  String provideString(T? message);

  /// 提前解析数据
  @protected
  Future<T?> prepareMessage(BuildContext? context) =>
      SynchronousFuture<T?>(null);

  Future<String> _load(BuildContext? context) {
    return prepareMessage(context).then((T? message) {
      return compute((T? message) {
        return provideString(message);
      }, message, debugLabel: 'Load Bytes');
    });
  }

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<String> loadString(BuildContext? context) {
    return globalString.cache
        .putIfAbsent(cacheKey(context), () => _load(context));
  }

  @override
  StringCacheKey cacheKey(BuildContext? context) {
    return StringCacheKey(keyData: this, theme: theme);
  }
}

/// [SvgBytesLoader]
/// [SvgStringLoader]
class MemoryStringLoader extends StringLoader<void> {
  const MemoryStringLoader(this._text, {super.theme});

  final String _text;

  @override
  String provideString(void message) {
    return _text;
  }

  @override
  int get hashCode => Object.hash(_text, theme);

  @override
  bool operator ==(Object other) {
    return other is MemoryStringLoader &&
        other._text == _text &&
        other.theme == theme;
  }
}

class FileStringLoader extends StringLoader<void> {
  /// See class doc.
  const FileStringLoader(this.file, {super.theme});

  /// The file containing the SVG data to decode and render.
  final File file;

  @override
  String provideString(void message) {
    final Uint8List bytes = file.readAsBytesSync();
    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  int get hashCode => Object.hash(file, theme);

  @override
  bool operator ==(Object other) {
    return other is FileStringLoader &&
        other.file == file &&
        other.theme == theme;
  }
}

class AssetStringLoader extends StringLoader<ByteData> {
  /// See class doc.
  const AssetStringLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
    super.theme,
  });

  /// The name of the asset, e.g. foo.svg.
  final String assetName;

  /// The package containing the asset.
  final String? packageName;

  /// The asset bundle to use, or [DefaultAssetBundle] if null.
  final AssetBundle? assetBundle;

  AssetBundle _resolveBundle(BuildContext? context) {
    if (assetBundle != null) {
      return assetBundle!;
    }
    if (context != null) {
      return DefaultAssetBundle.of(context);
    }
    return rootBundle;
  }

  @override
  Future<ByteData?> prepareMessage(BuildContext? context) {
    return _resolveBundle(context).load(
      packageName == null ? assetName : 'packages/$packageName/$assetName',
    );
  }

  @override
  String provideString(ByteData? message) =>
      utf8.decode(message!.buffer.asUint8List(), allowMalformed: true);

  @override
  StringCacheKey cacheKey(BuildContext? context) {
    return StringCacheKey(
      theme: theme,
      keyData: _AssetByteLoaderCacheKey(
        assetName,
        packageName,
        _resolveBundle(context),
      ),
    );
  }

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle, theme);

  @override
  bool operator ==(Object other) {
    return other is AssetStringLoader &&
        other.assetName == assetName &&
        other.packageName == packageName &&
        other.assetBundle == assetBundle &&
        other.theme == theme;
  }

  @override
  String toString() => 'AssetStringLoader($assetName)';
}

@immutable
class _AssetByteLoaderCacheKey {
  const _AssetByteLoaderCacheKey(
    this.assetName,
    this.packageName,
    this.assetBundle,
  );

  final String assetName;
  final String? packageName;

  final AssetBundle assetBundle;

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is _AssetByteLoaderCacheKey &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }

  @override
  String toString() =>
      'StringLoaderAsset(${packageName != null ? '$packageName/' : ''}$assetName)';
}

//endregion ---StringLoader---
