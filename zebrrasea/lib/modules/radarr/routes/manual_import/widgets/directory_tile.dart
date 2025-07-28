import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrManualImportDirectoryTile extends StatefulWidget {
  final RadarrFileSystemDirectory directory;

  const RadarrManualImportDirectoryTile({
    Key? key,
    required this.directory,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrManualImportDirectoryTile> {
  ZebrraLoadingState _loadingState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    RadarrFileSystemDirectory _dir = widget.directory;
    if (_dir.path?.isEmpty ?? true) return const SizedBox(height: 0.0);
    return ZebrraBlock(
      title: _dir.name ?? ZebrraUI.TEXT_EMDASH,
      body: [TextSpan(text: _dir.path)],
      trailing: ZebrraIconButton.arrow(loadingState: _loadingState),
      onTap: () async {
        if (_loadingState == ZebrraLoadingState.INACTIVE) {
          if (mounted) setState(() => _loadingState = ZebrraLoadingState.ACTIVE);
          context.read<RadarrManualImportState>().fetchDirectories(
                context,
                _dir.path,
              );
        }
      },
    );
  }
}
