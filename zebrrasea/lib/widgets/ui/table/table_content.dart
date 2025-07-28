import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/extensions/string/links.dart';

enum _Type {
  CONTENT,
  SPACER,
}

class ZebrraTableContent extends StatelessWidget {
  final String? title;
  final String? body;
  final String? url;
  final bool bodyIsUrl;
  final int titleFlex;
  final int bodyFlex;
  final double spacerSize;
  final TextAlign titleAlign;
  final TextAlign bodyAlign;
  final _Type type;

  const ZebrraTableContent._({
    Key? key,
    this.title,
    this.body,
    this.url,
    this.bodyIsUrl = false,
    this.titleAlign = TextAlign.end,
    this.bodyAlign = TextAlign.start,
    this.titleFlex = 5,
    this.bodyFlex = 10,
    this.spacerSize = ZebrraUI.DEFAULT_MARGIN_SIZE,
    required this.type,
  });

  factory ZebrraTableContent.spacer({
    Key? key,
    double spacerSize = ZebrraUI.DEFAULT_MARGIN_SIZE,
  }) =>
      ZebrraTableContent._(
        key: key,
        type: _Type.SPACER,
        spacerSize: spacerSize,
      );

  factory ZebrraTableContent({
    Key? key,
    String? title,
    required String? body,
    String? url,
    bool bodyIsUrl = false,
    TextAlign titleAlign = TextAlign.end,
    TextAlign bodyAlign = TextAlign.start,
    int titleFlex = 1,
    int bodyFlex = 2,
  }) =>
      ZebrraTableContent._(
        key: key,
        title: title,
        body: body,
        url: url,
        bodyIsUrl: bodyIsUrl,
        titleAlign: titleAlign,
        bodyAlign: bodyAlign,
        titleFlex: titleFlex,
        bodyFlex: bodyFlex,
        type: _Type.CONTENT,
      );

  @override
  Widget build(BuildContext context) {
    if (type == _Type.SPACER) return SizedBox(height: spacerSize);
    return Row(
      children: [
        if (title != null) _title(),
        _subtitle(),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _title() {
    return Expanded(
      child: Padding(
        child: Text(
          title?.toUpperCase() ?? ZebrraUI.TEXT_EMDASH,
          textAlign: titleAlign,
          style: const TextStyle(
            color: ZebrraColours.grey,
            fontSize: ZebrraUI.FONT_SIZE_H3,
          ),
        ),
        padding: const EdgeInsets.only(
          top: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
          bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
          right: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
        ),
      ),
      flex: titleFlex,
    );
  }

  Widget _subtitle() {
    return Expanded(
      child: InkWell(
        child: Padding(
          child: Text(
            body ?? ZebrraUI.TEXT_EMDASH,
            textAlign: bodyAlign,
            style: const TextStyle(
              color: ZebrraColours.white,
              fontSize: ZebrraUI.FONT_SIZE_H3,
            ),
          ),
          padding: const EdgeInsets.only(
            top: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
            bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
            left: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
          ),
        ),
        borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
        onTap: _onTap(),
        onLongPress: _onLongPress(),
      ),
      flex: bodyFlex,
    );
  }

  void Function()? _onTap() {
    final sanitizedUrl = url ?? '';
    if (sanitizedUrl.isEmpty && !bodyIsUrl) return null;
    if (sanitizedUrl.isNotEmpty) return sanitizedUrl.openLink;
    return body!.openLink;
  }

  void Function()? _onLongPress() {
    final sanitizedUrl = url ?? '';
    if (sanitizedUrl.isEmpty && !bodyIsUrl) return null;
    if (sanitizedUrl.isNotEmpty) return sanitizedUrl.copyToClipboard;
    return body!.copyToClipboard;
  }
}
