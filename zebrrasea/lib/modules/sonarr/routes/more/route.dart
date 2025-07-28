import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

class SonarrMoreRoute extends StatefulWidget {
  const SonarrMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrMoreRoute> createState() => _State();
}

class _State extends State<SonarrMoreRoute> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      body: _body(),
    );
  }

  // ignore: unused_element
  Future<void> _showComingSoonMessage() async {
    showZebrraInfoSnackBar(
      title: 'zebrrasea.ComingSoon'.tr(),
      message: 'This feature is still being developed!',
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: SonarrNavigationBar.scrollControllers[3],
      children: [
        ZebrraBlock(
          title: 'sonarr.History'.tr(),
          body: [TextSpan(text: 'sonarr.HistoryDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.history_rounded,
            color: ZebrraColours().byListIndex(0),
          ),
          onTap: SonarrRoutes.HISTORY.go,
        ),
        // ZebrraBlock(
        //   title: 'sonarr.ManualImport'.tr(),
        //   body: [TextSpan(text: 'sonarr.ManualImportDescription'.tr())],
        //   trailing: ZebrraIconButton(
        //     icon: Icons.download_done_rounded,
        //     color: ZebrraColours().byListIndex(1),
        //   ),
        //   onTap: () async => _showComingSoonMessage(),
        // ),
        ZebrraBlock(
          title: 'sonarr.Queue'.tr(),
          body: [TextSpan(text: 'sonarr.QueueDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.queue_play_next_rounded,
            color: ZebrraColours().byListIndex(1),
          ),
          onTap: SonarrRoutes.QUEUE.go,
        ),
        // ZebrraBlock(
        //   title: 'sonarr.SystemStatus'.tr(),
        //   body: [TextSpan(text: 'sonarr.SystemStatusDescription'.tr())],
        //   trailing: ZebrraIconButton(
        //     icon: Icons.computer_rounded,
        //     color: ZebrraColours().byListIndex(3),
        //   ),
        //   onTap: () async => _showComingSoonMessage(),
        // ),
        ZebrraBlock(
          title: 'sonarr.Tags'.tr(),
          body: [TextSpan(text: 'sonarr.TagsDescription'.tr())],
          trailing: ZebrraIconButton(
            icon: Icons.style_rounded,
            color: ZebrraColours().byListIndex(2),
          ),
          onTap: SonarrRoutes.TAGS.go,
        ),
      ],
    );
  }
}
