import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class QueueRoute extends StatefulWidget {
  const QueueRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<QueueRoute>
    with ZebrraLoadCallbackMixin, ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
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
    return ZebrraAppBar(
      title: 'radarr.Queue'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
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
              ZebrraLogger().error(
                'Unable to fetch Radarr queue',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) {
            return _list(
              snapshot.data![0],
              snapshot.data![1],
            );
          }
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(RadarrQueue queue, List<RadarrMovie> movies) {
    if ((queue.records?.length ?? 0) == 0) {
      return ZebrraMessage(
        text: 'Empty Queue',
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState?.show,
      );
    }
    return ZebrraListViewBuilder(
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
