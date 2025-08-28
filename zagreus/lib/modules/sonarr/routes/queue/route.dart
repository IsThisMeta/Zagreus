import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class QueueRoute extends StatefulWidget {
  const QueueRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<QueueRoute> with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SonarrQueueState(context),
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(),
        body: _body(context),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<SonarrQueueState>().fetchQueue(
          context,
          hardCheck: true,
        );
    await context.read<SonarrQueueState>().queue;
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'sonarr.Queue'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZagRefreshIndicator(
      key: _refreshKey,
      context: context,
      onRefresh: () async => _onRefresh(context),
      child: FutureBuilder(
        future: context.watch<SonarrQueueState>().queue,
        builder: (context, AsyncSnapshot<SonarrQueuePage> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZagLogger().error(
                'Unable to fetch Sonarr queue',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZagMessage.error(
              onTap: _refreshKey.currentState!.show,
            );
          }
          if (snapshot.hasData) {
            return _list(snapshot.data!);
          }
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(SonarrQueuePage queue) {
    if (queue.records!.isEmpty) {
      return ZagMessage(
        text: 'sonarr.EmptyQueue'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: queue.records!.length,
      itemBuilder: (context, index) => SonarrQueueTile(
        key: ObjectKey(queue.records![index].id),
        queueRecord: queue.records![index],
        type: SonarrQueueTileType.ALL,
      ),
    );
  }
}
