import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraTableCard extends StatelessWidget {
  final String? title;
  final List<ZebrraTableContent>? content;
  final List<ZebrraButton>? buttons;

  const ZebrraTableCard({
    Key? key,
    this.content,
    this.buttons,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Padding(
        child: _body(),
        padding: EdgeInsets.only(
          left: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
          right: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
          top: ZebrraUI.DEFAULT_MARGIN_SIZE - ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
          bottom: buttons?.isEmpty ?? true
              ? ZebrraUI.DEFAULT_MARGIN_SIZE - ZebrraUI.DEFAULT_MARGIN_SIZE / 4
              : 0,
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        if (title?.isNotEmpty ?? false) _title(),
        ..._content(),
        _buttons(),
      ],
    );
  }

  Widget _title() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: ZebrraUI.DEFAULT_MARGIN_SIZE),
          child: ZebrraText.title(text: title!),
        ),
      ],
    );
  }

  List<Widget> _content() {
    return content!
        .map((child) => Padding(
              child: child,
              padding: const EdgeInsets.symmetric(
                horizontal: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
              ),
            ))
        .toList();
  }

  Widget _buttons() {
    if (buttons == null) return Container(height: 0.0);
    return Padding(
      child: Row(
        children:
            buttons!.map<Widget>((button) => Expanded(child: button)).toList(),
      ),
      padding: const EdgeInsets.only(
        top: ZebrraUI.DEFAULT_MARGIN_SIZE / 2 - ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
        bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }
}
