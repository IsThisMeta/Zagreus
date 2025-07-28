import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliHistoryDetailsInformation extends StatelessWidget {
  final TautulliHistoryRecord history;
  final ScrollController scrollController;

  const TautulliHistoryDetailsInformation({
    Key? key,
    required this.history,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraListView(
      controller: scrollController,
      children: [
        const ZebrraHeader(text: 'Metadata'),
        _metadataBlock(),
        const ZebrraHeader(text: 'Session'),
        _sessionBlock(),
        const ZebrraHeader(text: 'Player'),
        _playerBlock(),
      ],
    );
  }

  Widget _metadataBlock() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'status', body: history.lsStatus),
        ZebrraTableContent(title: 'title', body: history.lsFullTitle),
        if (history.year != null)
          ZebrraTableContent(title: 'year', body: history.year.toString()),
        ZebrraTableContent(title: 'user', body: history.friendlyName),
      ],
    );
  }

  Widget _sessionBlock() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'state', body: history.lsState),
        ZebrraTableContent(
            title: 'date',
            body: DateFormat('yyyy-MM-dd').format(history.date!)),
        ZebrraTableContent(title: 'started', body: history.date!.asTimeOnly()),
        ZebrraTableContent(
            title: 'stopped',
            body: history.state == null
                ? history.stopped!.asTimeOnly()
                : ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'paused', body: history.pausedCounter!.asWordsTimestamp()),
      ],
    );
  }

  Widget _playerBlock() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'location', body: history.ipAddress),
        ZebrraTableContent(title: 'platform', body: history.platform),
        ZebrraTableContent(title: 'product', body: history.product),
        ZebrraTableContent(title: 'player', body: history.player),
      ],
    );
  }
}
