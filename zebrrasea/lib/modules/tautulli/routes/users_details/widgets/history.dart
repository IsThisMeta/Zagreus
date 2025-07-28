import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliUserDetailsHistory extends StatefulWidget {
  final TautulliTableUser user;

  const TautulliUserDetailsHistory({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliUserDetailsHistory>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().setUserHistory(
          widget.user.userId!,
          context.read<TautulliState>().api!.history.getHistory(
                userId: widget.user.userId,
                length: TautulliDatabase.CONTENT_LOAD_LENGTH.read(),
              ),
        );
    await context.read<TautulliState>().userHistory[widget.user.userId!];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.TAUTULLI,
      body: _body(),
    );
  }

  Widget _body() => ZebrraRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: loadCallback,
        child: FutureBuilder(
          future:
              context.watch<TautulliState>().userHistory[widget.user.userId!],
          builder: (context, AsyncSnapshot<TautulliHistory> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting)
                ZebrraLogger().error(
                  'Unable to fetch Tautulli user history: ${widget.user.userId}',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData) return _history(snapshot.data);
            return const ZebrraLoader();
          },
        ),
      );

  Widget _history(TautulliHistory? history) {
    if ((history?.records ?? 0) == 0)
      return ZebrraMessage(
        text: 'No History Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    return ZebrraListViewBuilder(
      controller: TautulliUserDetailsNavigationBar.scrollControllers[1],
      itemCount: history!.records!.length,
      itemBuilder: (context, index) => TautulliHistoryTile(
        history: history.records![index],
      ),
    );
  }
}
