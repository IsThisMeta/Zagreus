import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class ManualImportRoute extends StatefulWidget {
  const ManualImportRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ManualImportRoute> createState() => _State();
}

class _State extends State<ManualImportRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RadarrManualImportState(context),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(),
        body: _body(context),
        bottomNavigationBar: const RadarrManualImportBottomActionBar(),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'radarr.ManualImport'.tr(),
      scrollControllers: [scrollController],
      bottom: ZebrraAppBar.empty(
        height: ZebrraTextInputBar.defaultAppBarHeight,
        child: RadarrManualImportPathBar(scrollController: scrollController),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future:
          context.select<RadarrManualImportState, Future<RadarrFileSystem>?>(
              (state) => state.directories),
      builder: (context, AsyncSnapshot<RadarrFileSystem> snapshot) {
        if (snapshot.hasError) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            ZebrraLogger().error(
              'Unable to fetch Radarr filesystem',
              snapshot.error,
              snapshot.stackTrace,
            );
          }
          return ZebrraMessage.error(onTap: () {
            context.read<RadarrManualImportState>().fetchDirectories(
                  context,
                  context.read<RadarrManualImportState>().currentPath,
                );
          });
        }
        if (snapshot.hasData) return _list(context, snapshot.data);
        return const ZebrraLoader();
      },
    );
  }

  Widget _list(BuildContext context, RadarrFileSystem? fileSystem) {
    if ((fileSystem?.directories?.length ?? 0) == 0 &&
        (fileSystem!.parent == null || fileSystem.parent!.isEmpty)) {
      return ZebrraMessage(
        text: 'radarr.NoSubdirectoriesFound'.tr(),
      );
    }
    return Selector<RadarrManualImportState, String?>(
      selector: (_, state) => state.currentPath,
      builder: (context, path, _) {
        List<RadarrFileSystemDirectory> directories =
            _filterDirectories(path, fileSystem);
        return ZebrraListView(
          key: ObjectKey(fileSystem!.directories),
          controller: scrollController,
          children: [
            RadarrManualImportParentDirectoryTile(fileSystem: fileSystem),
            ...List.generate(
              directories.length,
              (index) => RadarrManualImportDirectoryTile(
                  directory: directories[index]),
            ),
          ],
        );
      },
    );
  }

  List<RadarrFileSystemDirectory> _filterDirectories(
    String? path,
    RadarrFileSystem? fileSystem,
  ) {
    if (path == null || path.isEmpty) {
      return fileSystem!.directories ?? [];
    }
    if (fileSystem?.directories == null || fileSystem!.directories!.isEmpty) {
      return [];
    }
    return fileSystem.directories!
        .where(
          (element) =>
              (element.path?.toLowerCase() ?? '').contains(path.toLowerCase()),
        )
        .toList();
  }
}
