import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchRoute> createState() => _State();
}

class _State extends State<SearchRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      useDrawer: true,
      title: ZebrraModule.SEARCH.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _drawer() => ZebrraDrawer(page: ZebrraModule.SEARCH.key);

  Widget _body() {
    if (ZebrraBox.indexers.isEmpty) {
      return ZebrraMessage.moduleNotEnabled(
        context: context,
        module: ZebrraModule.SEARCH.title,
      );
    }
    return ZebrraListView(
      controller: scrollController,
      children: _list,
    );
  }

  List<Widget> get _list {
    final list = ZebrraBox.indexers.data
        .map((indexer) => SearchIndexerTile(indexer: indexer))
        .toList();
    list.sort((a, b) => a.indexer!.displayName
        .toLowerCase()
        .compareTo(b.indexer!.displayName.toLowerCase()));

    return list;
  }
}
