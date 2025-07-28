import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/search.dart';

class SearchResultTile extends StatelessWidget {
  final NewznabResultData data;

  const SearchResultTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: data.title,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedTableContent: _tableContent(),
      collapsedTrailing: _trailing(context),
      expandedTableButtons: _tableButtons(context),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(text: data.size.asBytes()),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: data.category),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(text: data.age);
  }

  List<ZebrraTableContent> _tableContent() {
    return [
      ZebrraTableContent(title: 'search.Age'.tr(), body: data.age),
      ZebrraTableContent(title: 'search.Size'.tr(), body: data.size.asBytes()),
      ZebrraTableContent(title: 'search.Category'.tr(), body: data.category),
      if (SearchDatabase.SHOW_LINKS.read())
        ZebrraTableContent(title: '', body: ''),
      if (SearchDatabase.SHOW_LINKS.read())
        ZebrraTableContent(
            title: 'search.Comments'.tr(),
            body: data.linkComments,
            bodyIsUrl: true),
      if (SearchDatabase.SHOW_LINKS.read())
        ZebrraTableContent(
            title: 'search.Download'.tr(),
            body: data.linkDownload,
            bodyIsUrl: true),
    ];
  }

  List<ZebrraButton> _tableButtons(BuildContext context) {
    return [
      ZebrraButton.text(
        icon: Icons.download_rounded,
        text: 'search.Download'.tr(),
        onTap: () async => _sendToClient(context),
      ),
    ];
  }

  ZebrraIconButton _trailing(BuildContext context) {
    return ZebrraIconButton(
      icon: Icons.download_rounded,
      onPressed: () => _sendToClient(context),
    );
  }

  Future<void> _sendToClient(BuildContext context) async {
    Tuple2<bool, SearchDownloadType?> result =
        await SearchDialogs().downloadResult(context);
    if (result.item1) result.item2!.execute(context, data);
  }
}
