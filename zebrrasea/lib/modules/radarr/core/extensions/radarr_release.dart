import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/double/time.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension RadarrReleaseExtension on RadarrRelease {
  IconData get zebrraTrailingIcon {
    if (this.approved!) return Icons.download_rounded;
    return Icons.report_outlined;
  }

  Color get zebrraTrailingColor {
    if (this.approved!) return Colors.white;
    return ZebrraColours.red;
  }

  String? get zebrraProtocol {
    if (this.protocol != null)
      return this.protocol == RadarrProtocol.TORRENT
          ? '${this.protocol!.readable} (${this.seeders ?? 0}/${this.leechers ?? 0})'
          : this.protocol!.readable;
    return ZebrraUI.TEXT_EMDASH;
  }

  Color get zebrraProtocolColor {
    if (this.protocol == RadarrProtocol.USENET) return ZebrraColours.accent;
    int seeders = this.seeders ?? 0;
    if (seeders > 10) return ZebrraColours.blue;
    if (seeders > 0) return ZebrraColours.orange;
    return ZebrraColours.red;
  }

  String? get zebrraIndexer {
    if (this.indexer != null && this.indexer!.isNotEmpty) return this.indexer;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraAge {
    if (this.ageHours != null) return this.ageHours!.asTimeAgo();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraQuality {
    if (this.quality != null && this.quality!.quality != null)
      return this.quality!.quality!.name;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSize {
    if (this.size != null) return this.size.asBytes();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? zebrraCustomFormatScore({bool nullOnEmpty = false}) {
    if ((this.customFormatScore ?? 0) != 0) {
      String _prefix = this.customFormatScore! > 0 ? '+' : '';
      return '$_prefix${this.customFormatScore}';
    }
    if (nullOnEmpty) return null;
    return ZebrraUI.TEXT_EMDASH;
  }
}
