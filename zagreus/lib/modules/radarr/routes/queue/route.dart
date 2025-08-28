import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class QueueRoute extends StatefulWidget {
  const QueueRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<QueueRoute>
    with ZagLoadCallbackMixin, ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  @override
  Future<void> loadCallback() async {
    if (context.read<RadarrState>().enabled) {
      await context
          .read<RadarrState>()
          .api!
          .command
          .refreshMonitoredDownloads();
      context.read<RadarrState>().fetchQueue();
      await context.read<RadarrState>().queue;
    }
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'radarr.Queue'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      key: _refreshKey,
      context: context,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: Future.wait([
          context.select((RadarrState state) => state.queue!),
          context.select((RadarrState state) => state.movies!),
        ]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZagLogger().error(
                'Unable to fetch Radarr queue',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) {
            return _list(
              snapshot.data![0],
              snapshot.data![1],
            );
          }
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(RadarrQueue queue, List<RadarrMovie> movies) {
    if ((queue.records?.length ?? 0) == 0) {
      return ZagMessage(
        text: 'Empty Queue',
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState?.show,
      );
    }
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: queue.records!.length,
      itemBuilder: (context, index) {
        RadarrMovie? movie = movies.firstWhereOrNull(
          (movie) => movie.id == queue.records![index].movieId,
        );
        return RadarrQueueTile(
          record: queue.records![index],
          movie: movie,
        );
      },
    );
  }
}
