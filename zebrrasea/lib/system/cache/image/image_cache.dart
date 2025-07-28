// ignore: always_use_package_imports
import 'platform/image_cache_stub.dart'
    if (dart.library.io) 'platform/image_cache_io.dart'
    if (dart.library.html) 'platform/image_cache_html.dart';

abstract class ZebrraImageCache {
  static const key = 'ZEBRRA_IMAGE_CACHE';
  static bool get isSupported => isPlatformSupported();
  factory ZebrraImageCache() => getImageCache();

  void initialize();
  Future<bool> clear();
  dynamic get instance;
}
