import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class LogsPlexMediaServerRoute extends StatefulWidget {
  const LogsPlexMediaServerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LogsPlexMediaServerRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TautulliLogsPlexMediaServerState(context),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'Plex Media Server Logs',
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<TautulliLogsPlexMediaServerState>().fetchLogs(context),
      child: FutureBuilder(
        future: context
            .select((TautulliLogsPlexMediaServerState state) => state.logs),
        builder: (context, AsyncSnapshot<List<TautulliPlexLog>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Plex Media Server logs',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _logs(snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _logs(List<TautulliPlexLog>? logs) {
    if ((logs?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'No Logs Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    List<TautulliPlexLog> _reversed = logs!.reversed.toList();
    return ZebrraListViewBuilder(
      controller: scrollController,
      itemCount: _reversed.length,
      itemBuilder: (context, index) =>
          TautulliLogsPlexMediaServerLogTile(log: _reversed[index]),
    );
  }
}
