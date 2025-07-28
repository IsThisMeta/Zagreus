import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrSystemStatusAboutPage extends StatefulWidget {
  final ScrollController scrollController;

  const RadarrSystemStatusAboutPage({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrSystemStatusAboutPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

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
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<RadarrSystemStatusState>().fetchStatus(context),
      child: FutureBuilder(
        future: context.watch<RadarrSystemStatusState>().status,
        builder: (context, AsyncSnapshot<RadarrSystemStatus> snapshot) {
          if (snapshot.hasError) {
            ZebrraLogger().error('Unable to fetch Radarr system status',
                snapshot.error, snapshot.stackTrace);
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data!);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(RadarrSystemStatus status) {
    return ZebrraListView(
      controller: RadarrSystemStatusNavigationBar.scrollControllers[0],
      children: [
        ZebrraTableCard(
          content: [
            ZebrraTableContent(title: 'Version', body: status.zebrraVersion),
            if (status.zebrraIsDocker)
              ZebrraTableContent(
                title: 'Package',
                body: status.zebrraPackageVersion,
              ),
            ZebrraTableContent(title: '.NET Core', body: status.zebrraNetCore),
            ZebrraTableContent(title: 'Migration', body: status.zebrraDBMigration),
            ZebrraTableContent(
                title: 'AppData', body: status.zebrraAppDataDirectory),
            ZebrraTableContent(
                title: 'Startup', body: status.zebrraStartupDirectory),
            ZebrraTableContent(title: 'mode', body: status.zebrraMode),
            ZebrraTableContent(title: 'uptime', body: status.zebrraUptime),
          ],
        ),
      ],
    );
  }
}
