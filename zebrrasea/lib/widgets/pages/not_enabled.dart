import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class NotEnabledPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String module;

  NotEnabledPage({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZebrraAppBar(title: module),
      body: ZebrraMessage.moduleNotEnabled(
        context: context,
        module: module,
      ),
    );
  }
}
