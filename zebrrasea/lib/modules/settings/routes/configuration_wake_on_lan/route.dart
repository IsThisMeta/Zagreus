import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';

class ConfigurationWakeOnLANRoute extends StatefulWidget {
  const ConfigurationWakeOnLANRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationWakeOnLANRoute> createState() => _State();
}

class _State extends State<ConfigurationWakeOnLANRoute>
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
      scrollControllers: [scrollController],
      title: ZebrraModule.WAKE_ON_LAN.title,
    );
  }

  Widget _body() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraListView(
        controller: scrollController,
        children: [
          ZebrraModule.WAKE_ON_LAN.informationBanner(),
          _enabledToggle(),
          _broadcastAddress(),
          _macAddress(),
        ],
      ),
    );
  }

  Widget _enabledToggle() {
    return ZebrraBlock(
      title: 'settings.EnableModule'.tr(args: [ZebrraModule.WAKE_ON_LAN.title]),
      trailing: ZebrraSwitch(
        value: ZebrraProfile.current.wakeOnLANEnabled,
        onChanged: (value) {
          ZebrraProfile.current.wakeOnLANEnabled = value;
          ZebrraProfile.current.save();
        },
      ),
    );
  }

  Widget _broadcastAddress() {
    String? broadcastAddress = ZebrraProfile.current.wakeOnLANBroadcastAddress;
    return ZebrraBlock(
      title: 'settings.BroadcastAddress'.tr(),
      body: [
        TextSpan(
          text:
              broadcastAddress == '' ? 'zebrrasea.NotSet'.tr() : broadcastAddress,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values =
            await SettingsDialogs().editBroadcastAddress(
          context,
          broadcastAddress,
        );
        if (_values.item1) {
          ZebrraProfile.current.wakeOnLANBroadcastAddress = _values.item2;
          ZebrraProfile.current.save();
        }
      },
    );
  }

  Widget _macAddress() {
    String? macAddress = ZebrraProfile.current.wakeOnLANMACAddress;
    return ZebrraBlock(
      title: 'settings.MACAddress'.tr(),
      body: [
        TextSpan(text: macAddress == '' ? 'zebrrasea.NotSet'.tr() : macAddress),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editMACAddress(
          context,
          macAddress,
        );
        if (_values.item1) {
          ZebrraProfile.current.wakeOnLANMACAddress = _values.item2;
          ZebrraProfile.current.save();
        }
      },
    );
  }
}
