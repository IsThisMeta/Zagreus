import 'package:zagreus/database/table.dart';

enum SearchDatabase<T> with ZagTableMixin<T> {
  HIDE_XXX<bool>(false),
  SHOW_LINKS<bool>(true);

  @override
  ZagTable get table => ZagTable.search;

  @override
  final T fallback;

  const SearchDatabase(this.fallback);
}
