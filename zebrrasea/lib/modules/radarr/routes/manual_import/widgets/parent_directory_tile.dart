import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrManualImportParentDirectoryTile extends StatefulWidget {
  final RadarrFileSystem? fileSystem;

  const RadarrManualImportParentDirectoryTile({
    Key? key,
    required this.fileSystem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrManualImportParentDirectoryTile> {
  ZebrraLoadingState _loadingState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    if (widget.fileSystem == null ||
        widget.fileSystem!.parent == null ||
        widget.fileSystem!.parent!.isEmpty) return const SizedBox(height: 0.0);
    return ZebrraBlock(
      title: ZebrraUI.TEXT_ELLIPSIS,
      body: [TextSpan(text: 'radarr.ParentDirectory'.tr())],
      trailing: ZebrraIconButton(
        icon: Icons.arrow_upward_rounded,
        loadingState: _loadingState,
      ),
      onTap: () async {
        if (_loadingState == ZebrraLoadingState.INACTIVE) {
          if (mounted) setState(() => _loadingState = ZebrraLoadingState.ACTIVE);
          context.read<RadarrManualImportState>().fetchDirectories(
                context,
                widget.fileSystem!.parent,
              );
        }
      },
    );
  }
}
