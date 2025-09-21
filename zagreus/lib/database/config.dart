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

      // Debug: Check what's in the config for zagreus/lunasea table
      print('[DEBUG] Config import - table data:');
      print('[DEBUG] Available tables in backup: ${config.keys.toList()}');

      // Check both possible table names (lunasea from old backups, zagreus from new)
      final zagreusData = config['zagreus'] as Map<String, dynamic>?;
      final lunaseaData = config['lunasea'] as Map<String, dynamic>?;

      if (zagreusData != null) {
        print('[DEBUG] Found "zagreus" table');
        print('[DEBUG] DRAWER_AUTOMATIC_MANAGE in backup: ${zagreusData['DRAWER_AUTOMATIC_MANAGE']}');
        print('[DEBUG] DRAWER_MANUAL_ORDER in backup: ${zagreusData['DRAWER_MANUAL_ORDER']}');
      }
      if (lunaseaData != null) {
        print('[DEBUG] Found "lunasea" table with keys: ${lunaseaData.keys.toList()}');
        print('[DEBUG] DRAWER_AUTOMATIC_MANAGE in backup: ${lunaseaData['DRAWER_AUTOMATIC_MANAGE']}');
        print('[DEBUG] DRAWER_MANUAL_ORDER in backup: ${lunaseaData['DRAWER_MANUAL_ORDER']}');

        // Check with LUNASEA_ prefix too
        print('[DEBUG] LUNASEA_DRAWER_AUTOMATIC_MANAGE in backup: ${lunaseaData['LUNASEA_DRAWER_AUTOMATIC_MANAGE']}');
        print('[DEBUG] LUNASEA_DRAWER_MANUAL_ORDER in backup: ${lunaseaData['LUNASEA_DRAWER_MANUAL_ORDER']}');
      }

      _setProfiles(config[ZagBox.profiles.key]);
      _setIndexers(config[ZagBox.indexers.key]);
      _setExternalModules(config[ZagBox.externalModules.key]);
      for (final table in ZagTable.values) {
        print('[DEBUG] Importing table: ${table.key}');
        // Handle both new format (zagreus) and old format (lunasea)
        dynamic tableData = config[table.key];

        // Special handling for the main settings table - map lunasea -> zagreus
        if (table.key == 'zagreus' && tableData == null && config['lunasea'] != null) {
          print('[DEBUG] Mapping lunasea table to zagreus table');
          tableData = config['lunasea'];
        }

        table.import(tableData);
      }

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
