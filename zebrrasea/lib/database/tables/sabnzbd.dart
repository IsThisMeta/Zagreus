import 'package:zebrrasea/database/table.dart';

enum SABnzbdDatabase<T> with ZebrraTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  ZebrraTable get table => ZebrraTable.sabnzbd;

  @override
  final T fallback;

  const SABnzbdDatabase(this.fallback);
}
