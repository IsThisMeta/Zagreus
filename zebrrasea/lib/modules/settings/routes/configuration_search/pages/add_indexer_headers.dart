import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/indexer.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class ConfigurationSearchAddIndexerHeadersRoute extends StatefulWidget {
  final ZebrraIndexer? indexer;

  const ConfigurationSearchAddIndexerHeadersRoute({
    Key? key,
    required this.indexer,
  }) : super(key: key);

  @override
  State<ConfigurationSearchAddIndexerHeadersRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchAddIndexerHeadersRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (widget.indexer == null) {
      return InvalidRoutePage(
        title: 'settings.CustomHeaders'.tr(),
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
          onTap: () async {
            await HeaderUtility()
                .addHeader(context, headers: widget.indexer!.headers);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        if (widget.indexer!.headers.isEmpty)
          ZebrraMessage.inList(text: 'settings.NoHeadersAdded'.tr()),
        ..._list(),
      ],
    );
  }

  List<Widget> _list() {
    final headers = widget.indexer!.headers.cast<String, dynamic>();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZebrraBlock>((key) => _headerTile(key, headers[key]))
        .toList();
  }

  ZebrraBlock _headerTile(String key, String? value) {
    return ZebrraBlock(
      title: key.toString(),
      body: [TextSpan(text: value.toString())],
      trailing: ZebrraIconButton(
        icon: ZebrraIcons.DELETE,
        color: ZebrraColours.red,
        onPressed: () async {
          await HeaderUtility().deleteHeader(
            context,
            headers: widget.indexer!.headers,
            key: key,
          );
          if (mounted) setState(() {});
        },
      ),
    );
  }
}
