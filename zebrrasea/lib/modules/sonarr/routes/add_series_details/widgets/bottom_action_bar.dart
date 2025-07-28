import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/router.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

class SonarrAddSeriesDetailsActionBar extends StatelessWidget {
  const SonarrAddSeriesDetailsActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraActionBarCard(
          title: 'zebrrasea.Options'.tr(),
          subtitle: 'sonarr.StartSearchFor'.tr(),
          onTap: () async => SonarrDialogs().addSeriesOptions(context),
        ),
        ZebrraButton(
          type: ZebrraButtonType.TEXT,
          text: 'zebrrasea.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _onTap(context),
          loadingState: context.watch<SonarrSeriesAddDetailsState>().state,
        ),
      ],
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (context.read<SonarrSeriesAddDetailsState>().canExecuteAction) {
      context.read<SonarrSeriesAddDetailsState>().state =
          ZebrraLoadingState.ACTIVE;
      SonarrSeriesAddDetailsState _state =
          context.read<SonarrSeriesAddDetailsState>();
      await SonarrAPIController()
          .addSeries(
        context: context,
        series: _state.series,
        qualityProfile: _state.qualityProfile,
        languageProfile: _state.languageProfile,
        rootFolder: _state.rootFolder,
        seasonFolder: _state.useSeasonFolders,
        tags: _state.tags,
        seriesType: _state.seriesType,
        monitorType: _state.monitorType,
      )
          .then((series) async {
        context.read<SonarrState>().fetchAllSeries();
        context.read<SonarrSeriesAddDetailsState>().series.id = series!.id;

        ZebrraRouter.router.pop();
        SonarrRoutes.SERIES.go(params: {
          'series': series.id!.toString(),
        });
      }).catchError((error, stack) {
        context.read<SonarrSeriesAddDetailsState>().state =
            ZebrraLoadingState.ERROR;
      });
      context.read<SonarrSeriesAddDetailsState>().state =
          ZebrraLoadingState.INACTIVE;
    }
  }
}
