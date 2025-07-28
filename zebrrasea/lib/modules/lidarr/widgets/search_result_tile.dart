import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/double/time.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/router.dart';

class LidarrReleasesTile extends StatefulWidget {
  final LidarrReleaseData release;

  const LidarrReleasesTile({
    Key? key,
    required this.release,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LidarrReleasesTile> {
  ZebrraLoadingState _downloadState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: widget.release.title,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      collapsedTrailing: _trailing(),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(
        style: TextStyle(
          color: zebrraProtocolColor,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
        text: widget.release.protocol.toTitleCase(),
      ),
      if (widget.release.isTorrent)
        TextSpan(
          text: ' (${widget.release.seeders}/${widget.release.leechers})',
          style: TextStyle(
            color: zebrraProtocolColor,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.release.indexer),
      TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.release.ageHours.asTimeAgo()),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.release.quality),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.size.asBytes()),
      ],
    );
  }

  Widget _trailing() {
    return ZebrraIconButton(
      icon: widget.release.approved
          ? Icons.file_download_rounded
          : Icons.report_outlined,
      color: widget.release.approved ? Colors.white : ZebrraColours.red,
      onPressed: () async =>
          widget.release.approved ? _startDownload() : _showWarnings(),
      onLongPress: _startDownload,
      loadingState: _downloadState,
    );
  }

  List<ZebrraHighlightedNode> _highlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: widget.release.protocol.toTitleCase(),
        backgroundColor: zebrraProtocolColor,
      ),
    ];
  }

  List<ZebrraTableContent> _tableContent() {
    return [
      ZebrraTableContent(
          title: 'source', body: widget.release.protocol.toTitleCase()),
      ZebrraTableContent(title: 'age', body: widget.release.ageHours.asTimeAgo()),
      ZebrraTableContent(title: 'indexer', body: widget.release.indexer),
      ZebrraTableContent(title: 'size', body: widget.release.size.asBytes()),
      ZebrraTableContent(title: 'quality', body: widget.release.quality),
      if (widget.release.protocol == 'torrent' &&
          widget.release.seeders != null)
        ZebrraTableContent(title: 'seeders', body: '${widget.release.seeders}'),
      if (widget.release.protocol == 'torrent' &&
          widget.release.leechers != null)
        ZebrraTableContent(title: 'leechers', body: '${widget.release.leechers}'),
    ];
  }

  Color get zebrraProtocolColor {
    if (!widget.release.isTorrent) return ZebrraColours.accent;
    int seeders = widget.release.seeders ?? 0;
    if (seeders > 10) return ZebrraColours.blue;
    if (seeders > 0) return ZebrraColours.orange;
    return ZebrraColours.red;
  }

  List<ZebrraButton> _tableButtons() {
    return [
      ZebrraButton(
        type: ZebrraButtonType.TEXT,
        icon: Icons.download_rounded,
        text: 'Download',
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
      if (widget.release.infoUrl.isNotEmpty)
        ZebrraButton.text(
          text: 'Indexer',
          icon: Icons.info_outline_rounded,
          color: ZebrraColours.blue,
          onTap: widget.release.infoUrl.openLink,
        ),
      if (!widget.release.approved)
        ZebrraButton.text(
          text: 'Rejected',
          icon: Icons.report_outlined,
          color: ZebrraColours.red,
          onTap: _showWarnings,
        ),
    ];
  }

  Future<void> _startDownload() async {
    setState(() => _downloadState = ZebrraLoadingState.ACTIVE);
    LidarrAPI _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .downloadRelease(widget.release.guid, widget.release.indexerId)
        .then((_) {
      showZebrraSuccessSnackBar(
        title: 'Downloading...',
        message: widget.release.title,
        showButton: true,
        buttonText: 'Back',
        buttonOnPressed: ZebrraRouter().popToRootRoute,
      );
    }).catchError((error, stack) {
      showZebrraErrorSnackBar(
        title: 'Failed to Start Downloading',
        error: error,
      );
    });
    setState(() => _downloadState = ZebrraLoadingState.INACTIVE);
  }

  Future<void> _showWarnings() async => await ZebrraDialogs().showRejections(
        context,
        widget.release.rejections.cast<String>(),
      );
}
