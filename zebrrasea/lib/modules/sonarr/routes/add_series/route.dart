import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class AddSeriesRoute extends StatefulWidget {
  final String query;

  const AddSeriesRoute({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<AddSeriesRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SonarrAddSeriesState(
        context,
        widget.query,
      ),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(),
      ),
    );
  }

  Widget _appBar() {
    return SonarrSeriesAddAppBar(
      scrollController: scrollController,
      query: widget.query,
      autofocus: widget.query.isEmpty,
    );
  }

  Widget _body() {
    return SonarrAddSeriesSearchPage(scrollController: scrollController);
  }
}
