import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/modules/search.dart';

class SearchState extends ZebrraModuleState {
  @override
  void reset() {}

  NewznabAPI? _api;
  NewznabAPI get api => _api!;
  set api(NewznabAPI api) {
    _api = api;
  }

  late ZebrraIndexer _indexer;
  ZebrraIndexer get indexer => _indexer;
  set indexer(ZebrraIndexer indexer) {
    _indexer = indexer;
    api = NewznabAPI.fromIndexer(_indexer);
    notifyListeners();
  }

  Future<List<NewznabCategoryData>>? _categories;
  Future<List<NewznabCategoryData>>? get categories => _categories;
  void fetchCategories() {
    if (_api != null) _categories = _api!.getCategories();
    notifyListeners();
  }

  NewznabCategoryData? _activeCategory;
  NewznabCategoryData? get activeCategory => _activeCategory;
  set activeCategory(NewznabCategoryData? category) {
    _activeCategory = category;
    notifyListeners();
  }

  NewznabSubcategoryData? _activeSubcategory;
  NewznabSubcategoryData? get activeSubcategory => _activeSubcategory;
  set activeSubcategory(NewznabSubcategoryData? subcategory) {
    _activeSubcategory = subcategory;
    notifyListeners();
  }

  String? _searchQuery;
  String get searchQuery => _searchQuery!;
  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetQuery() => _searchQuery = null;
}
