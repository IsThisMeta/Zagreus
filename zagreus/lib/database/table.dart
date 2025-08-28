import 'package:flutter/material.dart';

import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/deprecated.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/lidarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/nzbget.dart';
import 'package:zagreus/database/tables/radarr.dart';
import 'package:zagreus/database/tables/sabnzbd.dart';
import 'package:zagreus/database/tables/search.dart';
import 'package:zagreus/database/tables/sonarr.dart';
import 'package:zagreus/database/tables/tautulli.dart';
import 'package:zagreus/vendor.dart';

enum ZagTable<T extends ZagTableMixin> {
  bios<BIOSDatabase>('bios', items: BIOSDatabase.values),
  dashboard<DashboardDatabase>('home', items: DashboardDatabase.values),
  lidarr<LidarrDatabase>('lidarr', items: LidarrDatabase.values),
  zagreus<ZagreusDatabase>('zagreus', items: ZagreusDatabase.values),
  nzbget<NZBGetDatabase>('nzbget', items: NZBGetDatabase.values),
  radarr<RadarrDatabase>('radarr', items: RadarrDatabase.values),
  sabnzbd<SABnzbdDatabase>('sabnzbd', items: SABnzbdDatabase.values),
  search<SearchDatabase>('search', items: SearchDatabase.values),
  sonarr<SonarrDatabase>('sonarr', items: SonarrDatabase.values),
  tautulli<TautulliDatabase>('tautulli', items: TautulliDatabase.values);

  final String key;
  final List<T> items;

  const ZagTable(
    this.key, {
    required this.items,
  });

  static void register() {
    for (final table in ZagTable.values) table.items[0].register();
    registerDeprecatedAdapters();
  }

  T? _itemFromKey(String key) {
    for (final item in items) {
      if (item.key == key) return item;
    }
    return null;
  }

  Map<String, dynamic> export() {
    Map<String, dynamic> results = {};

    for (final item in this.items) {
      final value = item.export();
      if (value != null) results[item.key] = value;
    }

    return results;
  }

  void import(Map<String, dynamic>? table) {
    if (table == null || table.isEmpty) return;
    for (final key in table.keys) {
      final db = _itemFromKey(key);
      db?.import(table[key]);
    }
  }
}

mixin ZagTableMixin<T> on Enum {
  T get fallback;
  ZagTable get table;

  ZagBox get box => ZagBox.zagreus;
  String get key => '${table.key.toUpperCase()}_$name';

  T read() => box.read(key, fallback: fallback);
  void update(T value) => box.update(key, value);

  /// Default is an empty list and does not register any Hive adapters
  void register() {}

  /// The list of items that are not imported or exported by default
  List get blockedFromImportExport => [];

  @mustCallSuper
  dynamic export() {
    if (blockedFromImportExport.contains(this)) return null;
    return read();
  }

  @mustCallSuper
  void import(dynamic value) {
    if (blockedFromImportExport.contains(this) || value == null) return;
    return update(value as T);
  }

  Stream<BoxEvent> watch() {
    return box.watch(this.key);
  }

  ValueListenableBuilder listenableBuilder({
    required Widget Function(BuildContext, Widget?) builder,
    Key? key,
    Widget? child,
  }) {
    return box.listenableBuilder(
      key: key,
      selectItems: [this],
      builder: (context, widget) => builder(context, widget),
      child: child,
    );
  }
}
