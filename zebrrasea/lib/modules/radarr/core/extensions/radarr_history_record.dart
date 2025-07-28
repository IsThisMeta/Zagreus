import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrHistoryRecord on RadarrHistoryRecord {
  String get zebrraFileDeletedReasonMessage {
    if (this.eventType != RadarrEventType.MOVIE_FILE_DELETED ||
        this.data!['reason'] == null) return ZebrraUI.TEXT_EMDASH;
    switch (this.data!['reason']) {
      case 'Manual':
        return 'File was deleted manually';
      case 'MissingFromDisk':
        return 'Unable to find the file on disk';
      case 'Upgrade':
        return 'File was deleted to import an upgrade';
      default:
        return ZebrraUI.TEXT_EMDASH;
    }
  }
}
