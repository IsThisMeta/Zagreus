import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class LogsNewslettersRoute extends StatefulWidget {
  const LogsNewslettersRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LogsNewslettersRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TautulliLogsNewslettersState(context),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'Newsletter Logs',
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<TautulliLogsNewslettersState>().fetchLogs(context),
      child: FutureBuilder(
        future:
            context.select((TautulliLogsNewslettersState state) => state.logs),
        builder: (context, AsyncSnapshot<TautulliNewsletterLogs> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Tautulli newsletter logs',
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

  Widget _logs(TautulliNewsletterLogs? logs) {
    if ((logs?.logs?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'No Logs Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    return ZebrraListViewBuilder(
      controller: scrollController,
      itemCount: logs!.logs!.length,
      itemBuilder: (context, index) =>
          TautulliLogsNewsletterLogTile(newsletter: logs.logs![index]),
    );
  }
}
