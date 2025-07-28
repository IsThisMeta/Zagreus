import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/database.dart';
import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/database/table.dart';

class ZebrraConfig {
  Future<void> import(BuildContext context, String data) async {
    await ZebrraDatabase().clear();

    try {
      Map<String, dynamic> config = json.decode(data);

      _setProfiles(config[ZebrraBox.profiles.key]);
      _setIndexers(config[ZebrraBox.indexers.key]);
      _setExternalModules(config[ZebrraBox.externalModules.key]);
      for (final table in ZebrraTable.values) table.import(config[table.key]);

      if (!ZebrraProfile.list.contains(ZebrraSeaDatabase.ENABLED_PROFILE.read())) {
        ZebrraSeaDatabase.ENABLED_PROFILE.update(ZebrraProfile.list[0]);
      }
    } catch (error, stack) {
      await ZebrraDatabase().bootstrap();
      ZebrraLogger().error(
        'Failed to import configuration, resetting to default',
        error,
        stack,
      );
    }

    ZebrraState.reset(context);
  }

  String export() {
    Map<String, dynamic> config = {};
    config[ZebrraBox.externalModules.key] = ZebrraBox.externalModules.export();
    config[ZebrraBox.indexers.key] = ZebrraBox.indexers.export();
    config[ZebrraBox.profiles.key] = ZebrraBox.profiles.export();
    for (final table in ZebrraTable.values) config[table.key] = table.export();

    return json.encode(config);
  }

  void _setProfiles(List? data) {
    if (data == null) return;

    for (final item in data) {
      final content = (item as Map).cast<String, dynamic>();
      final key = content['key'] ?? 'default';
      final obj = ZebrraProfile.fromJson(content);
      ZebrraBox.profiles.update(key, obj);
    }
  }

  void _setIndexers(List? data) {
    if (data == null) return;

    for (final indexer in data) {
      final obj = ZebrraIndexer.fromJson(indexer);
      ZebrraBox.indexers.create(obj);
    }
  }

  void _setExternalModules(List? data) {
    if (data == null) return;

    for (final module in data) {
      final obj = ZebrraExternalModule.fromJson(module);
      ZebrraBox.externalModules.create(obj);
    }
  }
}
