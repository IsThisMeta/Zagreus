import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class ConfigurationSearchEditIndexerHeadersRoute extends StatefulWidget {
  final int id;

  const ConfigurationSearchEditIndexerHeadersRoute({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigurationSearchEditIndexerHeadersRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchEditIndexerHeadersRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraIndexer? _indexer;

  @override
  Widget build(BuildContext context) {
    if (widget.id < 0 || !ZebrraBox.indexers.contains(widget.id)) {
      return InvalidRoutePage(
        title: 'settings.CustomHeaders'.tr(),
        message: 'search.IndexerNotFound'.tr(),
      );
    }

    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'settings.CustomHeaders'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'settings.AddHeader'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => HeaderUtility().addHeader(context,
              headers: _indexer!.headers, indexer: _indexer),
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
            if (_indexer!.headers.isEmpty)
              ZebrraMessage.inList(text: 'settings.NoHeadersAdded'.tr()),
            ..._list(),
          ],
        );
      },
    );
  }

  List<Widget> _list() {
    final headers = _indexer!.headers.cast<String, dynamic>();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZebrraBlock>((key) => _headerBlock(key, headers[key]))
        .toList();
  }

  ZebrraBlock _headerBlock(String key, String? value) {
    return ZebrraBlock(
      title: key.toString(),
      body: [TextSpan(text: value.toString())],
      trailing: ZebrraIconButton(
        icon: ZebrraIcons.DELETE,
        color: ZebrraColours.red,
        onPressed: () async => HeaderUtility().deleteHeader(
          context,
          headers: _indexer!.headers,
          key: key,
          indexer: _indexer,
        ),
      ),
    );
  }
}
