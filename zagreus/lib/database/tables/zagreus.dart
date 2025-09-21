import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/models/log.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/types/indexer_icon.dart';
import 'package:zagreus/types/list_view_option.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/database/table.dart';
import 'package:zagreus/types/log_type.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

enum ZagreusDatabase<T> with ZagTableMixin<T> {
  ANDROID_BACK_OPENS_DRAWER<bool>(true),
  DRAWER_AUTOMATIC_MANAGE<bool>(true),
  DRAWER_MANUAL_ORDER<List>([]),
  ENABLED_PROFILE<String>(ZagProfile.DEFAULT_PROFILE),
  NETWORKING_TLS_VALIDATION<bool>(false),
  THEME_AMOLED<bool>(false),
  THEME_AMOLED_BORDER<bool>(false),
  THEME_LIGHT_BORDER<bool>(false),
  THEME_IMAGE_BACKGROUND_OPACITY<int>(20),
  THEME_MODE<String>('dark'),
  THEME_FOLLOW_SYSTEM<bool>(false),
  QUICK_ACTIONS_LIDARR<bool>(false),
  QUICK_ACTIONS_RADARR<bool>(false),
  QUICK_ACTIONS_SONARR<bool>(false),
  QUICK_ACTIONS_NZBGET<bool>(false),
  QUICK_ACTIONS_SABNZBD<bool>(false),
  QUICK_ACTIONS_OVERSEERR<bool>(false),
  QUICK_ACTIONS_TAUTULLI<bool>(false),
  QUICK_ACTIONS_SEARCH<bool>(false),
  USE_24_HOUR_TIME<bool>(false),
  ENABLE_IN_APP_NOTIFICATIONS<bool>(false),
  CHANGELOG_LAST_BUILD_VERSION<int>(0),
  ZAGREUS_PRO_ENABLED<bool>(false),
  ZAGREUS_PRO_EXPIRY<String>(''),
  ZAGREUS_PRO_SUBSCRIPTION_TYPE<String>(''),
  LAST_SUBSCRIPTION_VERIFY<String>(''),
  USER_BOOT_MODULE<String>('dashboard'),
  TESTFLIGHT_BYPASS_PRO<bool>(false);

  @override
  ZagTable get table => ZagTable.zagreus;

  @override
  final T fallback;

  const ZagreusDatabase(this.fallback);

  @override
  void register() {
    Hive.registerAdapter(ZagExternalModuleAdapter());
    Hive.registerAdapter(ZagIndexerAdapter());
    Hive.registerAdapter(ZagProfileAdapter());
    Hive.registerAdapter(ZagLogAdapter());
    Hive.registerAdapter(ZagIndexerIconAdapter());
    Hive.registerAdapter(ZagLogTypeAdapter());
    Hive.registerAdapter(ZagModuleAdapter());
    Hive.registerAdapter(ZagListViewOptionAdapter());
  }

  @override
  dynamic export() {
    ZagreusDatabase db = this;
    switch (db) {
      case ZagreusDatabase.DRAWER_MANUAL_ORDER:
        return ZagDrawer.moduleOrderedList()
            .map<String>((module) => module.key)
            .toList();
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    ZagreusDatabase db = this;
    dynamic result;

    switch (db) {
      case ZagreusDatabase.DRAWER_MANUAL_ORDER:
        print('[DEBUG] Importing DRAWER_MANUAL_ORDER: $value');
        List<ZagModule> item = [];
        (value as List).cast<String>().forEach((val) {
          ZagModule? module = ZagModule.fromKey(val);
          if (module != null) item.add(module);
        });
        result = item;
        print('[DEBUG] Converted to modules: ${item.map((m) => m.key).toList()}');
        break;
      case ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE:
        print('[DEBUG] Importing DRAWER_AUTOMATIC_MANAGE: $value');
        result = value;
        break;
      default:
        result = value;
        break;
    }

    print('[DEBUG] About to call super.import for ${db.name} with value: $result');
    return super.import(result);
  }
}
