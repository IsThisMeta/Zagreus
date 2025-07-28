import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/routes/radarr.dart';

class RadarrUpcomingTile extends StatefulWidget {
  static final itemExtent = ZebrraBlock.calculateItemExtent(3);

  final RadarrMovie movie;
  final RadarrQualityProfile? profile;

  const RadarrUpcomingTile({
    Key? key,
    required this.movie,
    required this.profile,
  }) : super(key: key);

  @override
  State<RadarrUpcomingTile> createState() => _State();
}

class _State extends State<RadarrUpcomingTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<RadarrState, Future<List<RadarrMovie>>?>(
      selector: (_, state) => state.missing,
      builder: (context, missing, _) {
        return ZebrraBlock(
          title: widget.movie.title,
          body: [
            _subtitle1(),
            _subtitle2(),
            _subtitle3(),
          ],
          trailing: _trailing(),
          backgroundUrl:
              context.read<RadarrState>().getFanartURL(widget.movie.id),
          posterHeaders: context.read<RadarrState>().headers,
          posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
          posterIsSquare: false,
          posterUrl: context.read<RadarrState>().getPosterURL(widget.movie.id),
          onTap: _onTap,
          disabled: !widget.movie.monitored!,
        );
      },
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(text: widget.movie.zebrraYear),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zebrraRuntime),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zebrraStudio),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.profile!.zebrraName),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zebrraMinimumAvailability),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zebrraReleaseDate),
      ],
    );
  }

  TextSpan _subtitle3() {
    Color color;
    String? _days;
    String type;
    if (widget.movie.zebrraIsInCinemas && !widget.movie.zebrraIsReleased) {
      color = ZebrraColours.blue;
      _days = widget.movie.zebrraEarlierReleaseDate?.asDaysDifference();
      type = 'release';
    } else if (!widget.movie.zebrraIsInCinemas && !widget.movie.zebrraIsReleased) {
      color = ZebrraColours.orange;
      _days = widget.movie.inCinemas?.asDaysDifference();
      type = 'cinema';
    } else {
      color = ZebrraColours.grey;
      _days = ZebrraUI.TEXT_EMDASH;
      type = 'unknown';
    }
    return TextSpan(
      style: TextStyle(
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        color: color,
      ),
      children: [
        if (type == 'release')
          TextSpan(
            text: _days == null
                ? 'radarr.AvailabilityUnknown'.tr()
                : _days == 'Today'
                    ? 'radarr.AvailableToday'.tr()
                    : 'radarr.AvailableIn'.tr(args: [_days]),
          ),
        if (type == 'cinema')
          TextSpan(
            text: _days == null
                ? 'radarr.CinemaDateUnknown'.tr()
                : _days == 'Today'
                    ? 'radarr.InCinemasToday'.tr()
                    : 'radarr.InCinemasIn'.tr(args: [_days]),
          ),
        if (type == 'unknown') TextSpan(text: _days),
      ],
    );
  }

  ZebrraIconButton _trailing() {
    return ZebrraIconButton(
      icon: Icons.search_rounded,
      onPressed: () async => RadarrAPIHelper().automaticSearch(
        context: context,
        movieId: widget.movie.id!,
        title: widget.movie.title!,
      ),
      onLongPress: () => RadarrRoutes.MOVIE_RELEASES.go(params: {
        'movie': widget.movie.id!.toString(),
      }),
    );
  }

  Future<void> _onTap() async {
    RadarrRoutes.MOVIE.go(params: {
      'movie': widget.movie.id!.toString(),
    });
  }
}
