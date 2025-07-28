import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/routes/lidarr.dart';

class LidarrRoute extends StatefulWidget {
  const LidarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<LidarrRoute> createState() => _State();
}

class _State extends State<LidarrRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;
  String _profileState = ZebrraProfile.current.toString();
  LidarrAPI _api = LidarrAPI.from(ZebrraProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        ZebrraPageController(initialPage: LidarrDatabase.NAVIGATION_INDEX.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      onProfileChange: (_) {
        if (_profileState != ZebrraProfile.current.toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => ZebrraDrawer(page: ZebrraModule.LIDARR.key);

  Widget? _bottomNavigationBar() {
    if (ZebrraProfile.current.lidarrEnabled)
      return LidarrNavigationBar(pageController: _pageController);
    return null;
  }

  Widget _body() {
    if (!ZebrraProfile.current.lidarrEnabled)
      return ZebrraMessage.moduleNotEnabled(
        context: context,
        module: ZebrraModule.LIDARR.title,
      );
    return ZebrraPageView(
      controller: _pageController,
      children: [
        LidarrCatalogue(
          refreshIndicatorKey: _refreshKeys[0],
          refreshAllPages: _refreshAllPages,
        ),
        LidarrMissing(
          refreshIndicatorKey: _refreshKeys[1],
          refreshAllPages: _refreshAllPages,
        ),
        LidarrHistory(
          refreshIndicatorKey: _refreshKeys[2],
          refreshAllPages: _refreshAllPages,
        ),
      ],
    );
  }

  Widget _appBar() {
    const db = ZebrraBox.profiles;
    final profiles = db.keys.fold<List<String>>([], (arr, key) {
      if (ZebrraBox.profiles.read(key)?.lidarrEnabled ?? false) arr.add(key);
      return arr;
    });
    List<Widget>? actions;
    if (ZebrraProfile.current.lidarrEnabled)
      actions = [
        ZebrraIconButton(
          icon: Icons.add_rounded,
          onPressed: () async => _enterAddArtist(),
        ),
        ZebrraIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZebrraAppBar.dropdown(
      title: ZebrraModule.LIDARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: LidarrNavigationBar.scrollControllers,
    );
  }

  Future<void> _enterAddArtist() async {
    final _model = Provider.of<LidarrState>(context, listen: false);
    _model.addSearchQuery = '';
    LidarrRoutes.ADD_ARTIST.go();
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await LidarrDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZebrraProfile profile = ZebrraProfile.current;
          await profile.lidarrHost.openLink();
          break;
        case 'update_library':
          await _api
              .updateLibrary()
              .then((_) => showZebrraSuccessSnackBar(
                  title: 'Updating Library...',
                  message: 'Updating your library in the background'))
              .catchError((error) => showZebrraErrorSnackBar(
                  title: 'Failed to Update Library', error: error));
          break;
        case 'rss_sync':
          await _api
              .triggerRssSync()
              .then((_) => showZebrraSuccessSnackBar(
                  title: 'Running RSS Sync...',
                  message: 'Running RSS sync in the background'))
              .catchError((error) => showZebrraErrorSnackBar(
                  title: 'Failed to Run RSS Sync', error: error));
          break;
        case 'backup':
          await _api
              .triggerBackup()
              .then((_) => showZebrraSuccessSnackBar(
                  title: 'Backing Up Database...',
                  message: 'Backing up database in the background'))
              .catchError((error) => showZebrraErrorSnackBar(
                  title: 'Failed to Backup Database', error: error));
          break;
        case 'missing_search':
          {
            List<dynamic> values =
                await LidarrDialogs.searchAllMissing(context);
            if (values[0])
              await _api
                  .searchAllMissing()
                  .then((_) => showZebrraSuccessSnackBar(
                      title: 'Searching...',
                      message: 'Search for all missing albums'))
                  .catchError((error) => showZebrraErrorSnackBar(
                      title: 'Failed to Search', error: error));
            break;
          }
        default:
          ZebrraLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  void _refreshProfile() {
    _api = LidarrAPI.from(ZebrraProfile.current);
    _profileState = ZebrraProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
