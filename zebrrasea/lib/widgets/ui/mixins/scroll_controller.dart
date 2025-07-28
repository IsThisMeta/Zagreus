import 'package:flutter/material.dart';

mixin ZebrraScrollControllerMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();

  @mustCallSuper
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
