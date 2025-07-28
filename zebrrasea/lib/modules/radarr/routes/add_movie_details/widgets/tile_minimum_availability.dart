import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrAddMovieDetailsMinimumAvailabilityTile extends StatelessWidget {
  const RadarrAddMovieDetailsMinimumAvailabilityTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<RadarrAddMovieDetailsState, RadarrAvailability>(
      selector: (_, state) => state.availability,
      builder: (context, availability, _) {
        return ZebrraBlock(
          title: 'radarr.MinimumAvailability'.tr(),
          body: [TextSpan(text: availability.readable)],
          trailing: const ZebrraIconButton.arrow(),
          onTap: () async {
            Tuple2<bool, RadarrAvailability?> values =
                await RadarrDialogs().editMinimumAvailability(context);
            if (values.item1)
              context.read<RadarrAddMovieDetailsState>().availability =
                  values.item2!;
          },
        );
      },
    );
  }
}
