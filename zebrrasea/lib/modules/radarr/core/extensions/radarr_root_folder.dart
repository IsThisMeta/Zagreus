import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrRootFolderExtension on RadarrRootFolder? {
  String get zebrraPath {
    if (this?.path?.isNotEmpty ?? false) return this!.path!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSpace {
    return this?.freeSpace.asBytes() ?? ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraUnmappedFolders {
    int length = this?.unmappedFolders?.length ?? 0;
    if (this!.unmappedFolders!.length == 1) return 'radarr.UnmappedFolder'.tr();
    return 'radarr.UnmappedFolders'.tr(args: [length.toString()]);
  }
}
