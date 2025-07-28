import 'package:flutter/material.dart';

import 'package:quick_actions/quick_actions.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/router/router.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/router/routes/settings.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';
import 'package:zebrrasea/modules/nzbget.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/modules/dashboard/core/state.dart';
import 'package:zebrrasea/api/wake_on_lan/wake_on_lan.dart';

part 'modules.g.dart';

const MODULE_DASHBOARD_KEY = 'dashboard';
const MODULE_EXTERNAL_MODULES_KEY = 'external_modules';
const MODULE_LIDARR_KEY = 'lidarr';
const MODULE_NZBGET_KEY = 'nzbget';
const MODULE_OVERSEERR_KEY = 'overseerr';
const MODULE_RADARR_KEY = 'radarr';
const MODULE_SABNZBD_KEY = 'sabnzbd';
const MODULE_SEARCH_KEY = 'search';
const MODULE_SETTINGS_KEY = 'settings';
const MODULE_SONARR_KEY = 'sonarr';
const MODULE_TAUTULLI_KEY = 'tautulli';
const MODULE_WAKE_ON_LAN_KEY = 'wake_on_lan';

@HiveType(typeId: 25, adapterName: 'ZebrraModuleAdapter')
enum ZebrraModule {
  @HiveField(0)
  DASHBOARD(MODULE_DASHBOARD_KEY),
  @HiveField(11)
  EXTERNAL_MODULES(MODULE_EXTERNAL_MODULES_KEY),
  @HiveField(1)
  LIDARR(MODULE_LIDARR_KEY),
  @HiveField(2)
  NZBGET(MODULE_NZBGET_KEY),
  @HiveField(3)
  OVERSEERR(MODULE_OVERSEERR_KEY),
  @HiveField(4)
  RADARR(MODULE_RADARR_KEY),
  @HiveField(5)
  SABNZBD(MODULE_SABNZBD_KEY),
  @HiveField(6)
  SEARCH(MODULE_SEARCH_KEY),
  @HiveField(7)
  SETTINGS(MODULE_SETTINGS_KEY),
  @HiveField(8)
  SONARR(MODULE_SONARR_KEY),
  @HiveField(9)
  TAUTULLI(MODULE_TAUTULLI_KEY),
  @HiveField(10)
  WAKE_ON_LAN(MODULE_WAKE_ON_LAN_KEY);

  final String key;
  const ZebrraModule(this.key);

  static ZebrraModule? fromKey(String? key) {
    switch (key) {
      case MODULE_DASHBOARD_KEY:
        return ZebrraModule.DASHBOARD;
      case MODULE_LIDARR_KEY:
        return ZebrraModule.LIDARR;
      case MODULE_NZBGET_KEY:
        return ZebrraModule.NZBGET;
      case MODULE_RADARR_KEY:
        return ZebrraModule.RADARR;
      case MODULE_SABNZBD_KEY:
        return ZebrraModule.SABNZBD;
      case MODULE_SEARCH_KEY:
        return ZebrraModule.SEARCH;
      case MODULE_SETTINGS_KEY:
        return ZebrraModule.SETTINGS;
      case MODULE_SONARR_KEY:
        return ZebrraModule.SONARR;
      case MODULE_OVERSEERR_KEY:
        return ZebrraModule.OVERSEERR;
      case MODULE_TAUTULLI_KEY:
        return ZebrraModule.TAUTULLI;
      case MODULE_WAKE_ON_LAN_KEY:
        return ZebrraModule.WAKE_ON_LAN;
      case MODULE_EXTERNAL_MODULES_KEY:
        return ZebrraModule.EXTERNAL_MODULES;
    }
    return null;
  }

  static List<ZebrraModule> get active {
    return ZebrraModule.values.filter((m) {
      if (m == ZebrraModule.DASHBOARD) return false;
      if (m == ZebrraModule.SETTINGS) return false;
      return m.featureFlag;
    }).toList();
  }
}

