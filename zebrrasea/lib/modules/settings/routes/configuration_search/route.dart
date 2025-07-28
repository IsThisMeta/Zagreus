import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/modules/search/core.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSearchRoute extends StatefulWidget {
  const ConfigurationSearchRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSearchRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'search.Search'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomNavigationBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'search.AddIndexer'.tr(),
          icon: Icons.add_rounded,
          onTap: SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER.go,
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraBox.indexers.listenableBuilder(
      builder: (context, _) => ZebrraListView(
        controller: scrollController,
        children: [
          ZebrraModule.SEARCH.informationBanner(),
          ..._indexerSection(),
          ..._customization(),
        ],
      ),
    );
  }

  List<Widget> _indexerSection() {
    if (ZebrraBox.indexers.isEmpty) {
      return [ZebrraMessage(text: 'search.NoIndexersFound'.tr())];
    }
    return _indexers;
  }

  List<Widget> get _indexers {
    List<ZebrraIndexer> indexers = ZebrraBox.indexers.data.toList();
    indexers.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    List<ZebrraBlock> list = List.generate(
      indexers.length,
      (index) =>
          _indexerTile(indexers[index], indexers[index].key) as ZebrraBlock,
    );
    return list;
  }

  Widget _indexerTile(ZebrraIndexer indexer, int index) {
    return ZebrraBlock(
      title: indexer.displayName,
      body: [TextSpan(text: indexer.host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER.go(
        params: {
          'id': index.toString(),
        },
      ),
    );
  }

  List<Widget> _customization() {
    return [
      ZebrraDivider(),
      _hideAdultCategories(),
      _showLinks(),
    ];
  }

  Widget _hideAdultCategories() {
    const _db = SearchDatabase.HIDE_XXX;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'search.HideAdultCategories'.tr(),
        body: [TextSpan(text: 'search.HideAdultCategoriesDescription'.tr())],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _showLinks() {
    const _db = SearchDatabase.SHOW_LINKS;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'search.ShowLinks'.tr(),
        body: [TextSpan(text: 'search.ShowLinksDescription'.tr())],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }
}
