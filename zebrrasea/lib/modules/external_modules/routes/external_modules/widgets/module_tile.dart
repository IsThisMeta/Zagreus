import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/external_module.dart';
import 'package:zebrrasea/extensions/string/links.dart';

class ExternalModulesModuleTile extends StatelessWidget {
  final ZebrraExternalModule? module;

  const ExternalModulesModuleTile({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: module!.displayName,
      body: [TextSpan(text: module!.host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: module!.host.openLink,
    );
  }
}
