import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class LibrariesDetailsRoute extends StatefulWidget {
  final int? sectionId;

  const LibrariesDetailsRoute({
    Key? key,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<LibrariesDetailsRoute> createState() => _State();
}

class _State extends State<LibrariesDetailsRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZebrraPageController(
      initialPage: TautulliDatabase.NAVIGATION_INDEX_LIBRARIES_DETAILS.read(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sectionId == null) {
      return InvalidRoutePage(
        title: 'Library Details',
        message: 'Library Not Found',
      );
    }

    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: TautulliLibrariesDetailsNavigationBar(
        pageController: _pageController,
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'Library Details',
      scrollControllers:
          TautulliLibrariesDetailsNavigationBar.scrollControllers,
      pageController: _pageController,
    );
  }

  Widget _body() {
    return ZebrraPageView(
      controller: _pageController,
      children: [
        TautulliLibrariesDetailsInformation(sectionId: widget.sectionId!),
        TautulliLibrariesDetailsUserStats(sectionId: widget.sectionId!),
      ],
    );
  }
}
