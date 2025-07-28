import 'package:zebrrasea/database/box.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/database/table.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';
import 'package:zebrrasea/system/platform.dart';
import 'package:zebrrasea/vendor.dart';

class ZebrraDatabase {
  static const String _DATABASE_LEGACY_PATH = 'database';
  static const String _DATABASE_PATH = 'ZebrraSea/database';

  String get path {
    if (ZebrraPlatform.isWindows || ZebrraPlatform.isLinux) return _DATABASE_PATH;
    return _DATABASE_LEGACY_PATH;
  }

  Future<void> initialize() async {
    await Hive.initFlutter(path);
    ZebrraTable.register();
    await open();
  }

  Future<void> open() async {
    await ZebrraBox.open();
    if (ZebrraBox.profiles.isEmpty) await bootstrap();
  }

  Future<void> nuke() async {
    await Hive.close();

    for (final box in ZebrraBox.values) {
      await Hive.deleteBoxFromDisk(box.key, path: path);
    }

    if (ZebrraFileSystem.isSupported) {
      await ZebrraFileSystem().nuke();
    }
  }

  Future<void> bootstrap() async {
    const defaultProfile = ZebrraProfile.DEFAULT_PROFILE;
    await clear();

    ZebrraBox.profiles.update(defaultProfile, ZebrraProfile());
    ZebrraSeaDatabase.ENABLED_PROFILE.update(defaultProfile);
  }

  Future<void> clear() async {
    for (final box in ZebrraBox.values) await box.clear();
  }

  Future<void> deinitialize() async {
    await Hive.close();
  }
}
