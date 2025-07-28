import 'package:flutter/material.dart';
import 'package:zebrrasea/widgets/ui.dart';

class ErrorRoutePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Exception? exception;

  ErrorRoutePage({
    Key? key,
    this.exception,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZebrraAppBar(
        title: 'ZebrraSea',
        scrollControllers: const [],
      ),
      body: ZebrraMessage.goBack(
        context: context,
        text: exception?.toString() ?? '404: Not Found',
      ),
    );
  }
}
