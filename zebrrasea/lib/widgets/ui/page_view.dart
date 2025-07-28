import 'package:flutter/material.dart';

class ZebrraPageView extends StatelessWidget {
  final PageController? controller;
  final List<Widget> children;

  const ZebrraPageView({
    Key? key,
    this.controller,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: children,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
