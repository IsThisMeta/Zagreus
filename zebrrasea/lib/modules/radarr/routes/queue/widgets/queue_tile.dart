import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/routes/radarr.dart';

class RadarrQueueTile extends StatelessWidget {
  final RadarrQueueRecord record;
  final RadarrMovie? movie;

  const RadarrQueueTile({
    Key? key,
    required this.record,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<RadarrState>().movies,
      builder: (context, AsyncSnapshot<List<RadarrMovie>> snapshot) {
        RadarrMovie? movie;
        if (snapshot.hasData)
          movie = snapshot.data!.firstWhereOrNull(
            (element) => element.id == record.movieId,
          );
        return ZebrraExpandableListTile(
          title: record.title!,
          collapsedSubtitles: [
            _subtitle1(),
            _subtitle2(),
          ],
          expandedHighlightedNodes: _highlightedNodes(),
          expandedTableContent: _tableContent(movie),
          expandedTableButtons: _tableButtons(context),
          collapsedTrailing: ZebrraIconButton(
            icon: record.zebrraStatusIcon,
            color: record.zebrraStatusColor,
          ),
          onLongPress: () => RadarrRoutes.MOVIE.go(params: {
            'movie': record.movieId!.toString(),
          }),
        );
      },
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(text: record.zebrraMovieTitle(movie!));
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(
          text: record.zebrraQuality,
          style: const TextStyle(
            color: ZebrraColours.accent,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: record.timeLeft ?? ZebrraUI.TEXT_EMDASH),
      ],
    );
  }

  List<ZebrraTableContent> _tableContent(RadarrMovie? movie) {
    if (movie == null) return [];
    return [
      ZebrraTableContent(
          title: 'radarr.Movie'.tr(), body: record.zebrraMovieTitle(movie)),
      ZebrraTableContent(
          title: 'radarr.Languages'.tr(), body: record.zebrraLanguage),
      ZebrraTableContent(title: 'Client', body: record.zebrraDownloadClient),
      ZebrraTableContent(title: 'Indexer', body: record.zebrraIndexer),
      ZebrraTableContent(
          title: 'radarr.Size'.tr(), body: record.size!.toInt().asBytes()),
      ZebrraTableContent(
          title: 'Time Left', body: record.timeLeft ?? ZebrraUI.TEXT_EMDASH),
    ];
  }

  List<ZebrraHighlightedNode> _highlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: record.protocol?.readable ?? ZebrraUI.TEXT_EMDASH,
        backgroundColor: ZebrraColours.blue,
      ),
      ZebrraHighlightedNode(
        text: record.zebrraQuality,
        backgroundColor: ZebrraColours.accent,
      ),
      if ((record.customFormats?.length ?? 0) != 0)
        for (int i = 0; i < record.customFormats!.length; i++)
          ZebrraHighlightedNode(
            text: record.customFormats![i].name!,
            backgroundColor: ZebrraColours.orange,
          ),
      ZebrraHighlightedNode(
        text: '${record.zebrraPercentageComplete}%',
        backgroundColor: ZebrraColours.blueGrey,
      ),
      ZebrraHighlightedNode(
        text: record.status?.readable ?? ZebrraUI.TEXT_EMDASH,
        backgroundColor: ZebrraColours.blueGrey,
      ),
    ];
  }

  List<ZebrraButton> _tableButtons(BuildContext context) {
    return [
      if ((record.statusMessages ?? []).isNotEmpty)
        ZebrraButton.text(
          icon: Icons.messenger_outline_rounded,
          color: ZebrraColours.orange,
          text: 'Messages',
          onTap: () async {
            ZebrraDialogs().showMessages(
              context,
              record.statusMessages!
                  .map<String>((status) => status.messages!.join('\n'))
                  .toList(),
            );
          },
        ),
      if (record.status == RadarrQueueRecordStatus.COMPLETED &&
          record.trackedDownloadStatus == RadarrTrackedDownloadStatus.WARNING &&
          (record.outputPath ?? '').isNotEmpty)
        ZebrraButton.text(
          icon: Icons.download_done_rounded,
          text: 'radarr.Import'.tr(),
          onTap: () => RadarrRoutes.MANUAL_IMPORT_DETAILS.go(queryParams: {
            'path': record.outputPath!,
          }),
        ),
      ZebrraButton.text(
        icon: Icons.delete_rounded,
        color: ZebrraColours.red,
        text: 'Remove',
        onTap: () async {
          if (context.read<RadarrState>().enabled) {
            bool result = await RadarrDialogs().confirmDeleteQueue(context);
            if (result) {
              await context
                  .read<RadarrState>()
                  .api!
                  .queue
                  .delete(
                    id: record.id!,
                    blacklist: RadarrDatabase.QUEUE_BLACKLIST.read(),
                    removeFromClient:
                        RadarrDatabase.QUEUE_REMOVE_FROM_CLIENT.read(),
                  )
                  .then((_) {
                showZebrraSuccessSnackBar(
                  title: 'Removed From Queue',
                  message: record.title,
                );
                context
                    .read<RadarrState>()
                    .api!
                    .command
                    .refreshMonitoredDownloads()
                    .then((_) => context.read<RadarrState>().fetchQueue());
              }).catchError((error, stack) {
                ZebrraLogger().error(
                    'Failed to remove queue record: ${record.id}',
                    error,
                    stack);
                showZebrraErrorSnackBar(
                  title: 'Failed to Remove',
                  error: error,
                );
              });
            }
          }
        },
      ),
    ];
  }
}
