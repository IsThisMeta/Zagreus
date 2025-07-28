import 'package:flutter/material.dart';

import 'package:zebrrasea/database/box.dart';
import 'package:zebrrasea/database/models/deprecated.dart';
import 'package:zebrrasea/database/tables/bios.dart';
import 'package:zebrrasea/database/tables/dashboard.dart';
import 'package:zebrrasea/database/tables/lidarr.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/database/tables/nzbget.dart';
import 'package:zebrrasea/database/tables/radarr.dart';
import 'package:zebrrasea/database/tables/sabnzbd.dart';
import 'package:zebrrasea/database/tables/search.dart';
import 'package:zebrrasea/database/tables/sonarr.dart';
import 'package:zebrrasea/database/tables/tautulli.dart';
import 'package:zebrrasea/vendor.dart';

enum ZebrraTable<T extends ZebrraTableMixin> {
  bios<BIOSDatabase>('bios', items: BIOSDatabase.values),
  dashboard<DashboardDatabase>('home', items: DashboardDatabase.values),
  lidarr<LidarrDatabase>('lidarr', items: LidarrDatabase.values),
  zebrrasea<ZebrraSeaDatabase>('zebrrasea', items: ZebrraSeaDatabase.values),
  nzbget<NZBGetDatabase>('nzbget', items: NZBGetDatabase.values),
  radarr<RadarrDatabase>('radarr', items: RadarrDatabase.values),
  sabnzbd<SABnzbdDatabase>('sabnzbd', items: SABnzbdDatabase.values),
  search<SearchDatabase>('search', items: SearchDatabase.values),
  sonarr<SonarrDatabase>('sonarr', items: SonarrDatabase.values),
  tautulli<TautulliDatabase>('tautulli', items: TautulliDatabase.values);

  final String key;
  final List<T> items;

  const ZebrraTable(
    this.key, {
    required this.items,
  });

  static void register() {
    for (final table in ZebrraTable.values) table.items[0].register();
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

mixin ZebrraTableMixin<T> on Enum {
  T get fallback;
  ZebrraTable get table;

  ZebrraBox get box => ZebrraBox.zebrrasea;
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
