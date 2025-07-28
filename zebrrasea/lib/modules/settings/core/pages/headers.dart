import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class SettingsHeaderRoute extends StatefulWidget {
  final ZebrraModule module;

  const SettingsHeaderRoute({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SettingsHeaderRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
            text: 'settings.AddHeader'.tr(),
            icon: Icons.add_rounded,
            onTap: () async {
              await HeaderUtility().addHeader(context, headers: _headers());
              _resetState();
            }),
      ],
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'settings.CustomHeaders'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraListView(
        controller: scrollController,
        children: [
          if ((_headers()).isEmpty) _noHeadersFound(),
          ..._headerList(),
        ],
      ),
    );
  }

  Widget _noHeadersFound() =>
      ZebrraMessage.inList(text: 'settings.NoHeadersAdded'.tr());

  List<ZebrraBlock> _headerList() {
    final headers = _headers();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZebrraBlock>((key) => _headerBlock(key, headers[key]))
        .toList();
  }

  ZebrraBlock _headerBlock(String key, String? value) {
    return ZebrraBlock(
      title: key,
      body: [TextSpan(text: value)],
      trailing: ZebrraIconButton(
          icon: ZebrraIcons.DELETE,
          color: ZebrraColours.red,
          onPressed: () async {
            await HeaderUtility().deleteHeader(
              context,
              key: key,
              headers: _headers(),
            );
            _resetState();
          }),
    );
  }

  Map<String, String> _headers() {
    switch (widget.module) {
      case ZebrraModule.DASHBOARD:
        throw Exception('Dashboard does not have a headers page');
      case ZebrraModule.EXTERNAL_MODULES:
        throw Exception('External modules do not have a headers page');
      case ZebrraModule.LIDARR:
        return ZebrraProfile.current.lidarrHeaders;
      case ZebrraModule.RADARR:
        return ZebrraProfile.current.radarrHeaders;
      case ZebrraModule.SONARR:
        return ZebrraProfile.current.sonarrHeaders;
      case ZebrraModule.SABNZBD:
        return ZebrraProfile.current.sabnzbdHeaders;
      case ZebrraModule.NZBGET:
        return ZebrraProfile.current.nzbgetHeaders;
      case ZebrraModule.SEARCH:
        throw Exception('Search does not have a headers page');
      case ZebrraModule.SETTINGS:
        throw Exception('Settings does not have a headers page');
      case ZebrraModule.WAKE_ON_LAN:
        throw Exception('Wake on LAN does not have a headers page');
      case ZebrraModule.OVERSEERR:
        throw Exception('Overseerr does not have a headers page');
      case ZebrraModule.TAUTULLI:
        return ZebrraProfile.current.tautulliHeaders;
    }
  }

  Future<void> _resetState() async {
    switch (widget.module) {
      case ZebrraModule.DASHBOARD:
        throw Exception('Dashboard does not have a global state');
      case ZebrraModule.EXTERNAL_MODULES:
        throw Exception('External modules do not have a global state');
      case ZebrraModule.LIDARR:
        return;
      case ZebrraModule.RADARR:
        return context.read<RadarrState>().reset();
      case ZebrraModule.SONARR:
        return context.read<SonarrState>().reset();
      case ZebrraModule.SABNZBD:
        return;
      case ZebrraModule.NZBGET:
        return;
      case ZebrraModule.SEARCH:
        throw Exception('Search does not have a global state');
      case ZebrraModule.SETTINGS:
        throw Exception('Settings does not have a global state');
      case ZebrraModule.WAKE_ON_LAN:
        throw Exception('Wake on LAN does not have a global state');
      case ZebrraModule.TAUTULLI:
        return context.read<TautulliState>().reset();
      case ZebrraModule.OVERSEERR:
        return;
    }
  }
}
