import 'package:flutter/material.dart';

class ZebrraCustomScrollView extends StatelessWidget {
  final ScrollController controller;
  final List<Widget> slivers;

  const ZebrraCustomScrollView({
    super.key,
    required this.controller,
    required this.slivers,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      interactive: true,
      child: CustomScrollView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: slivers,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }
}
