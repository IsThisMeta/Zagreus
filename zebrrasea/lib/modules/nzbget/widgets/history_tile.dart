import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class NZBGetHistoryTile extends StatefulWidget {
  final NZBGetHistoryData data;
  final Function() refresh;

  const NZBGetHistoryTile({
    Key? key,
    required this.data,
    required this.refresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<NZBGetHistoryTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: widget.data.name,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableContent: _expandedTableContent(),
      expandedTableButtons: _expandedTableButtons(),
      onLongPress: () async => _handlePopup(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(text: widget.data.completeTime),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.data.sizeReadable),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(
            text: (widget.data.category ?? '').isEmpty
                ? 'No Category'
                : widget.data.category),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      text: widget.data.statusString,
      style: TextStyle(
        color: widget.data.statusColor,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  List<ZebrraHighlightedNode> _expandedHighlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: widget.data.statusString,
        backgroundColor: widget.data.statusColor,
      ),
      ZebrraHighlightedNode(
        text: widget.data.healthString,
        backgroundColor: ZebrraColours.blueGrey,
      )
    ];
  }

  List<ZebrraTableContent> _expandedTableContent() {
    return [
      ZebrraTableContent(title: 'age', body: widget.data.completeTime),
      ZebrraTableContent(title: 'size', body: widget.data.sizeReadable),
      ZebrraTableContent(
          title: 'category',
          body: (widget.data.category ?? '').isEmpty
              ? 'No Category'
              : widget.data.category),
      ZebrraTableContent(title: 'speed', body: widget.data.downloadSpeed),
      ZebrraTableContent(title: 'path', body: widget.data.storageLocation),
    ];
  }

  List<ZebrraButton> _expandedTableButtons() {
    return [
      ZebrraButton.text(
        text: 'Delete',
        icon: Icons.delete_rounded,
        color: ZebrraColours.red,
        onTap: () async => _deleteButton(),
      ),
    ];
  }

  Future<void> _handlePopup() async {
    List values =
        await NZBGetDialogs.historySettings(context, widget.data.name);
    if (values[0])
      switch (values[1]) {
        case 'retry':
          {
            await NZBGetAPI.from(ZebrraProfile.current)
                .retryHistoryEntry(widget.data.id)
                .then((_) {
              widget.refresh();
              showZebrraSuccessSnackBar(
                title: 'Retrying Job...',
                message: widget.data.name,
              );
            }).catchError((error) {
              showZebrraErrorSnackBar(
                title: 'Failed to Retry Job',
                error: error,
              );
            });
            break;
          }
        case 'hide':
          await NZBGetAPI.from(ZebrraProfile.current)
              .deleteHistoryEntry(widget.data.id, hide: true)
              .then((_) => _handleDelete('History Hidden'))
              .catchError((error) => showZebrraErrorSnackBar(
                    title: 'Failed to Hide History',
                    error: error,
                  ));
          break;
        case 'delete':
          await NZBGetAPI.from(ZebrraProfile.current)
              .deleteHistoryEntry(widget.data.id, hide: true)
              .then((_) => _handleDelete('History Deleted'))
              .catchError((error) => showZebrraErrorSnackBar(
                    title: 'Failed to Delete History',
                    error: error,
                  ));
      }
  }

  Future<void> _deleteButton() async {
    List<dynamic> values = await NZBGetDialogs.deleteHistory(context);
    if (values[0])
      await NZBGetAPI.from(ZebrraProfile.current)
          .deleteHistoryEntry(
            widget.data.id,
            hide: values[1],
          )
          .then((_) =>
              _handleDelete(values[1] ? 'History Hidden' : 'History Deleted'))
          .catchError((error) => showZebrraErrorSnackBar(
                title: 'Failed to Delete History',
                error: error,
              ));
  }

  void _handleDelete(String title) {
    showZebrraSuccessSnackBar(
      title: title,
      message: widget.data.name,
    );
    widget.refresh();
  }
}
