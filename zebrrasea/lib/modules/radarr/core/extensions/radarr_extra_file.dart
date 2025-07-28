import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrExtraFileExtension on RadarrExtraFile {
  String get zebrraRelativePath {
    if (this.relativePath?.isNotEmpty ?? false) return this.relativePath!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraExtension {
    if (this.extension?.isNotEmpty ?? false) return this.extension!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraType {
    if (this.type?.isNotEmpty ?? false) return this.type!.toTitleCase();
    return ZebrraUI.TEXT_EMDASH;
  }
}
