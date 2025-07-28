import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMoviesEditQualityProfileTile extends StatelessWidget {
  final List<RadarrQualityProfile?>? profiles;

  const RadarrMoviesEditQualityProfileTile({
    Key? key,
    required this.profiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<RadarrMoviesEditState, RadarrQualityProfile>(
      selector: (_, state) => state.qualityProfile,
      builder: (context, profile, _) => ZebrraBlock(
        title: 'radarr.QualityProfile'.tr(),
        body: [TextSpan(text: profile.name ?? ZebrraUI.TEXT_EMDASH)],
        trailing: const ZebrraIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, RadarrQualityProfile?> values =
              await RadarrDialogs().editQualityProfile(context, profiles!);
          if (values.item1)
            context.read<RadarrMoviesEditState>().qualityProfile =
                values.item2!;
        },
      ),
    );
  }
}
