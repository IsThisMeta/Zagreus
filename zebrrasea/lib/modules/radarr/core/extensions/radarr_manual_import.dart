import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrManualImportExtension on RadarrManualImport {
  String? get zebrraLanguage {
    if ((this.languages?.length ?? 0) > 1) return 'Multi-Language';
    if ((this.languages?.length ?? 0) == 1) return this.languages![0].name;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraQualityProfile {
    return this.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSize {
    return this.size.asBytes();
  }

  String get zebrraMovie {
    if (this.movie == null) return ZebrraUI.TEXT_EMDASH;
    String title = this.movie!.title ?? ZebrraUI.TEXT_EMDASH;
    int? year = (this.movie!.year ?? 0) == 0 ? null : this.movie!.year;
    return [
      title,
      if (year != null) '($year)',
    ].join(' ');
  }
}
