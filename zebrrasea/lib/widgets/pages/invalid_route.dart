import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class InvalidRoutePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? title;
  final String? message;
  final Exception? exception;

  InvalidRoutePage({
    Key? key,
    this.title,
    this.message,
    this.exception,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZebrraAppBar(
        title: title ?? 'ZebrraSea',
        scrollControllers: const [],
      ),
      body: ZebrraMessage.goBack(
        context: context,
        text: exception?.toString() ?? message ?? '404: Not Found',
      ),
    );
  }
}
