import 'package:flutter/material.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/modules/settings.dart';

class ConfigurationNZBGetConnectionDetailsHeadersRoute extends StatelessWidget {
  const ConfigurationNZBGetConnectionDetailsHeadersRoute({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsHeaderRoute(module: ZebrraModule.NZBGET);
  }
}
