import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/routes/radarr.dart';

class RadarrMoreRoute extends StatefulWidget {
  const RadarrMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<RadarrMoreRoute> createState() => _State();
}

class _State extends State<RadarrMoreRoute> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: RadarrNavigationBar.scrollControllers[3],
      itemExtent: ZebrraBlock.calculateItemExtent(1),
      children: [
        ZebrraBlock(
          title: 'radarr.History'.tr(),
          body: [TextSpan(text: 'radarr.HistoryDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.history_rounded,
            color: ZebrraColours().byListIndex(0),
          ),
          onTap: RadarrRoutes.HISTORY.go,
        ),
        ZebrraBlock(
          title: 'radarr.ManualImport'.tr(),
          body: [TextSpan(text: 'radarr.ManualImportDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.download_done_rounded,
            color: ZebrraColours().byListIndex(1),
          ),
          onTap: RadarrRoutes.MANUAL_IMPORT.go,
        ),
        ZebrraBlock(
          title: 'radarr.Queue'.tr(),
          body: [TextSpan(text: 'radarr.QueueDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.queue_play_next_rounded,
            color: ZebrraColours().byListIndex(2),
          ),
          onTap: RadarrRoutes.QUEUE.go,
        ),
        ZebrraBlock(
          title: 'radarr.SystemStatus'.tr(),
          body: [TextSpan(text: 'radarr.SystemStatusDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.computer_rounded,
            color: ZebrraColours().byListIndex(3),
          ),
          onTap: RadarrRoutes.SYSTEM_STATUS.go,
        ),
        ZebrraBlock(
          title: 'radarr.Tags'.tr(),
          body: [TextSpan(text: 'radarr.TagsDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.style_rounded,
            color: ZebrraColours().byListIndex(4),
          ),
          onTap: RadarrRoutes.TAGS.go,
        ),
      ],
    );
  }
}
