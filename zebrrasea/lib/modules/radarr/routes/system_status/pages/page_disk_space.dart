import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrSystemStatusDiskSpacePage extends StatefulWidget {
  final ScrollController scrollController;

  const RadarrSystemStatusDiskSpacePage({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrSystemStatusDiskSpacePage>
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

  Future<void> _refresh() async {
    context.read<RadarrSystemStatusState>().fetchDiskSpace(context);
    context.read<RadarrState>().fetchRootFolders();
    await Future.wait([
      context.read<RadarrSystemStatusState>().diskSpace!,
      context.read<RadarrState>().rootFolders!,
    ]);
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: Future.wait([
          context.watch<RadarrSystemStatusState>().diskSpace!,
          context.read<RadarrState>().rootFolders!,
        ]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasError) {
            ZebrraLogger().error('Unable to fetch Radarr disk space',
                snapshot.error, snapshot.stackTrace);
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData)
            return _list(snapshot.data![0], snapshot.data![1]);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(
    List<RadarrDiskSpace> diskSpace,
    List<RadarrRootFolder> rootFolders,
  ) {
    // Compile Disks
    List<Widget> _disks = [
      ZebrraMessage.inList(text: 'radarr.NoDisksFound'.tr())
    ];
    if (diskSpace.isNotEmpty)
      _disks = [
        ZebrraHeader(text: 'radarr.Disks'.tr()),
        ...List.generate(
          diskSpace.length,
          (index) => RadarrDiskSpaceTile(diskSpace: diskSpace[index]),
        ),
      ];
    // Compile root folders
    List<Widget> _rootFolders = [
      ZebrraMessage.inList(text: 'radarr.NoRootFoldersFound'.tr())
    ];
    if (rootFolders.isNotEmpty)
      _rootFolders = [
        ZebrraHeader(text: 'radarr.RootFolders'.tr()),
        ...List.generate(
          rootFolders.length,
          (index) => RadarrRootFolderTile(rootFolder: rootFolders[index]),
        ),
      ];
    return ZebrraListView(
      controller: RadarrSystemStatusNavigationBar.scrollControllers[1],
      children: [
        ..._disks,
        ..._rootFolders,
      ],
    );
  }
}
