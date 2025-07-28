import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraReorderableListViewDragger extends StatelessWidget {
  final int index;

  const ZebrraReorderableListViewDragger({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const ZebrraIconButton(
            icon: Icons.menu_rounded,
            mouseCursor: SystemMouseCursors.click,
          ),
        ),
      ],
    );
  }
}
