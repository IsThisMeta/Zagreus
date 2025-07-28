import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesDetailsOverviewDescriptionTile extends StatelessWidget {
  final SonarrSeries? series;

  const SonarrSeriesDetailsOverviewDescriptionTile({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      backgroundUrl: context.read<SonarrState>().getFanartURL(series!.id),
      posterUrl: context.read<SonarrState>().getPosterURL(series!.id),
      posterHeaders: context.read<SonarrState>().headers,
      title: series!.title,
      body: [
        ZebrraTextSpan.extended(
          text: series!.overview == null || series!.overview!.isEmpty
              ? 'sonarr.NoSummaryAvailable'.tr()
              : series!.overview,
        ),
      ],
      customBodyMaxLines: 3,
      onTap: () async => ZebrraDialogs().textPreview(
        context,
        series!.title,
        series!.overview!,
      ),
    );
  }
}
