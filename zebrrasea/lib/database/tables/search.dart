import 'package:zebrrasea/database/table.dart';

enum SearchDatabase<T> with ZebrraTableMixin<T> {
  HIDE_XXX<bool>(false),
  SHOW_LINKS<bool>(true);

  @override
  ZebrraTable get table => ZebrraTable.search;

  @override
  final T fallback;

  const SearchDatabase(this.fallback);
}
