import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class NZBGetHistoryHideButton extends StatefulWidget {
  final ScrollController controller;

  const NZBGetHistoryHideButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<NZBGetHistoryHideButton> createState() => _State();
}

class _State extends State<NZBGetHistoryHideButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        child: Consumer<NZBGetState>(
          builder: (context, model, widget) => ZebrraIconButton(
            icon: model.historyHideFailed
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            onPressed: () => model.historyHideFailed = !model.historyHideFailed,
          ),
        ),
        height: ZebrraTextInputBar.defaultHeight,
        width: ZebrraTextInputBar.defaultHeight,
        margin: const EdgeInsets.only(left: 12.0),
        color: Theme.of(context).canvasColor,
      );
}