extension ZebrraModuleEnablementExtension on ZebrraModule {
  bool get featureFlag {
    switch (this) {
      case ZebrraModule.OVERSEERR:
        return false;
      case ZebrraModule.WAKE_ON_LAN:
        return ZebrraWakeOnLAN.isSupported;
      default:
        return true;
    }
  }

  bool get isEnabled {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return true;
      case ZebrraModule.SETTINGS:
        return true;
      case ZebrraModule.LIDARR:
        return ZebrraProfile.current.lidarrEnabled;
      case ZebrraModule.NZBGET:
        return ZebrraProfile.current.nzbgetEnabled;
      case ZebrraModule.OVERSEERR:
        return ZebrraProfile.current.overseerrEnabled;
      case ZebrraModule.RADARR:
        return ZebrraProfile.current.radarrEnabled;
      case ZebrraModule.SABNZBD:
        return ZebrraProfile.current.sabnzbdEnabled;
      case ZebrraModule.SEARCH:
        return !ZebrraBox.indexers.isEmpty;
      case ZebrraModule.SONARR:
        return ZebrraProfile.current.sonarrEnabled;
      case ZebrraModule.TAUTULLI:
        return ZebrraProfile.current.tautulliEnabled;
      case ZebrraModule.WAKE_ON_LAN:
        return ZebrraProfile.current.wakeOnLANEnabled;
      case ZebrraModule.EXTERNAL_MODULES:
        return !ZebrraBox.externalModules.isEmpty;
    }
  }
}

