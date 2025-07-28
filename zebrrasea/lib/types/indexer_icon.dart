import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

part 'indexer_icon.g.dart';

const _GENERIC = 'generic';
const _DOGNZB = 'dognzb';
const _DRUNKENSLUG = 'drunkenslug';
const _NZBFINDER = 'nzbfinder';
const _NZBGEEK = 'nzbgeek';
const _NZBHYDRA = 'nzbhydra';
const _NZBSU = 'nzbsu';

@JsonEnum()
@HiveType(typeId: 22, adapterName: 'ZebrraIndexerIconAdapter')
enum ZebrraIndexerIcon {
  @JsonValue(_GENERIC)
  @HiveField(0)
  GENERIC(_GENERIC),

  @JsonValue(_DOGNZB)
  @HiveField(1)
  DOGNZB(_DOGNZB),

  @JsonValue(_DRUNKENSLUG)
  @HiveField(2)
  DRUNKENSLUG(_DRUNKENSLUG),

  @JsonValue(_NZBFINDER)
  @HiveField(3)
  NZBFINDER(_NZBFINDER),

  @JsonValue(_NZBGEEK)
  @HiveField(4)
  NZBGEEK(_NZBGEEK),

  @JsonValue(_NZBHYDRA)
  @HiveField(5)
  NZBHYDRA(_NZBHYDRA),

  @JsonValue(_NZBSU)
  @HiveField(6)
  NZBSU(_NZBSU);

  final String key;
  const ZebrraIndexerIcon(this.key);

  static ZebrraIndexerIcon fromKey(String key) {
    switch (key) {
      case _DOGNZB:
        return ZebrraIndexerIcon.DOGNZB;
      case _DRUNKENSLUG:
        return ZebrraIndexerIcon.DRUNKENSLUG;
      case _NZBFINDER:
        return ZebrraIndexerIcon.NZBFINDER;
      case _NZBGEEK:
        return ZebrraIndexerIcon.NZBGEEK;
      case _NZBHYDRA:
        return ZebrraIndexerIcon.NZBHYDRA;
      case _NZBSU:
        return ZebrraIndexerIcon.NZBSU;
      default:
        return ZebrraIndexerIcon.GENERIC;
    }
  }

  String get name {
    switch (this) {
      case ZebrraIndexerIcon.GENERIC:
        return 'Generic';
      case ZebrraIndexerIcon.DOGNZB:
        return 'DOGnzb';
      case ZebrraIndexerIcon.DRUNKENSLUG:
        return 'DrunkenSlug';
      case ZebrraIndexerIcon.NZBFINDER:
        return 'NZBFinder';
      case ZebrraIndexerIcon.NZBGEEK:
        return 'NZBGeek';
      case ZebrraIndexerIcon.NZBHYDRA:
        return 'NZBHydra2';
      case ZebrraIndexerIcon.NZBSU:
        return 'NZB.su';
    }
  }

  IconData get icon {
    switch (this) {
      case ZebrraIndexerIcon.GENERIC:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.DOGNZB:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.DRUNKENSLUG:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.NZBFINDER:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.NZBGEEK:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.NZBHYDRA:
        return Icons.rss_feed_rounded;
      case ZebrraIndexerIcon.NZBSU:
        return Icons.rss_feed_rounded;
    }
  }
}
