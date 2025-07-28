import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSearchAddIndexerRoute extends StatefulWidget {
  const ConfigurationSearchAddIndexerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSearchAddIndexerRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchAddIndexerRoute>
    with ZebrraScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _indexer = ZebrraIndexer();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'search.AddIndexer'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'search.AddIndexer'.tr(),
          icon: Icons.add_rounded,
          onTap: () async {
            if (_indexer.displayName.isEmpty ||
                _indexer.host.isEmpty ||
                _indexer.apiKey.isEmpty) {
              showZebrraErrorSnackBar(
                title: 'search.FailedToAddIndexer'.tr(),
                message: 'settings.AllFieldsAreRequired'.tr(),
              );
            } else {
              ZebrraBox.indexers.create(_indexer);
              showZebrraSuccessSnackBar(
                title: 'search.IndexerAdded'.tr(),
                message: _indexer.displayName,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        _displayName(),
        _apiURL(),
        _apiKey(),
        _headers(),
      ],
    );
  }

  Widget _displayName() {
    String _name = _indexer.displayName;
    return ZebrraBlock(
      title: 'settings.DisplayName'.tr(),
      body: [TextSpan(text: _name.isEmpty ? 'zebrrasea.NotSet'.tr() : _name)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZebrraDialogs().editText(
          context,
          'settings.DisplayName'.tr(),
          prefill: _name,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.displayName = values.item2);
        }
      },
    );
  }

  Widget _apiURL() {
    String _host = _indexer.host;
    return ZebrraBlock(
      title: 'search.IndexerAPIHost'.tr(),
      body: [TextSpan(text: _host.isEmpty ? 'zebrrasea.NotSet'.tr() : _host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZebrraDialogs().editText(
          context,
          'search.IndexerAPIHost'.tr(),
          prefill: _host,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.host = values.item2);
        }
      },
    );
  }

  Widget _apiKey() {
    String _key = _indexer.apiKey;
    return ZebrraBlock(
      title: 'search.IndexerAPIKey'.tr(),
      body: [TextSpan(text: _key.isEmpty ? 'zebrrasea.NotSet'.tr() : _key)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZebrraDialogs().editText(
          context,
          'search.IndexerAPIKey'.tr(),
          prefill: _key,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.apiKey = values.item2);
        }
      },
    );
  }

  Widget _headers() {
    return ZebrraBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER_HEADERS.go(
        extra: _indexer,
      ),
    );
  }
}
