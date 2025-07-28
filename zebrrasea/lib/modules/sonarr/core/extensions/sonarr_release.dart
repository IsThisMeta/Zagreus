import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/double/time.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrReleaseExtension on SonarrRelease {
  IconData get zebrraTrailingIcon {
    if (this.approved!) return Icons.download_rounded;
    return Icons.report_outlined;
  }

  Color get zebrraTrailingColor {
    if (this.approved!) return Colors.white;
    return ZebrraColours.red;
  }

  String get zebrraProtocol {
    if (this.protocol != null) {
      return this.protocol == SonarrProtocol.TORRENT
          ? '${this.protocol!.zebrraReadable()} (${this.seeders ?? 0}/${this.leechers ?? 0})'
          : this.protocol!.zebrraReadable();
    }
    return ZebrraUI.TEXT_EMDASH;
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

  String? get zebrraLanguage {
    if (this.language != null && this.language != null)
      return this.language!.name;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSize {
    if (this.size != null) return this.size.asBytes();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? zebrraPreferredWordScore({bool nullOnEmpty = false}) {
    if ((this.preferredWordScore ?? 0) != 0) {
      String _prefix = this.preferredWordScore! > 0 ? '+' : '';
      return '$_prefix${this.preferredWordScore}';
    }
    if (nullOnEmpty) return null;
    return ZebrraUI.TEXT_EMDASH;
  }
}
