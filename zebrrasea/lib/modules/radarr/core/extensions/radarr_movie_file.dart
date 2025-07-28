import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrMovieFileExtension on RadarrMovieFile {
  String get zebrraRelativePath {
    if (this.relativePath?.isNotEmpty ?? false) return this.relativePath!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSize {
    if ((this.size ?? 0) != 0) return this.size.asBytes(decimals: 1);
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraLanguage {
    if (this.languages?.isEmpty ?? true) return ZebrraUI.TEXT_EMDASH;
    return this.languages!.map<String?>((lang) => lang.name).join('\n');
  }

  String get zebrraQuality {
    if (this.quality?.quality?.name != null)
      return this.quality!.quality!.name!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraDateAdded {
    if (this.dateAdded != null)
      return this.dateAdded!.asDateTime(delimiter: '\n');
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraCustomFormats {
    if (this.customFormats != null && this.customFormats!.isNotEmpty)
      return this
          .customFormats!
          .map<String?>((format) => format.name)
          .join('\n');
    return ZebrraUI.TEXT_EMDASH;
  }
}