extension ZebrraModuleMetadataExtension on ZebrraModule {
  String get title {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return 'zebrrasea.Dashboard'.tr();
      case ZebrraModule.LIDARR:
        return 'Lidarr';
      case ZebrraModule.NZBGET:
        return 'NZBGet';
      case ZebrraModule.RADARR:
        return 'Radarr';
      case ZebrraModule.SABNZBD:
        return 'SABnzbd';
      case ZebrraModule.SEARCH:
        return 'search.Search'.tr();
      case ZebrraModule.SETTINGS:
        return 'zebrrasea.Settings'.tr();
      case ZebrraModule.SONARR:
        return 'Sonarr';
      case ZebrraModule.TAUTULLI:
        return 'Tautulli';
      case ZebrraModule.OVERSEERR:
        return 'Overseerr';
      case ZebrraModule.WAKE_ON_LAN:
        return 'Wake on LAN';
      case ZebrraModule.EXTERNAL_MODULES:
        return 'zebrrasea.ExternalModules'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return Icons.home_rounded;
      case ZebrraModule.LIDARR:
        return ZebrraIcons.LIDARR;
      case ZebrraModule.NZBGET:
        return ZebrraIcons.NZBGET;
      case ZebrraModule.RADARR:
        return ZebrraIcons.RADARR;
      case ZebrraModule.SABNZBD:
        return ZebrraIcons.SABNZBD;
      case ZebrraModule.SEARCH:
        return Icons.search_rounded;
      case ZebrraModule.SETTINGS:
        return Icons.settings_rounded;
      case ZebrraModule.SONARR:
        return ZebrraIcons.SONARR;
      case ZebrraModule.TAUTULLI:
        return ZebrraIcons.TAUTULLI;
      case ZebrraModule.OVERSEERR:
        return ZebrraIcons.OVERSEERR;
      case ZebrraModule.WAKE_ON_LAN:
        return Icons.settings_remote_rounded;
      case ZebrraModule.EXTERNAL_MODULES:
        return Icons.settings_ethernet_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return ZebrraColours.accent;
      case ZebrraModule.LIDARR:
        return const Color(0xFF159552);
      case ZebrraModule.NZBGET:
        return const Color(0xFF42D535);
      case ZebrraModule.RADARR:
        return const Color(0xFFFEC333);
      case ZebrraModule.SABNZBD:
        return const Color(0xFFFECC2B);
      case ZebrraModule.SEARCH:
        return ZebrraColours.accent;
      case ZebrraModule.SETTINGS:
        return ZebrraColours.accent;
      case ZebrraModule.SONARR:
        return const Color(0xFF3FC6F4);
      case ZebrraModule.TAUTULLI:
        return const Color(0xFFDBA23A);
      case ZebrraModule.OVERSEERR:
        return const Color(0xFF6366F1);
      case ZebrraModule.WAKE_ON_LAN:
        return ZebrraColours.accent;
      case ZebrraModule.EXTERNAL_MODULES:
        return ZebrraColours.accent;
    }
  }

  String? get website {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return null;
      case ZebrraModule.LIDARR:
        return 'https://lidarr.audio';
      case ZebrraModule.NZBGET:
        return 'https://nzbget.net';
      case ZebrraModule.RADARR:
        return 'https://radarr.video';
      case ZebrraModule.SABNZBD:
        return 'https://sabnzbd.org';
      case ZebrraModule.SEARCH:
        return null;
      case ZebrraModule.SETTINGS:
        return null;
      case ZebrraModule.SONARR:
        return 'https://sonarr.tv';
      case ZebrraModule.TAUTULLI:
        return 'https://tautulli.com';
      case ZebrraModule.OVERSEERR:
        return 'https://overseerr.dev';
      case ZebrraModule.WAKE_ON_LAN:
        return null;
      case ZebrraModule.EXTERNAL_MODULES:
        return null;
    }
  }

  String? get github {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return null;
      case ZebrraModule.LIDARR:
        return 'https://github.com/Lidarr/Lidarr';
      case ZebrraModule.NZBGET:
        return 'https://github.com/nzbget/nzbget';
      case ZebrraModule.RADARR:
        return 'https://github.com/Radarr/Radarr';
      case ZebrraModule.SABNZBD:
        return 'https://github.com/sabnzbd/sabnzbd';
      case ZebrraModule.SEARCH:
        return 'https://github.com/theotherp/nzbhydra2';
      case ZebrraModule.SETTINGS:
        return null;
      case ZebrraModule.SONARR:
        return 'https://github.com/Sonarr/Sonarr';
      case ZebrraModule.TAUTULLI:
        return 'https://github.com/Tautulli/Tautulli';
      case ZebrraModule.OVERSEERR:
        return 'https://github.com/sct/overseerr';
      case ZebrraModule.WAKE_ON_LAN:
        return null;
      case ZebrraModule.EXTERNAL_MODULES:
        return null;
    }
  }

  String get description {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return 'zebrrasea.Dashboard'.tr();
      case ZebrraModule.LIDARR:
        return 'Manage Music';
      case ZebrraModule.NZBGET:
        return 'Manage Usenet Downloads';
      case ZebrraModule.RADARR:
        return 'Manage Movies';
      case ZebrraModule.SABNZBD:
        return 'Manage Usenet Downloads';
      case ZebrraModule.SEARCH:
        return 'Search Newznab Indexers';
      case ZebrraModule.SETTINGS:
        return 'Configure ZebrraSea';
      case ZebrraModule.SONARR:
        return 'Manage Television Series';
      case ZebrraModule.TAUTULLI:
        return 'View Plex Activity';
      case ZebrraModule.OVERSEERR:
        return 'Manage Requests for New Content';
      case ZebrraModule.WAKE_ON_LAN:
        return 'Wake Your Machine';
      case ZebrraModule.EXTERNAL_MODULES:
        return 'Access External Modules';
    }
  }

  String? get information {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return null;
      case ZebrraModule.LIDARR:
        return 'Lidarr is a music collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new tracks from your favorite artists and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.';
      case ZebrraModule.NZBGET:
        return 'NZBGet is a binary downloader, which downloads files from Usenet based on information given in nzb-files.';
      case ZebrraModule.RADARR:
        return 'Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.';
      case ZebrraModule.SABNZBD:
        return 'SABnzbd is a multi-platform binary newsgroup downloader. The program works in the background and simplifies the downloading verifying and extracting of files from Usenet.';
      case ZebrraModule.SEARCH:
        return 'ZebrraSea currently supports all indexers that support the newznab protocol, including NZBHydra2.';
      case ZebrraModule.SETTINGS:
        return null;
      case ZebrraModule.SONARR:
        return 'Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.';
      case ZebrraModule.TAUTULLI:
        return 'Tautulli is an application that you can run alongside your Plex Media Server to monitor activity and track various statistics. Most importantly, these statistics include what has been watched, who watched it, when and where they watched it, and how it was watched.';
      case ZebrraModule.OVERSEERR:
        return 'Overseerr is a free and open source software application for managing requests for your media library. It integrates with your existing services, such as Sonarr, Radarr, and Plex!';
      case ZebrraModule.WAKE_ON_LAN:
        return 'Wake on LAN is an industry standard protocol for waking computers up from a very low power mode remotely by sending a specially constructed packet to the machine.';
      case ZebrraModule.EXTERNAL_MODULES:
        return 'ZebrraSea allows you to add links to additional modules that are not currently supported allowing you to open the module\'s web GUI without having to leave ZebrraSea!';
    }
  }
}

