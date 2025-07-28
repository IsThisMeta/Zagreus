import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSonarrRoute extends StatefulWidget {
  const ConfigurationSonarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSonarrRoute> createState() => _State();
}

class _State extends State<ConfigurationSonarrRoute>
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
      title: ZebrraModule.SONARR.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraModule.SONARR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZebrraDivider(),
        _defaultOptionsPage(),
        _defaultPagesPage(),
        _queueSize(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.EnableModule'.tr(args: [ZebrraModule.SONARR.title]),
        trailing: ZebrraSwitch(
          value: ZebrraProfile.current.sonarrEnabled,
          onChanged: (value) {
            ZebrraProfile.current.sonarrEnabled = value;
            ZebrraProfile.current.save();
            context.read<SonarrState>().reset();
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
            args: [ZebrraModule.SONARR.title],
          ),
        )
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZebrraBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_PAGES.go,
    );
  }

  Widget _defaultOptionsPage() {
    return ZebrraBlock(
      title: 'settings.DefaultOptions'.tr(),
      body: [
        TextSpan(text: 'settings.DefaultOptionsDescription'.tr()),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_OPTIONS.go,
    );
  }

  Widget _queueSize() {
    const _db = SonarrDatabase.QUEUE_PAGE_SIZE;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'sonarr.QueueSize'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'zebrrasea.OneItem'.tr()
                : 'zebrrasea.Items'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZebrraIconButton(icon: Icons.queue_play_next_rounded),
        onTap: () async {
          Tuple2<bool, int> result =
              await SonarrDialogs().setQueuePageSize(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }
}
