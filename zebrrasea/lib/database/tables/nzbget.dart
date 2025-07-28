import 'package:zebrrasea/database/table.dart';

enum NZBGetDatabase<T> with ZebrraTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  ZebrraTable get table => ZebrraTable.nzbget;

  @override
  final T fallback;

  const NZBGetDatabase(this.fallback);
}
