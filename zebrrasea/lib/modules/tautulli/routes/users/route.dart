import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliUsersRoute extends StatefulWidget {
  const TautulliUsersRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliUsersRoute> createState() => _State();
}

class _State extends State<TautulliUsersRoute>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().resetUsers();
    await context.read<TautulliState>().users;
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

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: Selector<TautulliState, Future<TautulliUsersTable>>(
        selector: (_, state) => state.users!,
        builder: (context, users, _) => FutureBuilder(
          future: users,
          builder: (context, AsyncSnapshot<TautulliUsersTable> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting) {
                ZebrraLogger().error(
                  'Unable to fetch Tautulli users',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData) return _users(snapshot.data);
            return const ZebrraLoader();
          },
        ),
      ),
    );
  }

  Widget _users(TautulliUsersTable? users) {
    if ((users?.users?.length ?? 0) == 0) {
      return ZebrraMessage(
        text: 'No Users Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    }
    return ZebrraListViewBuilder(
      controller: TautulliNavigationBar.scrollControllers[1],
      itemCount: users!.users!.length,
      itemBuilder: (context, index) => TautulliUserTile(
        user: users.users![index],
      ),
    );
  }
}
