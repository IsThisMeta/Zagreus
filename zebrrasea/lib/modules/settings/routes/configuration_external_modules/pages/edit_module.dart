import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class ConfigurationExternalModulesEditRoute extends StatefulWidget {
  final int moduleId;

  const ConfigurationExternalModulesEditRoute({
    Key? key,
    required this.moduleId,
  }) : super(key: key);

  @override
  State<ConfigurationExternalModulesEditRoute> createState() => _State();
}

class _State extends State<ConfigurationExternalModulesEditRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraExternalModule? _module;

  @override
  Widget build(BuildContext context) {
    if (widget.moduleId < 0 ||
        !ZebrraBox.externalModules.contains(widget.moduleId)) {
      return InvalidRoutePage(
        title: 'settings.EditModule'.tr(),
        message: 'settings.ModuleNotFound'.tr(),
      );
    }
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
      title: 'settings.EditModule'.tr(),
    );
  }

  Widget _bottomNavigationBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'settings.DeleteModule'.tr(),
          icon: Icons.delete_rounded,
          color: ZebrraColours.red,
          onTap: () async {
            bool result = await SettingsDialogs().deleteExternalModule(context);
            if (result) {
              showZebrraSuccessSnackBar(
                  title: 'settings.DeleteModuleSuccess'.tr(),
                  message: _module!.displayName);
              _module!.delete();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZebrraBox.externalModules.listenableBuilder(
      selectKeys: [widget.moduleId],
      builder: (context, dynamic _) {
        if (!ZebrraBox.externalModules.contains(widget.moduleId))
          return Container();
        _module = ZebrraBox.externalModules.read(widget.moduleId);
        return ZebrraListView(
          controller: scrollController,
          children: [
            _displayNameTile(),
            _hostTile(),
          ],
        );
      },
    );
  }

  Widget _displayNameTile() {
    String _displayName = _module!.displayName;
    return ZebrraBlock(
      title: 'settings.DisplayName'.tr(),
      body: [
        TextSpan(
          text: _displayName.isEmpty ? 'zebrrasea.NotSet'.tr() : _displayName,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZebrraDialogs().editText(
          context,
          'settings.DisplayName'.tr(),
          prefill: _displayName,
        );
        if (values.item1) _module!.displayName = values.item2;
        _module!.save();
      },
    );
  }

  Widget _hostTile() {
    String _host = _module!.host;
    return ZebrraBlock(
      title: 'settings.Host'.tr(),
      body: [
        TextSpan(text: _host.isEmpty ? 'zebrrasea.NotSet'.tr() : _host),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values =
            await SettingsDialogs().editExternalModuleHost(
          context,
          prefill: _host,
        );
        if (values.item1) _module!.host = values.item2;
        _module!.save();
      },
    );
  }
}
