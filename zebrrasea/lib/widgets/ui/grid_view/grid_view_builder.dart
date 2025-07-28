import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraGridViewBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? itemExtent;
  final EdgeInsets? padding;
  final ScrollPhysics physics;
  final ScrollController controller;
  final SliverGridDelegate sliverGridDelegate;

  const ZebrraGridViewBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.sliverGridDelegate,
    this.itemExtent,
    required this.controller,
    this.padding,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      interactive: true,
      child: GridView.builder(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding ?? _defaultPadding(context),
        physics: physics,
        itemCount: itemCount,
        gridDelegate: sliverGridDelegate,
        itemBuilder: itemBuilder,
      ),
    );
  }

  EdgeInsets _defaultPadding(BuildContext context) {
    return MediaQuery.of(context).padding.add(ZebrraUI.MARGIN_HALF) as EdgeInsets;
  }
}
