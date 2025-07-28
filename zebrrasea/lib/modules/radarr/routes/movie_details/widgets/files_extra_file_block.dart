import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMovieDetailsFilesExtraFileBlock extends StatelessWidget {
  final RadarrExtraFile file;

  const RadarrMovieDetailsFilesExtraFileBlock({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'relative path', body: file.zebrraRelativePath),
        ZebrraTableContent(title: 'type', body: file.zebrraType),
        ZebrraTableContent(title: 'extension', body: file.zebrraExtension),
      ],
    );
  }
}
