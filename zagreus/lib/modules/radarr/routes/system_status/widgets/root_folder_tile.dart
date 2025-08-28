import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrRootFolderTile extends StatelessWidget {
  final RadarrRootFolder rootFolder;

  const RadarrRootFolderTile({
    Key? key,
    required this.rootFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: rootFolder.zagPath,
      body: [
        TextSpan(text: rootFolder.zagSpace),
        TextSpan(
          text: rootFolder.zagUnmappedFolders,
          style: const TextStyle(
            color: ZagColours.accent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        )
      ],
    );
  }
}
