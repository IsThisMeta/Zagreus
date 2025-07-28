import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/tautulli.dart';

class TautulliLibrariesLibraryTile extends StatelessWidget {
  final TautulliTableLibrary library;

  const TautulliLibrariesLibraryTile({
    Key? key,
    required this.library,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? _plays = library.plays;
    return ZebrraBlock(
      title: library.sectionName,
      body: [
        TextSpan(text: library.readableCount),
        TextSpan(
          children: [
            TextSpan(text: _plays == 1 ? '1 Play' : '$_plays Plays'),
            TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
            TextSpan(text: library.duration!.asWordsTimestamp()),
          ],
        ),
        TextSpan(
          style: const TextStyle(
            color: ZebrraColours.accent,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
          text: library.lastAccessed?.asAge() ?? 'Unknown',
        ),
      ],
      backgroundUrl:
          context.watch<TautulliState>().getImageURLFromPath(library.thumb),
      backgroundHeaders: context.watch<TautulliState>().headers,
      onTap: () => TautulliRoutes.LIBRARIES_DETAILS.go(params: {
        'section': library.sectionId.toString(),
      }),
    );
  }
}