extension ZebrraModuleRoutingExtension on ZebrraModule {
  String? get homeRoute {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return ZebrraRoutes.dashboard.root.path;
      case ZebrraModule.LIDARR:
        return ZebrraRoutes.lidarr.root.path;
      case ZebrraModule.NZBGET:
        return ZebrraRoutes.nzbget.root.path;
      case ZebrraModule.RADARR:
        return ZebrraRoutes.radarr.root.path;
      case ZebrraModule.SABNZBD:
        return ZebrraRoutes.sabnzbd.root.path;
      case ZebrraModule.SEARCH:
        return ZebrraRoutes.search.root.path;
      case ZebrraModule.SETTINGS:
        return ZebrraRoutes.settings.root.path;
      case ZebrraModule.SONARR:
        return ZebrraRoutes.sonarr.root.path;
      case ZebrraModule.TAUTULLI:
        return ZebrraRoutes.tautulli.root.path;
      case ZebrraModule.OVERSEERR:
        return null;
      case ZebrraModule.WAKE_ON_LAN:
        return null;
      case ZebrraModule.EXTERNAL_MODULES:
        return ZebrraRoutes.externalModules.root.path;
    }
  }

  SettingsRoutes? get settingsRoute {
    switch (this) {
      case ZebrraModule.DASHBOARD:
        return SettingsRoutes.CONFIGURATION_DASHBOARD;
      case ZebrraModule.LIDARR:
        return SettingsRoutes.CONFIGURATION_LIDARR;
      case ZebrraModule.NZBGET:
        return SettingsRoutes.CONFIGURATION_NZBGET;
      case ZebrraModule.OVERSEERR:
        return null;
      case ZebrraModule.RADARR:
        return SettingsRoutes.CONFIGURATION_RADARR;
      case ZebrraModule.SABNZBD:
        return SettingsRoutes.CONFIGURATION_SABNZBD;
      case ZebrraModule.SEARCH:
        return SettingsRoutes.CONFIGURATION_SEARCH;
      case ZebrraModule.SETTINGS:
        return null;
      case ZebrraModule.SONARR:
        return SettingsRoutes.CONFIGURATION_SONARR;
      case ZebrraModule.TAUTULLI:
        return SettingsRoutes.CONFIGURATION_TAUTULLI;
      case ZebrraModule.WAKE_ON_LAN:
        return SettingsRoutes.CONFIGURATION_WAKE_ON_LAN;
      case ZebrraModule.EXTERNAL_MODULES:
        return SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES;
    }
  }

  Future<void> launch() async {
    if (homeRoute != null) {
      ZebrraRouter.router.pushReplacement(homeRoute!);
    }
  }
}

