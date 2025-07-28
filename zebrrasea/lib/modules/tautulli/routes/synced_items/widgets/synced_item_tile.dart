import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/tautulli.dart';

class TautulliSyncedItemTile extends StatelessWidget {
  final TautulliSyncedItem syncedItem;

  const TautulliSyncedItemTile({
    Key? key,
    required this.syncedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: syncedItem.syncTitle,
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      backgroundHeaders: context.watch<TautulliState>().headers,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromRatingKey(
            syncedItem.ratingKey,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      posterHeaders: context.watch<TautulliState>().headers,
      posterUrl: context.watch<TautulliState>().getImageURLFromRatingKey(
            syncedItem.ratingKey,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      onTap: () async => _onTap(context),
    );
  }

  TextSpan _subtitle1() {
    int _count = syncedItem.itemCompleteCount ?? 0;
    int _size = syncedItem.totalSize ?? 0;
    String _type = syncedItem.metadataType ?? 'zebrrasea.Unknown'.tr();

    return TextSpan(
      children: [
        TextSpan(text: _type.toTitleCase()),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: _count == 1 ? '1 Item' : '$_count Items'),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: _size.asBytes(decimals: 1)),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: syncedItem.user ?? 'Unknown User'),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: syncedItem.deviceName ?? 'Unknown Device'),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: syncedItem.platform ?? 'Unknown Platform'),
      ],
    );
  }

  TextSpan _subtitle3() {
    String _state = syncedItem.state ?? 'zebrrasea.Unknown'.tr();
    return TextSpan(
      text: _state.toTitleCase(),
      style: const TextStyle(
        color: ZebrraColours.accent,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    TautulliRoutes.MEDIA_DETAILS.go(params: {
      'rating_key': syncedItem.ratingKey.toString(),
      'media_type': TautulliMediaType.from(syncedItem.metadataType).value,
    });
  }
}
