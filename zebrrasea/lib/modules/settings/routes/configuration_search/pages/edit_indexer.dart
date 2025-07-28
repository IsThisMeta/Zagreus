import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSearchEditIndexerRoute extends StatefulWidget {
  final int id;

  const ConfigurationSearchEditIndexerRoute({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigurationSearchEditIndexerRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchEditIndexerRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraIndexer? _indexer;

  @override
  Widget build(BuildContext context) {
    if (widget.id < 0 || !ZebrraBox.indexers.contains(widget.id)) {
      return InvalidRoutePage(
        title: 'search.EditIndexer'.tr(),
        message: 'search.IndexerNotFound'.tr(),
      );
    }

    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'search.EditIndexer'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'search.DeleteIndexer'.tr(),
          icon: Icons.delete_rounded,
          color: ZebrraColours.red,
          onTap: () async {
            bool result = await SettingsDialogs().deleteIndexer(context);
            if (result) {
              showZebrraSuccessSnackBar(
                title: 'search.IndexerDeleted'.tr(),
                message: _indexer!.displayName,
              );
              _indexer!.delete();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraBox.indexers.listenableBuilder(
      selectKeys: [widget.id],
      builder: (context, _) {
        if (!ZebrraBox.indexers.contains(widget.id)) return Container();
        _indexer = ZebrraBox.indexers.read(widget.id);
        return ZebrraListView(
          controller: scrollController,
          children: [
            _displayName(),
            _apiURL(),
            _apiKey(),
            _headers(),
          ],
        );
      },
    );
  }

  Widget _displayName() {
    String _name = _indexer!.displayName;
    return ZebrraBlock(
      title: 'settings.DisplayName'.tr(),
      body: [TextSpan(text: _name.isEmpty ? 'zebrrasea.NotSet'.tr() : _name)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZebrraDialogs().editText(
          context,
          'settings.DisplayName'.tr(),
          prefill: _indexer!.displayName,
        );
        if (values.item1) {
          _indexer!.displayName = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _apiURL() {
    String _host = _indexer!.host;
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
          _indexer!.host = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _apiKey() {
    String _key = _indexer!.apiKey;
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
        if (values.item1) {
          _indexer!.apiKey = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _headers() {
    return ZebrraBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER_HEADERS.go(
        params: {
          'id': widget.id.toString(),
        },
      ),
    );
  }
}
