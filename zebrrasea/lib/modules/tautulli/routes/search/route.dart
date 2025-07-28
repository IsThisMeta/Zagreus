import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

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
  Widget build(BuildContext context) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        module: ZebrraModule.TAUTULLI,
        appBar: TautulliSearchAppBar(scrollController: scrollController)
            as PreferredSizeWidget?,
        body: TautulliSearchSearchResults(scrollController: scrollController),
      );
}
