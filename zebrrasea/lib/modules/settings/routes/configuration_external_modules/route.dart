import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationExternalModulesRoute extends StatefulWidget {
  const ConfigurationExternalModulesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationExternalModulesRoute> createState() => _State();
}

class _State extends State<ConfigurationExternalModulesRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      scrollControllers: [scrollController],
      title: ZebrraModule.EXTERNAL_MODULES.title,
    );
  }

  Widget _bottomNavigationBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'settings.AddModule'.tr(),
          icon: Icons.add_rounded,
          onTap: SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_ADD.go,
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraBox.externalModules.listenableBuilder(
      builder: (context, _) => ZebrraListView(
        controller: scrollController,
        children: [
          ZebrraModule.EXTERNAL_MODULES.informationBanner(),
          ..._moduleSection(),
        ],
      ),
    );
  }

  List<Widget> _moduleSection() => [
        if (ZebrraBox.externalModules.isEmpty)
          ZebrraMessage(text: 'settings.NoExternalModulesFound'.tr()),
        ..._modules,
      ];

  List<Widget> get _modules {
    final modules = ZebrraBox.externalModules.data.toList();
    modules.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    List<ZebrraBlock> list = List.generate(
      modules.length,
      (index) => _moduleTile(modules[index], modules[index].key) as ZebrraBlock,
    );
    return list;
  }

  Widget _moduleTile(ZebrraExternalModule module, int index) {
    return ZebrraBlock(
      title: module.displayName,
      body: [TextSpan(text: module.host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_EDIT.go(params: {
          'id': index.toString(),
        });
      },
    );
  }
}
