import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliActivityStatus extends StatelessWidget {
  final TautulliActivity? activity;

  const TautulliActivityStatus({
    required this.activity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraHeader(
      text: activity!.zebrraSessionsHeader,
      subtitle: [
        activity!.zebrraSessions,
        activity!.zebrraBandwidth,
      ].join('\n'),
    );
  }
}
