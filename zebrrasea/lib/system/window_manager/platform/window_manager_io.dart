import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zebrrasea/system/platform.dart';
import 'package:window_manager/window_manager.dart';

// ignore: always_use_package_imports
import '../window_manager.dart';

bool isPlatformSupported() => ZebrraPlatform.isDesktop;
ZebrraWindowManager getWindowManager() {
  switch (ZebrraPlatform.current) {
    case ZebrraPlatform.LINUX:
    case ZebrraPlatform.MACOS:
    case ZebrraPlatform.WINDOWS:
      return IO();
    default:
      throw UnsupportedError('ZebrraWindowManager unsupported');
  }
}

class IO implements ZebrraWindowManager {
  @override
  Future<void> initialize() async {
    if (kDebugMode) return;

    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await setWindowSize();
      await setWindowTitle('ZebrraSea');
      windowManager.show();
    });
  }

  @override
  Future<void> setWindowTitle(String title) async {
    return windowManager
        .waitUntilReadyToShow()
        .then((_) async => await windowManager.setTitle(title));
  }

  Future<void> setWindowSize() async {
    const min = ZebrraWindowManager.MINIMUM_WINDOW_SIZE;
    const init = ZebrraWindowManager.INITIAL_WINDOW_SIZE;
    const minSize = Size(min, min);
    const initSize = Size(init, init);

    await windowManager.setSize(initSize);
    // Currently broken on Linux
    if (!ZebrraPlatform.isLinux) {
      await windowManager.setMinimumSize(minSize);
    }
  }
}
