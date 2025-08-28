import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/table.dart';

class ZagConfig {
  Future<void> import(BuildContext context, String data) async {
    await ZagDatabase().clear();

    try {
      Map<String, dynamic> config = json.decode(data);

      _setProfiles(config[ZagBox.profiles.key]);
      _setIndexers(config[ZagBox.indexers.key]);
      _setExternalModules(config[ZagBox.externalModules.key]);
      for (final table in ZagTable.values) table.import(config[table.key]);

      if (!ZagProfile.list.contains(ZagreusDatabase.ENABLED_PROFILE.read())) {
        ZagreusDatabase.ENABLED_PROFILE.update(ZagProfile.list[0]);
      }
    } catch (error, stack) {
      await ZagDatabase().bootstrap();
      ZagLogger().error(
        'Failed to import configuration, resetting to default',
        error,
        stack,
      );
    }

    ZagState.reset(context);
  }

  String export() {
    Map<String, dynamic> config = {};
    config[ZagBox.externalModules.key] = ZagBox.externalModules.export();
    config[ZagBox.indexers.key] = ZagBox.indexers.export();
    config[ZagBox.profiles.key] = ZagBox.profiles.export();
    for (final table in ZagTable.values) config[table.key] = table.export();

    return json.encode(config);
  }

  void _setProfiles(List? data) {
    if (data == null) return;

    for (final item in data) {
      final content = (item as Map).cast<String, dynamic>();
      final key = content['key'] ?? 'default';
      final obj = ZagProfile.fromJson(content);
      ZagBox.profiles.update(key, obj);
    }
  }

  void _setIndexers(List? data) {
    if (data == null) return;

    for (final indexer in data) {
      final obj = ZagIndexer.fromJson(indexer);
      ZagBox.indexers.create(obj);
    }
  }

  void _setExternalModules(List? data) {
    if (data == null) return;

    for (final module in data) {
      final obj = ZagExternalModule.fromJson(module);
      ZagBox.externalModules.create(obj);
    }
  }
}
