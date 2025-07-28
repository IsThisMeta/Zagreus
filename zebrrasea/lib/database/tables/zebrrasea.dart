import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/database/models/log.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/types/indexer_icon.dart';
import 'package:zebrrasea/types/list_view_option.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/database/table.dart';
import 'package:zebrrasea/types/log_type.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

enum ZebrraSeaDatabase<T> with ZebrraTableMixin<T> {
  ANDROID_BACK_OPENS_DRAWER<bool>(true),
  DRAWER_AUTOMATIC_MANAGE<bool>(true),
  DRAWER_MANUAL_ORDER<List>([]),
  ENABLED_PROFILE<String>(ZebrraProfile.DEFAULT_PROFILE),
  NETWORKING_TLS_VALIDATION<bool>(false),
  THEME_AMOLED<bool>(false),
  THEME_AMOLED_BORDER<bool>(false),
  THEME_IMAGE_BACKGROUND_OPACITY<int>(20),
  QUICK_ACTIONS_LIDARR<bool>(false),
  QUICK_ACTIONS_RADARR<bool>(false),
  QUICK_ACTIONS_SONARR<bool>(false),
  QUICK_ACTIONS_NZBGET<bool>(false),
  QUICK_ACTIONS_SABNZBD<bool>(false),
  QUICK_ACTIONS_OVERSEERR<bool>(false),
  QUICK_ACTIONS_TAUTULLI<bool>(false),
  QUICK_ACTIONS_SEARCH<bool>(false),
  USE_24_HOUR_TIME<bool>(false),
  ENABLE_IN_APP_NOTIFICATIONS<bool>(true),
  CHANGELOG_LAST_BUILD_VERSION<int>(0);

  @override
  ZebrraTable get table => ZebrraTable.zebrrasea;

  @override
  final T fallback;

  const ZebrraSeaDatabase(this.fallback);

  @override
  void register() {
    Hive.registerAdapter(ZebrraExternalModuleAdapter());
    Hive.registerAdapter(ZebrraIndexerAdapter());
    Hive.registerAdapter(ZebrraProfileAdapter());
    Hive.registerAdapter(ZebrraLogAdapter());
    Hive.registerAdapter(ZebrraIndexerIconAdapter());
    Hive.registerAdapter(ZebrraLogTypeAdapter());
    Hive.registerAdapter(ZebrraModuleAdapter());
    Hive.registerAdapter(ZebrraListViewOptionAdapter());
  }

  @override
  dynamic export() {
    ZebrraSeaDatabase db = this;
    switch (db) {
      case ZebrraSeaDatabase.DRAWER_MANUAL_ORDER:
        return ZebrraDrawer.moduleOrderedList()
            .map<String>((module) => module.key)
            .toList();
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    ZebrraSeaDatabase db = this;
    dynamic result;

    switch (db) {
      case ZebrraSeaDatabase.DRAWER_MANUAL_ORDER:
        List<ZebrraModule> item = [];
        (value as List).cast<String>().forEach((val) {
          ZebrraModule? module = ZebrraModule.fromKey(val);
          if (module != null) item.add(module);
        });
        result = item;
        break;
      default:
        result = value;
        break;
    }

    return super.import(result);
  }
}
