import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class LibrariesRoute extends StatefulWidget {
  const LibrariesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<LibrariesRoute> createState() => _State();
}

class _State extends State<LibrariesRoute>
    with ZebrraScrollControllerMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().resetLibrariesTable();
    await context.read<TautulliState>().librariesTable;
  }

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
      title: 'Libraries',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      onRefresh: loadCallback,
      key: _refreshKey,
      child: Selector<TautulliState, Future<TautulliLibrariesTable>?>(
        selector: (_, state) => state.librariesTable,
        builder: (context, future, _) => FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<TautulliLibrariesTable> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting)
                ZebrraLogger().error(
                  'Unable to fetch Tautulli libraries table',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData) return _libraries(snapshot.data);
            return const ZebrraLoader();
          },
        ),
      ),
    );
  }

  Widget _libraries(TautulliLibrariesTable? libraries) {
    if ((libraries?.libraries?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'No Libraries Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    return ZebrraListViewBuilder(
      controller: scrollController,
      itemCount: libraries!.libraries!.length,
      itemBuilder: (context, index) =>
          TautulliLibrariesLibraryTile(library: libraries.libraries![index]),
    );
  }
}
