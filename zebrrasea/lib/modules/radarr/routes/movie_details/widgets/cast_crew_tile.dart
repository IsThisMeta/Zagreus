import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMovieDetailsCastCrewTile extends StatelessWidget {
  final RadarrMovieCredits credits;

  const RadarrMovieDetailsCastCrewTile({
    Key? key,
    required this.credits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: credits.personName,
      posterPlaceholderIcon: ZebrraIcons.USER,
      posterUrl: credits.images!.isEmpty ? null : credits.images![0].url,
      body: [
        TextSpan(text: _position),
        TextSpan(
          text: credits.type!.readable,
          style: TextStyle(
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
            color: credits.type == RadarrCreditType.CAST
                ? ZebrraColours.accent
                : ZebrraColours.orange,
          ),
        ),
      ],
      onTap: credits.personTmdbId?.toString().openTmdbPerson,
    );
  }

  String? get _position {
    switch (credits.type) {
      case RadarrCreditType.CREW:
        return credits.job!.isEmpty ? ZebrraUI.TEXT_EMDASH : credits.job;
      case RadarrCreditType.CAST:
        return credits.character!.isEmpty
            ? ZebrraUI.TEXT_EMDASH
            : credits.character;
      default:
        return ZebrraUI.TEXT_EMDASH;
    }
  }
}
