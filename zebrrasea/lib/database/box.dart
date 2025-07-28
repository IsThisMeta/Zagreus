import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/database/models/log.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/database/table.dart';
import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/vendor.dart';

enum ZebrraBox<T> {
  alerts<dynamic>('alerts'),
  externalModules<ZebrraExternalModule>('external_modules'),
  indexers<ZebrraIndexer>('indexers'),
  logs<ZebrraLog>('logs'),
  zebrrasea<dynamic>('zebrrasea'),
  profiles<ZebrraProfile>('profiles');

  final String key;
  const ZebrraBox(this.key);

  Box<T> get _instance => Hive.box<T>(key);

  Iterable<dynamic> get keys => _instance.keys;
  Iterable<T> get data => _instance.values;

  int get size => _instance.length;
  bool get isEmpty => _instance.isEmpty;

  static Future<void> open() async {
    for (final box in ZebrraBox.values) await box._open();
  }

  T? read(dynamic key, {T? fallback}) {
    return _instance.get(key, defaultValue: fallback);
  }

  T? readAt(int index) {
    return _instance.getAt(index);
  }

  bool contains(dynamic key) {
    return _instance.containsKey(key);
  }

  Future<int> create(T value) async {
    return _instance.add(value);
  }

  Future<void> update(dynamic key, T value) {
    return _instance.put(key, value);
  }

  Future<void> delete(dynamic key) async {
    return _instance.delete(key);
  }

  Future<void> clear() async {
    _instance.keys.forEach((k) async => await _instance.delete(k));
  }

  Future<Box<T>> _open() async {
    return Hive.openBox<T>(key);
  }

  Stream<BoxEvent> watch([dynamic key]) {
    return _instance.watch(key: key);
  }

  ValueListenable<Box<T>> listenable([List<dynamic>? keys]) {
    return _instance.listenable(keys: keys);
  }

  ValueListenableBuilder listenableBuilder({
    required Widget Function(BuildContext, Widget?) builder,
    List<dynamic>? selectKeys,
    List<ZebrraTableMixin>? selectItems,
    Key? key,
    Widget? child,
  }) {
    final items = selectItems?.map((item) => item.key).toList();
    final keys = [...?selectKeys, ...?items];

    return ValueListenableBuilder(
      key: key,
      valueListenable: listenable(keys.isNotEmpty ? keys : null),
      builder: (context, _, widget) => builder(context, widget),
      child: child,
    );
  }
}

extension ZebrraBoxExtension on ZebrraBox {
  /// This only works for boxes that are typed specifically for a hive object
  /// Should be improved to actually support every box.
  List<Map<String, dynamic>> export() {
    try {
      return _instance.keys
          .map<Map<String, dynamic>>((k) => _instance.get(k)!.toJson())
          .toList();
    } catch (error, stack) {
      ZebrraLogger().error('Failed to export ZebrraBox', error, stack);
      return [];
    }
  }
}
