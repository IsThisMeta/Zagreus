import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrReleasesTile extends StatefulWidget {
  final RadarrRelease release;

  const RadarrReleasesTile({
    required this.release,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrReleasesTile> {
  ZebrraLoadingState _downloadState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: widget.release.title!,
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

  Widget _trailing() {
    return ZebrraIconButton(
      icon: widget.release.zebrraTrailingIcon,
      color: widget.release.zebrraTrailingColor,
      onPressed: () async =>
          widget.release.rejected! ? _showWarnings() : _startDownload(),
      onLongPress: _startDownload,
      loadingState: _downloadState,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.release.zebrraProtocol,
          style: TextStyle(
            color: widget.release.zebrraProtocolColor,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zebrraIndexer),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zebrraAge),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.release.zebrraQuality),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zebrraSize),
      ],
    );
  }

  List<ZebrraHighlightedNode> _highlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: widget.release.protocol!.readable!,
        backgroundColor: widget.release.zebrraProtocolColor,
      ),
      if (widget.release.zebrraCustomFormatScore(nullOnEmpty: true) != null)
        ZebrraHighlightedNode(
          text: widget.release.zebrraCustomFormatScore()!,
          backgroundColor: ZebrraColours.purple,
        ),
      ...widget.release.customFormats!.map<ZebrraHighlightedNode>((custom) =>
          ZebrraHighlightedNode(
              text: custom.name!, backgroundColor: ZebrraColours.blueGrey)),
    ];
  }

  List<ZebrraTableContent> _tableContent() {
    return [
      ZebrraTableContent(title: 'age', body: widget.release.zebrraAge),
      ZebrraTableContent(title: 'indexer', body: widget.release.zebrraIndexer),
      ZebrraTableContent(title: 'size', body: widget.release.zebrraSize),
      ZebrraTableContent(
          title: 'language',
          body: widget.release.languages
                  ?.map<String>(
                      (language) => language.name ?? ZebrraUI.TEXT_EMDASH)
                  .join('\n') ??
              ZebrraUI.TEXT_EMDASH),
      ZebrraTableContent(title: 'quality', body: widget.release.zebrraQuality),
      if (widget.release.seeders != null)
        ZebrraTableContent(title: 'seeders', body: '${widget.release.seeders}'),
      if (widget.release.leechers != null)
        ZebrraTableContent(title: 'leechers', body: '${widget.release.leechers}'),
    ];
  }

  List<ZebrraButton> _tableButtons() {
    return [
      ZebrraButton(
        type: ZebrraButtonType.TEXT,
        text: 'Download',
        icon: Icons.download_rounded,
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
      if (widget.release.infoUrl?.isNotEmpty ?? false)
        ZebrraButton.text(
          text: 'Indexer',
          icon: Icons.info_outline_rounded,
          color: ZebrraColours.blue,
          onTap: widget.release.infoUrl!.openLink,
        ),
      if (widget.release.rejected!)
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
    RadarrAPIHelper()
        .pushRelease(context: context, release: widget.release)
        .then((value) {
      if (mounted)
        setState(() => _downloadState =
            value ? ZebrraLoadingState.INACTIVE : ZebrraLoadingState.ERROR);
    });
  }

  Future<void> _showWarnings() async => await ZebrraDialogs()
      .showRejections(context, widget.release.rejections ?? []);
}
