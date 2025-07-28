import 'package:flutter/foundation.dart';

enum ZebrraPlatform {
  ANDROID,
  IOS,
  LINUX,
  MACOS,
  WEB,
  WINDOWS;

  static bool get isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static bool get isIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isLinux {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  }

  static bool get isMacOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get isWindows {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isLinux || isMacOS || isWindows;

  static ZebrraPlatform get current {
    if (isWeb) return ZebrraPlatform.WEB;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return ZebrraPlatform.ANDROID;
      case TargetPlatform.iOS:
        return ZebrraPlatform.IOS;
      case TargetPlatform.linux:
        return ZebrraPlatform.LINUX;
      case TargetPlatform.macOS:
        return ZebrraPlatform.MACOS;
      case TargetPlatform.windows:
        return ZebrraPlatform.WINDOWS;
      default:
        throw UnsupportedError('Platform is not supported');
    }
  }

  String get name {
    switch (this) {
      case ZebrraPlatform.ANDROID:
        return 'Android';
      case ZebrraPlatform.IOS:
        return 'iOS';
      case ZebrraPlatform.LINUX:
        return 'Linux';
      case ZebrraPlatform.MACOS:
        return 'macOS';
      case ZebrraPlatform.WEB:
        return 'Web';
      case ZebrraPlatform.WINDOWS:
        return 'Windows';
    }
  }
}
