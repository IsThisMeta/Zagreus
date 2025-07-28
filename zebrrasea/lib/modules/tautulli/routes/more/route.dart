import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/tautulli.dart';

class TautulliMoreRoute extends StatefulWidget {
  const TautulliMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliMoreRoute> createState() => _State();
}

class _State extends State<TautulliMoreRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.TAUTULLI,
      body: _body,
    );
  }

  Widget get _body {
    return ZebrraListView(
      controller: TautulliNavigationBar.scrollControllers[3],
      children: [
        ZebrraBlock(
          title: 'Check for Updates',
          body: const [TextSpan(text: 'Tautulli & Plex Updates')],
          trailing: ZebrraIconButton(
            icon: Icons.system_update_rounded,
            color: ZebrraColours().byListIndex(0),
          ),
          onTap: TautulliRoutes.CHECK_FOR_UPDATES.go,
        ),
        ZebrraBlock(
          title: 'Graphs',
          body: const [TextSpan(text: 'Play Count & Duration Graphs')],
          trailing: ZebrraIconButton(
            icon: Icons.insert_chart_rounded,
            color: ZebrraColours().byListIndex(1),
          ),
          onTap: TautulliRoutes.GRAPHS.go,
        ),
        ZebrraBlock(
          title: 'Libraries',
          body: const [TextSpan(text: 'Plex Library Information')],
          trailing: ZebrraIconButton(
            icon: Icons.video_library_rounded,
            color: ZebrraColours().byListIndex(2),
          ),
          onTap: TautulliRoutes.LIBRARIES.go,
        ),
        ZebrraBlock(
          title: 'Logs',
          body: const [TextSpan(text: 'Tautulli & Plex Logs')],
          trailing: ZebrraIconButton(
            icon: Icons.developer_mode_rounded,
            color: ZebrraColours().byListIndex(3),
          ),
          onTap: TautulliRoutes.LOGS.go,
        ),
        ZebrraBlock(
          title: 'Recently Added',
          body: const [TextSpan(text: 'Recently Added Content to Plex')],
          trailing: ZebrraIconButton(
            icon: Icons.recent_actors_rounded,
            color: ZebrraColours().byListIndex(4),
          ),
          onTap: TautulliRoutes.RECENTLY_ADDED.go,
        ),
        ZebrraBlock(
          title: 'Search',
          body: const [TextSpan(text: 'Search Your Libraries')],
          trailing: ZebrraIconButton(
            icon: Icons.search_rounded,
            color: ZebrraColours().byListIndex(5),
          ),
          onTap: TautulliRoutes.SEARCH.go,
        ),
        ZebrraBlock(
          title: 'Statistics',
          body: const [TextSpan(text: 'User & Library Statistics')],
          trailing: ZebrraIconButton(
            icon: Icons.format_list_numbered_rounded,
            color: ZebrraColours().byListIndex(6),
          ),
          onTap: TautulliRoutes.STATISTICS.go,
        ),
        ZebrraBlock(
          title: 'Synced Items',
          body: const [TextSpan(text: 'Synced Content on Devices')],
          trailing: ZebrraIconButton(
            icon: Icons.sync_rounded,
            color: ZebrraColours().byListIndex(7),
          ),
          onTap: TautulliRoutes.SYNCED_ITEMS.go,
        ),
      ],
    );
  }
}
