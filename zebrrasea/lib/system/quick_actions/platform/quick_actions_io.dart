import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/system/platform.dart';

// ignore: always_use_package_imports
import '../quick_actions.dart';

bool isPlatformSupported() => ZebrraPlatform.isMobile;
ZebrraQuickActions getQuickActions() {
  if (isPlatformSupported()) return IO();
  throw UnsupportedError('ZebrraQuickActions unsupported');
}

class IO implements ZebrraQuickActions {
  final QuickActions _quickActions = const QuickActions();

  @override
  Future<void> initialize() async {
    _quickActions.initialize(actionHandler);
    setActionItems();
  }

  @override
  void actionHandler(String action) {
    ZebrraModule.fromKey(action)?.launch();
  }

  @override
  void setActionItems() {
    _quickActions.setShortcutItems(<ShortcutItem>[
      if (ZebrraSeaDatabase.QUICK_ACTIONS_TAUTULLI.read())
        ZebrraModule.TAUTULLI.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_SONARR.read())
        ZebrraModule.SONARR.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_SEARCH.read())
        ZebrraModule.SEARCH.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_SABNZBD.read())
        ZebrraModule.SABNZBD.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_RADARR.read())
        ZebrraModule.RADARR.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_OVERSEERR.read())
        ZebrraModule.OVERSEERR.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_NZBGET.read())
        ZebrraModule.NZBGET.shortcutItem,
      if (ZebrraSeaDatabase.QUICK_ACTIONS_LIDARR.read())
        ZebrraModule.LIDARR.shortcutItem,
      ZebrraModule.SETTINGS.shortcutItem,
    ]);
  }
}
