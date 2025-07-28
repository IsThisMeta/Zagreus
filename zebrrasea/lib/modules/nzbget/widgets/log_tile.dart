import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class NZBGetLogTile extends StatelessWidget {
  final NZBGetLogData data;

  const NZBGetLogTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: data.text,
      body: [TextSpan(text: data.timestamp)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async =>
          ZebrraDialogs().textPreview(context, 'Log Entry', data.text!),
    );
  }
}
