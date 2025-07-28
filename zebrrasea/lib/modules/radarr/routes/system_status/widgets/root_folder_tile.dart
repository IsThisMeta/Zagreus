import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrRootFolderTile extends StatelessWidget {
  final RadarrRootFolder rootFolder;

  const RadarrRootFolderTile({
    Key? key,
    required this.rootFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: rootFolder.zebrraPath,
      body: [
        TextSpan(text: rootFolder.zebrraSpace),
        TextSpan(
          text: rootFolder.zebrraUnmappedFolders,
          style: const TextStyle(
            color: ZebrraColours.accent,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        )
      ],
    );
  }
}
