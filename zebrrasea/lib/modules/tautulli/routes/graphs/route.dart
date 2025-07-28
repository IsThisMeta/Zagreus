import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class GraphsRoute extends StatefulWidget {
  const GraphsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<GraphsRoute> createState() => _State();
}

class _State extends State<GraphsRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZebrraPageController(
        initialPage: TautulliDatabase.NAVIGATION_INDEX_GRAPHS.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      pageController: _pageController,
      scrollControllers: TautulliGraphsNavigationBar.scrollControllers,
      title: 'Graphs',
      actions: const [
        TautulliGraphsTypeButton(),
      ],
    );
  }

  Widget _bottomNavigationBar() {
    return TautulliGraphsNavigationBar(pageController: _pageController);
  }

  Widget _body() {
    return ZebrraPageView(
      controller: _pageController,
      children: const [
        TautulliGraphsPlayByPeriodRoute(),
        TautulliGraphsStreamInformationRoute(),
      ],
    );
  }
}
