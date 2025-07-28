import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/router.dart';

class SonarrEditSeriesActionBar extends StatelessWidget {
  const SonarrEditSeriesActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton(
          type: ZebrraButtonType.TEXT,
          text: 'zebrrasea.Update'.tr(),
          icon: Icons.edit_rounded,
          loadingState: context.watch<SonarrSeriesEditState>().state,
          onTap: () async => _updateOnTap(context),
        ),
      ],
    );
  }

  Future<void> _updateOnTap(BuildContext context) async {
    if (context.read<SonarrSeriesEditState>().canExecuteAction) {
      context.read<SonarrSeriesEditState>().state = ZebrraLoadingState.ACTIVE;
      if (context.read<SonarrSeriesEditState>().series != null) {
        SonarrSeries series = context
            .read<SonarrSeriesEditState>()
            .series!
            .updateEdits(context.read<SonarrSeriesEditState>());
        bool result = await SonarrAPIController().updateSeries(
          context: context,
          series: series,
        );
        if (result) ZebrraRouter().popSafely();
      }
    }
  }
}
