import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesDetailsOverviewInformationBlock extends StatelessWidget {
  final SonarrSeries? series;
  final SonarrQualityProfile? qualityProfile;
  final SonarrLanguageProfile? languageProfile;
  final List<SonarrTag> tags;

  const SonarrSeriesDetailsOverviewInformationBlock({
    Key? key,
    required this.series,
    required this.qualityProfile,
    required this.languageProfile,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
          title: 'sonarr.Monitoring'.tr(),
          body: (series?.monitored ?? false) ? 'Yes' : 'No',
        ),
        ZebrraTableContent(
          title: 'type',
          body: series?.zebrraSeriesType,
        ),
        ZebrraTableContent(
          title: 'path',
          body: series?.path,
        ),
        ZebrraTableContent(
          title: 'quality',
          body: qualityProfile?.name,
        ),
        ZebrraTableContent(
          title: 'language',
          body: languageProfile?.name,
        ),
        ZebrraTableContent(
          title: 'tags',
          body: series?.zebrraTags(tags),
        ),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(
          title: 'status',
          body: series?.status?.toTitleCase(),
        ),
        ZebrraTableContent(
          title: 'next airing',
          body: series?.zebrraNextAiring(),
        ),
        ZebrraTableContent(
          title: 'added on',
          body: series?.zebrraDateAdded,
        ),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(
          title: 'year',
          body: series?.zebrraYear,
        ),
        ZebrraTableContent(
          title: 'network',
          body: series?.zebrraNetwork,
        ),
        ZebrraTableContent(
          title: 'runtime',
          body: series?.zebrraRuntime,
        ),
        ZebrraTableContent(
          title: 'rating',
          body: series?.certification,
        ),
        ZebrraTableContent(
          title: 'genres',
          body: series?.zebrraGenres,
        ),
        ZebrraTableContent(
          title: 'alternate titles',
          body: series?.zebrraAlternateTitles,
        ),
      ],
    );
  }
}
