import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/tables/nzbget.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/nzbget.dart';
import 'package:zebrrasea/router/routes/nzbget.dart';

import 'package:zebrrasea/system/filesystem/file.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';

class NZBGetRoute extends StatefulWidget {
  final bool showDrawer;

  const NZBGetRoute({
    Key? key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<NZBGetRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;
  String _profileState = ZebrraProfile.current.toString();
  NZBGetAPI _api = NZBGetAPI.from(ZebrraProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        ZebrraPageController(initialPage: NZBGetDatabase.NAVIGATION_INDEX.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      drawer: widget.showDrawer ? _drawer() : null,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      extendBodyBehindAppBar: false,
      extendBody: false,
      onProfileChange: (_) {
        if (_profileState != ZebrraProfile.current.toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => ZebrraDrawer(page: ZebrraModule.NZBGET.key);

  Widget? _bottomNavigationBar() {
    if (ZebrraProfile.current.nzbgetEnabled) {
      return NZBGetNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZebrraBox.profiles.keys.fold([], (value, element) {
      if (ZebrraBox.profiles.read(element)?.nzbgetEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (ZebrraProfile.current.nzbgetEnabled)
      actions = [
        Selector<NZBGetState, bool>(
          selector: (_, model) => model.error,
          builder: (context, error, widget) =>
              error ? Container() : const NZBGetAppBarStats(),
        ),
        ZebrraIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZebrraAppBar.dropdown(
      title: ZebrraModule.NZBGET.title,
      useDrawer: widget.showDrawer,
      hideLeading: !widget.showDrawer,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: NZBGetNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    if (!ZebrraProfile.current.nzbgetEnabled)
      return ZebrraMessage.moduleNotEnabled(
        context: context,
        module: ZebrraModule.NZBGET.title,
      );
    return ZebrraPageView(
      controller: _pageController,
      children: [
        NZBGetQueue(
          refreshIndicatorKey: _refreshKeys[0],
        ),
        NZBGetHistory(
          refreshIndicatorKey: _refreshKeys[1],
        ),
      ],
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await NZBGetDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZebrraProfile profile = ZebrraProfile.current;
          await profile.nzbgetHost.openLink();
          break;
        case 'add_nzb':
          _addNZB();
          break;
        case 'sort':
          _sort();
          break;
        case 'server_details':
          _serverDetails();
          break;
        default:
          ZebrraLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addNZB() async {
    List values = await NZBGetDialogs.addNZB(context);
    if (values[0])
      switch (values[1]) {
        case 'link':
          _addByURL();
          break;
        case 'file':
          _addByFile();
          break;
        default:
          ZebrraLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addByURL() async {
    List values = await NZBGetDialogs.addNZBUrl(context);
    if (values[0])
      await _api
          .uploadURL(values[1])
          .then((_) => showZebrraSuccessSnackBar(
              title: 'Uploaded NZB (URL)', message: values[1]))
          .catchError((error) => showZebrraErrorSnackBar(
              title: 'Failed to Upload NZB', error: error));
  }

  Future<void> _addByFile() async {
    try {
      ZebrraFile? _file = await ZebrraFileSystem().read(context, [
        'nzb',
      ]);
      if (_file != null) {
        if (_file.data.isNotEmpty) {
          await _api.uploadFile(_file.data, _file.name).then((value) {
            _refreshKeys[0]?.currentState?.show();
            showZebrraSuccessSnackBar(
              title: 'Uploaded NZB (File)',
              message: _file.name,
            );
          });
        } else {
          showZebrraErrorSnackBar(
            title: 'Failed to Upload NZB',
            message: 'Please select a valid file',
          );
        }
      }
    } catch (error, stack) {
      ZebrraLogger().error('Failed to add NZB by file', error, stack);
      showZebrraErrorSnackBar(
        title: 'Failed to Upload NZB',
        error: error,
      );
    }
  }

  Future<void> _sort() async {
    List values = await NZBGetDialogs.sortQueue(context);
    if (values[0])
      await _api.sortQueue(values[1]).then((_) {
        _refreshKeys[0]?.currentState?.show();
        showZebrraSuccessSnackBar(
            title: 'Sorted Queue', message: (values[1] as NZBGetSort?).name);
      }).catchError((error) {
        showZebrraErrorSnackBar(title: 'Failed to Sort Queue', error: error);
      });
  }

  Future<void> _serverDetails() async => NZBGetRoutes.STATISTICS.go();

  void _refreshProfile() {
    _api = NZBGetAPI.from(ZebrraProfile.current);
    _profileState = ZebrraProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
