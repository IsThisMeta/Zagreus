import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/router/routes/tautulli.dart';

class LogsRoute extends StatefulWidget {
  const LogsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LogsRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'Logs',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraBlock(
          title: 'Logins',
          body: const [TextSpan(text: 'Tautulli Login Logs')],
          trailing: ZebrraIconButton(
            icon: Icons.vpn_key_rounded,
            color: ZebrraColours().byListIndex(0),
          ),
          onTap: TautulliRoutes.LOGS_LOGINS.go,
        ),
        ZebrraBlock(
          title: 'Newsletters',
          body: const [TextSpan(text: 'Tautulli Newsletter Logs')],
          trailing: ZebrraIconButton(
            icon: Icons.email_rounded,
            color: ZebrraColours().byListIndex(1),
          ),
          onTap: TautulliRoutes.LOGS_NEWSLETTERS.go,
        ),
        ZebrraBlock(
          title: 'Notifications',
          body: const [TextSpan(text: 'Tautulli Notification Logs')],
          trailing: ZebrraIconButton(
            icon: Icons.notifications_rounded,
            color: ZebrraColours().byListIndex(2),
          ),
          onTap: TautulliRoutes.LOGS_NOTIFICATIONS.go,
        ),
        ZebrraBlock(
          title: 'Plex Media Scanner',
          body: const [TextSpan(text: 'Plex Media Scanner Logs')],
          trailing: ZebrraIconButton(
            icon: Icons.scanner_rounded,
            color: ZebrraColours().byListIndex(3),
          ),
          onTap: TautulliRoutes.LOGS_PLEX_MEDIA_SCANNER.go,
        ),
        ZebrraBlock(
          title: 'Plex Media Server',
          body: const [TextSpan(text: 'Plex Media Server Logs')],
          trailing: ZebrraIconButton(
            icon: ZebrraIcons.PLEX,
            iconSize: ZebrraUI.ICON_SIZE - 2.0,
            color: ZebrraColours().byListIndex(4),
          ),
          onTap: TautulliRoutes.LOGS_PLEX_MEDIA_SERVER.go,
        ),
        ZebrraBlock(
          title: 'Tautulli',
          body: const [TextSpan(text: 'Tautulli Logs')],
          trailing: ZebrraIconButton(
            icon: ZebrraIcons.TAUTULLI,
            color: ZebrraColours().byListIndex(5),
          ),
          onTap: TautulliRoutes.LOGS_TAUTULLI.go,
        ),
      ],
    );
  }
}
