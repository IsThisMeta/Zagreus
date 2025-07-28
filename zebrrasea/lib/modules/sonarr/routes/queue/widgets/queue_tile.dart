import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

enum SonarrQueueTileType {
  ALL,
  EPISODE,
}

class SonarrQueueTile extends StatefulWidget {
  final SonarrQueueRecord queueRecord;
  final SonarrQueueTileType type;

  const SonarrQueueTile({
    Key? key,
    required this.queueRecord,
    required this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrQueueTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: widget.queueRecord.title!,
      collapsedSubtitles: [
        if (widget.type == SonarrQueueTileType.ALL) _subtitle1(),
        if (widget.type == SonarrQueueTileType.ALL) _subtitle2(),
        _subtitle3(),
        _subtitle4(),
      ],
      expandedTableContent: _expandedTableContent(),
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableButtons: _tableButtons(),
      collapsedTrailing: _collapsedTrailing(),
      onLongPress: _onLongPress,
    );
  }

  Future<void> _onLongPress() async {
    switch (widget.type) {
      case SonarrQueueTileType.ALL:
        SonarrRoutes.SERIES.go(params: {
          'series': widget.queueRecord.seriesId!.toString(),
        });
        break;
      case SonarrQueueTileType.EPISODE:
        SonarrRoutes.QUEUE.go();
        break;
    }
  }

  Widget _collapsedTrailing() {
    Tuple3<String, IconData, Color> _status =
        widget.queueRecord.zebrraStatusParameters();
    return ZebrraIconButton(
      icon: _status.item2,
      color: _status.item3,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      text: widget.queueRecord.series!.title ?? ZebrraUI.TEXT_EMDASH,
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(
            text: widget.queueRecord.episode?.zebrraSeasonEpisode() ??
                ZebrraUI.TEXT_EMDASH),
        const TextSpan(text: ': '),
        TextSpan(
            text: widget.queueRecord.episode!.title ?? ZebrraUI.TEXT_EMDASH,
            style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  TextSpan _subtitle3() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.queueRecord.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        if (widget.queueRecord.language != null)
          TextSpan(
            text: widget.queueRecord.language?.name ?? ZebrraUI.TEXT_EMDASH,
          ),
        if (widget.queueRecord.language != null)
          TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(
          text: widget.queueRecord.zebrraTimeLeft(),
        ),
      ],
    );
  }

  TextSpan _subtitle4() {
    Tuple3<String, IconData, Color> _params =
        widget.queueRecord.zebrraStatusParameters(canBeWhite: false);
    return TextSpan(
      style: TextStyle(
        color: _params.item3,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
      children: [
        TextSpan(text: widget.queueRecord.zebrraPercentage()),
        TextSpan(text: ZebrraUI.TEXT_EMDASH.pad()),
        TextSpan(text: _params.item1),
      ],
    );
  }

  List<ZebrraHighlightedNode> _expandedHighlightedNodes() {
    Tuple3<String, IconData, Color> _status =
        widget.queueRecord.zebrraStatusParameters(canBeWhite: false);
    return [
      ZebrraHighlightedNode(
        text: widget.queueRecord.protocol!.zebrraReadable(),
        backgroundColor: widget.queueRecord.protocol!.zebrraProtocolColor(),
      ),
      ZebrraHighlightedNode(
        text: widget.queueRecord.zebrraPercentage(),
        backgroundColor: _status.item3,
      ),
      ZebrraHighlightedNode(
        text: widget.queueRecord.status!.zebrraStatus(),
        backgroundColor: _status.item3,
      ),
    ];
  }

  List<ZebrraTableContent> _expandedTableContent() {
    return [
      if (widget.type == SonarrQueueTileType.ALL)
        ZebrraTableContent(
          title: 'sonarr.Series'.tr(),
          body: widget.queueRecord.series?.title ?? ZebrraUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZebrraTableContent(
          title: 'sonarr.Episode'.tr(),
          body: widget.queueRecord.episode?.zebrraSeasonEpisode() ??
              ZebrraUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZebrraTableContent(
          title: 'sonarr.Title'.tr(),
          body: widget.queueRecord.episode?.title ?? ZebrraUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZebrraTableContent(title: '', body: ''),
      ZebrraTableContent(
        title: 'sonarr.Quality'.tr(),
        body: widget.queueRecord.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      if (widget.queueRecord.language != null)
        ZebrraTableContent(
          title: 'sonarr.Language'.tr(),
          body: widget.queueRecord.language?.name ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'sonarr.Client'.tr(),
        body: widget.queueRecord.downloadClient ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'sonarr.Size'.tr(),
        body: widget.queueRecord.size?.floor().asBytes() ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'sonarr.TimeLeft'.tr(),
        body: widget.queueRecord.zebrraTimeLeft(),
      ),
    ];
  }

  List<ZebrraButton> _tableButtons() {
    return [
      if ((widget.queueRecord.statusMessages ?? []).isNotEmpty)
        ZebrraButton.text(
          icon: Icons.messenger_outline_rounded,
          color: ZebrraColours.orange,
          text: 'sonarr.Messages'.tr(),
          onTap: () async {
            SonarrDialogs().showQueueStatusMessages(
              context,
              widget.queueRecord.statusMessages!,
            );
          },
        ),
      // if (widget.queueRecord.status == SonarrQueueStatus.COMPLETED &&
      //     widget.queueRecord?.trackedDownloadStatus ==
      //         SonarrTrackedDownloadStatus.WARNING)
      //   ZebrraButton.text(
      //     icon: Icons.download_done_rounded,
      //     text: 'sonarr.Import'.tr(),
      //     onTap: () async {},
      //   ),
      ZebrraButton.text(
        icon: Icons.delete_rounded,
        color: ZebrraColours.red,
        text: 'zebrrasea.Remove'.tr(),
        onTap: () async {
          bool result = await SonarrDialogs().removeFromQueue(context);
          if (result) {
            SonarrAPIController()
                .removeFromQueue(
              context: context,
              queueRecord: widget.queueRecord,
            )
                .then((_) {
              switch (widget.type) {
                case SonarrQueueTileType.ALL:
                  context.read<SonarrQueueState>().fetchQueue(
                        context,
                        hardCheck: true,
                      );
                  break;
                case SonarrQueueTileType.EPISODE:
                  context.read<SonarrSeasonDetailsState>().fetchState(
                        context,
                        shouldFetchEpisodes: false,
                        shouldFetchFiles: false,
                      );
                  break;
              }
            });
          }
        },
      ),
    ];
  }
}
