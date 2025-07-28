import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliMediaDetailsMetadata extends StatefulWidget {
  final TautulliMediaType? type;
  final int ratingKey;

  const TautulliMediaDetailsMetadata({
    required this.type,
    required this.ratingKey,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliMediaDetailsMetadata>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    context.read<TautulliState>().setMetadata(
          widget.ratingKey,
          context
              .read<TautulliState>()
              .api!
              .libraries
              .getMetadata(ratingKey: widget.ratingKey),
        );
    await context.read<TautulliState>().metadata[widget.ratingKey];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: context.watch<TautulliState>().metadata[widget.ratingKey],
        builder: (context, AsyncSnapshot<TautulliMetadata> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Tautulli metadata: ${widget.ratingKey}',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _metadata(snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _metadata(TautulliMetadata? metadata) {
    return ZebrraListView(
      controller: TautulliMediaDetailsNavigationBar.scrollControllers[0],
      children: [
        TautulliMediaDetailsMetadataHeaderTile(metadata: metadata),
        TautulliMediaDetailsMetadataSummary(
            metadata: metadata, type: widget.type),
        TautulliMediaDetailsMetadataMetadata(metadata: metadata),
      ],
    );
  }
}
