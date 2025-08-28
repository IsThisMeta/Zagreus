import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchRoute> createState() => _State();
}

class _State extends State<SearchRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      title: ZagModule.SEARCH.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.SEARCH.key);

  Widget _body() {
    if (ZagBox.indexers.isEmpty) {
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.SEARCH.title,
      );
    }
    return ZagListView(
      controller: scrollController,
      children: _list,
    );
  }

  List<Widget> get _list {
    final list = ZagBox.indexers.data
        .map((indexer) => SearchIndexerTile(indexer: indexer))
        .toList();
    list.sort((a, b) => a.indexer!.displayName
        .toLowerCase()
        .compareTo(b.indexer!.displayName.toLowerCase()));

    return list;
  }
}
