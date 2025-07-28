import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrReleasesTile extends StatefulWidget {
  final SonarrRelease release;

  const SonarrReleasesTile({
    required this.release,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrReleasesTile> {
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
            color: widget.release.protocol!.zebrraProtocolColor(
              release: widget.release,
            ),
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
    String? _preferredWordScore =
        widget.release.zebrraPreferredWordScore(nullOnEmpty: true);
    return TextSpan(
      children: [
        if (_preferredWordScore != null)
          TextSpan(
            text: _preferredWordScore,
            style: const TextStyle(
              color: ZebrraColours.purple,
              fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
            ),
          ),
        if (_preferredWordScore != null)
          TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zebrraQuality),
        if (widget.release.language != null)
          TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        if (widget.release.language != null)
          TextSpan(text: widget.release.zebrraLanguage),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zebrraSize),
      ],
    );
  }

  List<ZebrraHighlightedNode> _highlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: widget.release.protocol!.zebrraReadable(),
        backgroundColor: widget.release.protocol!.zebrraProtocolColor(
          release: widget.release,
        ),
      ),
      if (widget.release.zebrraPreferredWordScore(nullOnEmpty: true) != null)
        ZebrraHighlightedNode(
          text: widget.release.zebrraPreferredWordScore()!,
          backgroundColor: ZebrraColours.purple,
        ),
    ];
  }

  List<ZebrraTableContent> _tableContent() {
    return [
      ZebrraTableContent(
        title: 'sonarr.Age'.tr(),
        body: widget.release.zebrraAge,
      ),
      ZebrraTableContent(
        title: 'sonarr.Indexer'.tr(),
        body: widget.release.zebrraIndexer,
      ),
      ZebrraTableContent(
        title: 'sonarr.Size'.tr(),
        body: widget.release.zebrraSize,
      ),
      if (widget.release.language != null)
        ZebrraTableContent(
          title: 'sonarr.Language'.tr(),
          body: widget.release.zebrraLanguage,
        ),
      ZebrraTableContent(
        title: 'sonarr.Quality'.tr(),
        body: widget.release.zebrraQuality,
      ),
      if (widget.release.seeders != null)
        ZebrraTableContent(
          title: 'sonarr.Seeders'.tr(),
          body: '${widget.release.seeders}',
        ),
      if (widget.release.leechers != null)
        ZebrraTableContent(
          title: 'sonarr.Leechers'.tr(),
          body: '${widget.release.leechers}',
        ),
    ];
  }

  List<ZebrraButton> _tableButtons() {
    return [
      ZebrraButton(
        type: ZebrraButtonType.TEXT,
        text: 'sonarr.Download'.tr(),
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
          text: 'sonarr.Rejected'.tr(),
          icon: Icons.report_outlined,
          color: ZebrraColours.red,
          onTap: _showWarnings,
        ),
    ];
  }

  Future<void> _startDownload() async {
    Future<void> setDownloadState(ZebrraLoadingState state) async {
      if (this.mounted) setState(() => _downloadState = state);
    }

    setDownloadState(ZebrraLoadingState.ACTIVE);
    SonarrAPIController()
        .downloadRelease(
          context: context,
          release: widget.release,
        )
        .whenComplete(() async => setDownloadState(ZebrraLoadingState.INACTIVE));
  }

  Future<void> _showWarnings() async => await ZebrraDialogs()
      .showRejections(context, widget.release.rejections ?? []);
}
