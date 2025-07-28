import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class AddMovieRoute extends StatefulWidget {
  final String query;

  const AddMovieRoute({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<AddMovieRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late ZebrraPageController _pageController;
  bool hasQuery = false;

  @override
  void initState() {
    super.initState();

    final page = RadarrDatabase.NAVIGATION_INDEX_ADD_MOVIE.read();
    hasQuery = widget.query.isNotEmpty;
    _pageController = ZebrraPageController(initialPage: hasQuery ? 0 : page);
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _bottomNavigationBar() {
    return RadarrAddMovieNavigationBar(pageController: _pageController);
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'radarr.AddMovie'.tr(),
      pageController: _pageController,
      scrollControllers: RadarrAddMovieNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return ChangeNotifierProvider(
      create: (context) => RadarrAddMovieState(
        context,
        widget.query,
      ),
      builder: (context, _) => ZebrraPageView(
        controller: _pageController,
        children: [
          RadarrAddMovieSearchPage(
            autofocusSearchBar: hasQuery && _pageController.initialPage == 0,
          ),
          const RadarrAddMovieDiscoverPage(),
        ],
      ),
    );
  }
}
