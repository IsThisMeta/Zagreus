import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/router/routes/search.dart';
import 'package:zebrrasea/widgets/sheets/download_client/button.dart';

class ResultsRoute extends StatefulWidget {
  const ResultsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ResultsRoute> createState() => _State();
}

class _State extends State<ResultsRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final PagingController<int, NewznabResultData> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    NewznabCategoryData? category = context.read<SearchState>().activeCategory;
    NewznabSubcategoryData? subcategory =
        context.read<SearchState>().activeSubcategory;
    await context
        .read<SearchState>()
        .api
        .getResults(
          categoryId: subcategory?.id ?? category?.id,
          offset: pageKey,
        )
        .then((data) {
      if (data.isEmpty) return _pagingController.appendLastPage([]);
      return _pagingController.appendPage(data, pageKey + 1);
    }).catchError((error, stack) {
      ZebrraLogger().error(
        'Unable to fetch search results page: $pageKey',
        error,
        stack,
      );
      _pagingController.error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    String? title = 'search.Results'.tr();
    NewznabCategoryData? category = context.read<SearchState>().activeCategory;
    NewznabSubcategoryData? subcategory =
        context.read<SearchState>().activeSubcategory;
    if (category != null) title = category.name;
    if (category != null && subcategory != null) {
      title = '$title > ${subcategory.name ?? 'zebrrasea.Unknown'.tr()}';
    }
    return ZebrraAppBar(
      title: title!,
      actions: [
        const DownloadClientButton(),
        ZebrraIconButton(
          icon: Icons.search_rounded,
          onPressed: () => SearchRoutes.SEARCH.go(),
        ),
      ],
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraPagedListView<NewznabResultData>(
      refreshKey: _refreshKey,
      pagingController: _pagingController,
      scrollController: scrollController,
      listener: _fetchPage,
      noItemsFoundMessage: 'search.NoResultsFound'.tr(),
      itemBuilder: (context, result, index) => SearchResultTile(data: result),
    );
  }
}
