import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMovieDetailsOverviewInformationBlock extends StatelessWidget {
  final RadarrMovie? movie;
  final RadarrQualityProfile? qualityProfile;
  final List<RadarrTag> tags;

  const RadarrMovieDetailsOverviewInformationBlock({
    Key? key,
    required this.movie,
    required this.qualityProfile,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
          title: 'monitoring',
          body: (movie?.monitored ?? false) ? 'Yes' : 'No',
        ),
        ZebrraTableContent(title: 'path', body: movie?.path),
        ZebrraTableContent(title: 'quality', body: qualityProfile?.name),
        ZebrraTableContent(
          title: 'availability',
          body: movie?.zebrraMinimumAvailability,
        ),
        ZebrraTableContent(title: 'tags', body: movie?.zebrraTags(tags)),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(title: 'status', body: movie?.status?.readable),
        ZebrraTableContent(title: 'in cinemas', body: movie?.zebrraInCinemasOn()),
        ZebrraTableContent(
          title: 'digital',
          body: movie?.zebrraDigitalReleaseDate(),
        ),
        ZebrraTableContent(
          title: 'physical',
          body: movie?.zebrraPhysicalReleaseDate(),
        ),
        ZebrraTableContent(title: 'added on', body: movie?.zebrraDateAdded()),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(title: 'year', body: movie?.zebrraYear),
        ZebrraTableContent(title: 'studio', body: movie?.zebrraStudio),
        ZebrraTableContent(title: 'runtime', body: movie?.zebrraRuntime),
        ZebrraTableContent(title: 'rating', body: movie?.certification),
        ZebrraTableContent(title: 'genres', body: movie?.zebrraGenres),
        ZebrraTableContent(
            title: 'alternate titles', body: movie?.zebrraAlternateTitles),
      ],
    );
  }
}
