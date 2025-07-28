import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

class SonarrSeriesAddSearchResultTile extends StatefulWidget {
  static final double extent = ZebrraBlock.calculateItemExtent(
    1,
    hasBottom: true,
    bottomHeight: ZebrraBlock.SUBTITLE_HEIGHT * 2,
  );

  final SonarrSeries series;
  final bool onTapShowOverview;
  final bool exists;
  final bool isExcluded;

  const SonarrSeriesAddSearchResultTile({
    Key? key,
    required this.series,
    required this.exists,
    required this.isExcluded,
    this.onTapShowOverview = false,
  }) : super(key: key);

  @override
  State<SonarrSeriesAddSearchResultTile> createState() => _State();
}

class _State extends State<SonarrSeriesAddSearchResultTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      backgroundUrl: widget.series.remotePoster,
      posterUrl: widget.series.remotePoster,
      posterHeaders: context.watch<SonarrState>().headers,
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      title: widget.series.title,
      titleColor: widget.isExcluded ? ZebrraColours.red : Colors.white,
      disabled: widget.exists,
      body: [_subtitle1()],
      bottom: _subtitle2(),
      bottomHeight: ZebrraBlock.SUBTITLE_HEIGHT * 2,
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(text: widget.series.zebrraSeasonCount),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.series.zebrraYear),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.series.zebrraNetwork),
    ]);
  }

  Widget _subtitle2() {
    return SizedBox(
      height: ZebrraBlock.SUBTITLE_HEIGHT * 2,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: ZebrraUI.FONT_SIZE_H3,
            color: ZebrraColours.grey,
          ),
          children: [
            ZebrraTextSpan.extended(text: widget.series.zebrraOverview),
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Future<void> _onTap() async {
    if (widget.onTapShowOverview) {
      ZebrraDialogs().textPreview(
        context,
        widget.series.title,
        widget.series.overview ?? 'sonarr.NoSummaryAvailable'.tr(),
      );
    } else if (widget.exists) {
      SonarrRoutes.SERIES.go(params: {'series': widget.series.id!.toString()});
    } else {
      SonarrRoutes.ADD_SERIES_DETAILS.go(extra: widget.series);
    }
  }

  Future<void>? _onLongPress() async =>
      widget.series.tvdbId?.toString().openTvdbSeries();
}