extension ZebrraModuleWebhookExtension on ZebrraModule {
  bool get hasWebhooks {
    switch (this) {
      case ZebrraModule.LIDARR:
        return true;
      case ZebrraModule.RADARR:
        return true;
      case ZebrraModule.SONARR:
        return true;
      case ZebrraModule.OVERSEERR:
        return true;
      case ZebrraModule.TAUTULLI:
        return true;
      default:
        return false;
    }
  }

  String? get webhookDocs {
    switch (this) {
      case ZebrraModule.LIDARR:
        return 'https://docs.zebrrasea.app/zebrrasea/notifications/lidarr';
      case ZebrraModule.RADARR:
        return 'https://docs.zebrrasea.app/zebrrasea/notifications/radarr';
      case ZebrraModule.SONARR:
        return 'https://docs.zebrrasea.app/zebrrasea/notifications/sonarr';
      case ZebrraModule.OVERSEERR:
        return 'https://docs.zebrrasea.app/zebrrasea/notifications/overseerr';
      case ZebrraModule.TAUTULLI:
        return 'https://docs.zebrrasea.app/zebrrasea/notifications/tautulli';
      default:
        return null;
    }
  }

  Future<void> handleWebhook(Map<String, dynamic> data) async {
    switch (this) {
      case ZebrraModule.LIDARR:
        return LidarrWebhooks().handle(data);
      case ZebrraModule.RADARR:
        return RadarrWebhooks().handle(data);
      case ZebrraModule.SONARR:
        return SonarrWebhooks().handle(data);
      case ZebrraModule.TAUTULLI:
        return TautulliWebhooks().handle(data);
      default:
        return;
    }
  }
}

extension ZebrraModuleExtension on ZebrraModule {
  ShortcutItem get shortcutItem {
    if (this == ZebrraModule.WAKE_ON_LAN) {
      throw Exception('WAKE_ON_LAN does not have a shortcut item');
    }
    return ShortcutItem(type: key, localizedTitle: title);
  }

  ZebrraModuleState? state(BuildContext context) {
    switch (this) {
      case ZebrraModule.WAKE_ON_LAN:
        return null;
      case ZebrraModule.DASHBOARD:
        return context.read<DashboardState>();
      case ZebrraModule.SETTINGS:
        return context.read<SettingsState>();
      case ZebrraModule.SEARCH:
        return context.read<SearchState>();
      case ZebrraModule.LIDARR:
        return context.read<LidarrState>();
      case ZebrraModule.RADARR:
        return context.read<RadarrState>();
      case ZebrraModule.SONARR:
        return context.read<SonarrState>();
      case ZebrraModule.NZBGET:
        return context.read<NZBGetState>();
      case ZebrraModule.SABNZBD:
        return context.read<SABnzbdState>();
      case ZebrraModule.OVERSEERR:
        return null;
      case ZebrraModule.TAUTULLI:
        return context.read<TautulliState>();
      case ZebrraModule.EXTERNAL_MODULES:
        return null;
    }
  }

  Widget informationBanner() {
    String key = 'ZEBRRASEA_MODULE_INFORMATION_${this.key}';
    void markSeen() => ZebrraBox.alerts.update(key, false);

    return ZebrraBox.alerts.listenableBuilder(
      selectKeys: [key],
      builder: (context, _) {
        if (ZebrraBox.alerts.read(key, fallback: true)) {
          return ZebrraBanner(
            dismissCallback: markSeen,
            headerText: this.title,
            bodyText: this.information,
            icon: this.icon,
            iconColor: this.color,
            buttons: [
              if (this.github != null)
                ZebrraButton.text(
                  text: 'GitHub',
                  icon: ZebrraIcons.GITHUB,
                  onTap: this.github!.openLink,
                ),
              if (this.website != null)
                ZebrraButton.text(
                  text: 'zebrrasea.Website'.tr(),
                  icon: Icons.home_rounded,
                  onTap: this.website!.openLink,
                ),
            ],
          );
        }
        return const SizedBox(height: 0.0, width: double.infinity);
      },
    );
  }
}
