import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';
import 'package:zebrrasea/router/routes/sabnzbd.dart';

class SABnzbdHistoryTile extends StatefulWidget {
  final SABnzbdHistoryData data;
  final Function() refresh;

  const SABnzbdHistoryTile({
    Key? key,
    required this.data,
    required this.refresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SABnzbdHistoryTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: widget.data.name,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedTableContent: _expandedTableContent(),
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableButtons: _expandedButtons(),
      onLongPress: () async => _handlePopup(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(text: widget.data.completeTimeString),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.data.sizeReadable),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.data.category),
    ]);
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

  List<ZebrraTableContent> _expandedTableContent() {
    return [
      ZebrraTableContent(title: 'age', body: widget.data.completeTimeString),
      ZebrraTableContent(title: 'size', body: widget.data.sizeReadable),
      ZebrraTableContent(title: 'category', body: widget.data.category),
      ZebrraTableContent(title: 'path', body: widget.data.storageLocation),
    ];
  }

  List<ZebrraHighlightedNode> _expandedHighlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: widget.data.status,
        backgroundColor: widget.data.statusColor,
      ),
    ];
  }

  List<ZebrraButton> _expandedButtons() {
    return [
      ZebrraButton.text(
        text: 'Stages',
        icon: Icons.subject_rounded,
        onTap: () async => _enterStages(),
      ),
      ZebrraButton.text(
        text: 'Delete',
        icon: Icons.delete_rounded,
        color: ZebrraColours.red,
        onTap: () async => _delete(),
      ),
    ];
  }

  Future<void> _enterStages() async {
    return SABnzbdRoutes.HISTORY_STAGES.go(
      extra: widget.data,
    );
  }

  Future<void> _handlePopup() async {
    List values = await SABnzbdDialogs.historySettings(
        context, widget.data.name, widget.data.failed);
    if (values[0])
      switch (values[1]) {
        case 'retry':
          _retry();
          break;
        case 'password':
          _password();
          break;
        case 'delete':
          _delete();
          break;
        default:
          ZebrraLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _delete() async {
    List values = await SABnzbdDialogs.deleteHistory(context);
    if (values[0]) {
      SABnzbdAPI.from(ZebrraProfile.current)
          .deleteHistory(widget.data.nzoId)
          .then((_) => _handleRefresh('History Deleted'))
          .catchError((error) => showZebrraErrorSnackBar(
                title: 'Failed to Delete History',
                error: error,
              ));
    }
  }

  Future<void> _password() async {
    List values = await SABnzbdDialogs.setPassword(context);
    if (values[0])
      SABnzbdAPI.from(ZebrraProfile.current)
          .retryFailedJobPassword(widget.data.nzoId, values[1])
          .then((_) => _handleRefresh('Password Set / Retrying...'))
          .catchError((error) => showZebrraErrorSnackBar(
                title: 'Failed to Set Password / Retry Job',
                error: error,
              ));
  }

  Future<void> _retry() async {
    SABnzbdAPI.from(ZebrraProfile.current)
        .retryFailedJob(widget.data.nzoId)
        .then((_) => _handleRefresh('Retrying Job'))
        .catchError((error) => showZebrraErrorSnackBar(
              title: 'Failed to Retry Job',
              error: error,
            ));
  }

  void _handleRefresh(String title) {
    showZebrraSuccessSnackBar(
      title: title,
      message: widget.data.name,
    );
    widget.refresh();
  }
}
