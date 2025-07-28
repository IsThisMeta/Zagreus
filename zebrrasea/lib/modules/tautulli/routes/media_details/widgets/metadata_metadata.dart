import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliMediaDetailsMetadataMetadata extends StatelessWidget {
  final TautulliMetadata? metadata;

  const TautulliMediaDetailsMetadataMetadata({
    Key? key,
    required this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        if (metadata!.originallyAvailableAt != null &&
            metadata!.originallyAvailableAt!.isNotEmpty)
          ZebrraTableContent(
            title: 'released',
            body: metadata!.originallyAvailableAt,
          ),
        if (metadata!.addedAt != null)
          ZebrraTableContent(
            title: 'added',
            body: metadata!.addedAt!.asPoleDate(),
          ),
        if (metadata!.duration != null)
          ZebrraTableContent(
            title: 'duration',
            body: metadata!.duration!.asNumberTimestamp(),
          ),
        if (metadata?.mediaInfo?.isNotEmpty ?? false)
          ZebrraTableContent(
            title: 'bitrate',
            body:
                '${metadata!.mediaInfo![0].bitrate ?? ZebrraUI.TEXT_EMDASH} kbps',
          ),
        if (metadata!.rating != null)
          ZebrraTableContent(
              title: 'rating',
              body: '${(((metadata?.rating ?? 0) * 10).truncate())}%'),
        if (metadata!.studio != null && metadata!.studio!.isNotEmpty)
          ZebrraTableContent(
            title: 'studio',
            body: metadata!.studio,
          ),
        if (metadata?.genres?.isNotEmpty ?? false)
          ZebrraTableContent(
            title: 'genres',
            body: metadata!.genres!.take(5).join('\n'),
          ),
        if (metadata?.directors?.isNotEmpty ?? false)
          ZebrraTableContent(
            title: 'directors',
            body: metadata!.directors!.take(5).join('\n'),
          ),
        if (metadata?.writers?.isNotEmpty ?? false)
          ZebrraTableContent(
            title: 'writers',
            body: metadata!.writers!.take(5).join('\n'),
          ),
        if (metadata?.actors?.isNotEmpty ?? false)
          ZebrraTableContent(
            title: 'actors',
            body: metadata!.actors!.take(5).join('\n'),
          ),
      ],
    );
  }
}
