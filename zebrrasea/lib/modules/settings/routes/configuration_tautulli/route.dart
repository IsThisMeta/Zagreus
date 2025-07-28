import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationTautulliRoute extends StatefulWidget {
  const ConfigurationTautulliRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationTautulliRoute> createState() => _State();
}

class _State extends State<ConfigurationTautulliRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: ZebrraModule.TAUTULLI.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraModule.TAUTULLI.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZebrraDivider(),
        _activityRefreshRate(),
        _defaultPagesPage(),
        _defaultTerminationMessage(),
        _statisticsItemCount(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.EnableModule'.tr(args: [ZebrraModule.TAUTULLI.title]),
        trailing: ZebrraSwitch(
          value: ZebrraProfile.current.tautulliEnabled,
          onChanged: (value) {
            ZebrraProfile.current.tautulliEnabled = value;
            ZebrraProfile.current.save();
            context.read<TautulliState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZebrraBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZebrraModule.TAUTULLI.title],
          ),
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZebrraBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_TAUTULLI_DEFAULT_PAGES.go,
    );
  }

  Widget _defaultTerminationMessage() {
    const _db = TautulliDatabase.TERMINATION_MESSAGE;
    return _db.listenableBuilder(
      builder: (context, _) {
        String message = _db.read();
        return ZebrraBlock(
          title: 'tautulli.DefaultTerminationMessage'.tr(),
          body: [
            TextSpan(text: message.isEmpty ? 'zebrrasea.NotSet'.tr() : message),
          ],
          trailing: const ZebrraIconButton(icon: Icons.videocam_off_rounded),
          onTap: () async {
            Tuple2<bool, String> result =
                await TautulliDialogs.setTerminationMessage(context);
            if (result.item1) _db.update(result.item2);
          },
        );
      },
    );
  }

  Widget _activityRefreshRate() {
    const _db = TautulliDatabase.REFRESH_RATE;
    return _db.listenableBuilder(builder: (context, _) {
      String refreshRate = _db.read() == 1
          ? 'zebrrasea.EverySecond'.tr()
          : 'zebrrasea.EverySeconds'.tr(args: [_db.read().toString()]);
      return ZebrraBlock(
        title: 'tautulli.ActivityRefreshRate'.tr(),
        body: [TextSpan(text: refreshRate)],
        trailing: const ZebrraIconButton(icon: ZebrraIcons.REFRESH),
        onTap: () async {
          List<dynamic> _values = await TautulliDialogs.setRefreshRate(context);
          if (_values[0]) _db.update(_values[1]);
        },
      );
    });
  }

  Widget _statisticsItemCount() {
    const _db = TautulliDatabase.STATISTICS_STATS_COUNT;
    return _db.listenableBuilder(
      builder: (context, _) {
        String statisticsItems = _db.read() == 1
            ? 'zebrrasea.OneItem'.tr()
            : 'zebrrasea.Items'.tr(args: [_db.read().toString()]);
        return ZebrraBlock(
          title: 'tautulli.StatisticsItemCount'.tr(),
          body: [TextSpan(text: statisticsItems)],
          trailing: const ZebrraIconButton(icon: Icons.format_list_numbered),
          onTap: () async {
            List<dynamic> _values =
                await TautulliDialogs.setStatisticsItemCount(context);
            if (_values[0]) _db.update(_values[1]);
          },
        );
      },
    );
  }
}
