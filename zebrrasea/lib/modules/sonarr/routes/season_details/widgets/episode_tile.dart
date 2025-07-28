import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

class SonarrEpisodeTile extends StatefulWidget {
  final SonarrEpisode episode;
  final SonarrEpisodeFile? episodeFile;
  final List<SonarrQueueRecord>? queueRecords;

  const SonarrEpisodeTile({
    Key? key,
    required this.episode,
    this.episodeFile,
    this.queueRecords,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrEpisodeTile> {
  ZebrraLoadingState _loadingState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      disabled: !widget.episode.monitored!,
      title: widget.episode.title,
      body: _body(),
      leading: _leading(),
      trailing: _trailing(),
      onTap: _onTap,
      onLongPress: _onLongPress,
      backgroundColor: context
              .read<SonarrSeasonDetailsState>()
              .selectedEpisodes
              .contains(widget.episode.id)
          ? ZebrraColours.accent.selected()
          : null,
    );
  }

  Future<void> _onTap() async {
    SonarrEpisodeDetailsSheet(
      context: context,
      episode: widget.episode,
      episodeFile: widget.episodeFile,
      queueRecords: widget.queueRecords,
    ).show();
  }

  Future<void> _onLongPress() async {
    Tuple2<bool, SonarrEpisodeSettingsType?> results = await SonarrDialogs()
        .episodeSettings(context: context, episode: widget.episode);
    if (results.item1) {
      results.item2!.execute(
        context: context,
        episode: widget.episode,
        episodeFile: widget.episodeFile,
      );
    }
  }

  List<TextSpan> _body() {
    return [
      TextSpan(text: widget.episode.zebrraAirDate()),
      TextSpan(
        text: widget.episode.zebrraDownloadedQuality(
          widget.episodeFile,
          widget.queueRecords?.isNotEmpty ?? false
              ? widget.queueRecords!.first
              : null,
        ),
        style: TextStyle(
          color: widget.episode.zebrraDownloadedQualityColor(
            widget.episodeFile,
            widget.queueRecords?.isNotEmpty ?? false
                ? widget.queueRecords!.first
                : null,
          ),
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
      ),
    ];
  }

  Widget _leading() {
    return ZebrraIconButton(
      text: widget.episode.episodeNumber.toString(),
      textSize: ZebrraUI.FONT_SIZE_H4,
      onPressed: () {
        context
            .read<SonarrSeasonDetailsState>()
            .toggleSelectedEpisode(widget.episode);
      },
    );
  }

  Widget _trailing() {
    Future<void> setLoadingState(ZebrraLoadingState state) async {
      if (this.mounted) setState(() => _loadingState = state);
    }

    return ZebrraIconButton(
      icon: Icons.search_rounded,
      loadingState: _loadingState,
      onPressed: () async {
        setLoadingState(ZebrraLoadingState.ACTIVE);
        SonarrAPIController()
            .episodeSearch(
              context: context,
              episode: widget.episode,
            )
            .whenComplete(() => setLoadingState(ZebrraLoadingState.INACTIVE));
      },
      onLongPress: () async {
        SonarrRoutes.RELEASES.go(queryParams: {
          'episode': widget.episode.id!.toString(),
        });
      },
    );
  }
}
