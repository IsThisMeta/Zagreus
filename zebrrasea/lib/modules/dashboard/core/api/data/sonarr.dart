import 'package:flutter/material.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/modules/sonarr/core/state.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/abstract.dart';

class CalendarSonarrData extends CalendarData {
  String episodeTitle;
  int seasonNumber;
  int episodeNumber;
  int seriesID;
  String airTime;
  bool hasFile;
  String? fileQualityProfile;

  CalendarSonarrData({
    required int id,
    required String title,
    required this.episodeTitle,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.seriesID,
    required this.airTime,
    required this.hasFile,
    required this.fileQualityProfile,
  }) : super(id, title);

  @override
  List<TextSpan> get body {
    final released = hasAired;
    return [
      TextSpan(
        children: [
          TextSpan(
              text: seasonNumber == 0 ? 'Specials' : 'Season $seasonNumber'),
          TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
          TextSpan(text: 'Episode $episodeNumber'),
        ],
      ),
      TextSpan(
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
        text: episodeTitle,
      ),
      if (!hasFile)
        TextSpan(
          text: released ? 'sonarr.Missing'.tr() : 'sonarr.Unaired'.tr(),
          style: TextStyle(
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
            color: released ? ZebrraColours.red : ZebrraColours.blue,
          ),
        ),
      if (hasFile)
        TextSpan(
          text: 'Downloaded ($fileQualityProfile)',
          style: const TextStyle(
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
            color: ZebrraColours.accent,
          ),
        ),
    ];
  }

  bool get hasAired {
    if (airTimeObject != null) return DateTime.now().isAfter(airTimeObject!);
    return false;
  }

  @override
  Future<void> enterContent(BuildContext context) async {
    SonarrRoutes.SERIES.go(params: {'series': seriesID.toString()});
  }

  @override
  Widget trailing(BuildContext context) => ZebrraIconButton(
        text: airTimeString,
        onPressed: () async => trailingOnPress(context),
        onLongPress: () => trailingOnLongPress(context),
      );

  DateTime? get airTimeObject {
    return DateTime.tryParse(airTime)?.toLocal();
  }

  String get airTimeString {
    if (airTimeObject != null) {
      return ZebrraSeaDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(airTimeObject!)
          : DateFormat('hh:mm\na').format(airTimeObject!);
    }
    return 'Unknown';
  }

  @override
  Future<void> trailingOnPress(BuildContext context) async {
    if (context.read<SonarrState>().api != null)
      context
          .read<SonarrState>()
          .api!
          .command
          .episodeSearch(episodeIds: [id])
          .then((_) => showZebrraSuccessSnackBar(
                title: 'Searching for Episode...',
                message: episodeTitle,
              ))
          .catchError((error, stack) {
            ZebrraLogger().error(
              'Failed to search for episode: $id',
              error,
              stack,
            );
            showZebrraErrorSnackBar(
              title: 'Failed to Search',
              error: error,
            );
          });
  }

  @override
  Future<void> trailingOnLongPress(BuildContext context) async {
    SonarrRoutes.RELEASES.go(queryParams: {
      'episode': id.toString(),
    });
  }

  @override
  String? backgroundUrl(BuildContext context) {
    return context.read<SonarrState>().getFanartURL(this.seriesID);
  }

  @override
  String? posterUrl(BuildContext context) {
    return context.read<SonarrState>().getPosterURL(this.seriesID);
  }
}
