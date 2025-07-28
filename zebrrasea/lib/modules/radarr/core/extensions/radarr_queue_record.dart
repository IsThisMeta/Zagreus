import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrQueueRecord on RadarrQueueRecord {
  String get zebrraQuality {
    return this.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraLanguage {
    if ((this.languages?.length ?? 0) == 0) return ZebrraUI.TEXT_EMDASH;
    if (this.languages!.length == 1)
      return this.languages![0].name ?? ZebrraUI.TEXT_EMDASH;
    return 'Multi-Language';
  }

  String zebrraMovieTitle(RadarrMovie movie) {
    String title = movie.title ?? ZebrraUI.TEXT_EMDASH;
    String year = movie.zebrraYear;
    return '$title ($year)';
  }

  String? get zebrraDownloadClient {
    if ((this.downloadClient ?? '').isNotEmpty) return this.downloadClient;
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraIndexer {
    if ((this.indexer ?? '').isNotEmpty) return this.indexer;
    return ZebrraUI.TEXT_EMDASH;
  }

  Color get zebrraProtocolColor {
    if (this.protocol == RadarrProtocol.USENET) return ZebrraColours.accent;
    return ZebrraColours.blue;
  }

  int get zebrraPercentageComplete {
    if (this.sizeLeft == null || this.size == null || this.size == 0) return 0;
    double sizeFetched = this.size! - this.sizeLeft!;
    return ((sizeFetched / this.size!) * 100).round();
  }

  IconData get zebrraStatusIcon {
    switch (this.status) {
      case RadarrQueueRecordStatus.DELAY:
        return Icons.access_time_rounded;
      case RadarrQueueRecordStatus.DOWNLOAD_CLIENT_UNAVAILABLE:
        return Icons.access_time_rounded;
      case RadarrQueueRecordStatus.FAILED:
        return Icons.cloud_download_rounded;
      case RadarrQueueRecordStatus.PAUSED:
        return Icons.pause_rounded;
      case RadarrQueueRecordStatus.QUEUED:
        return Icons.cloud_rounded;
      case RadarrQueueRecordStatus.WARNING:
        return Icons.cloud_download_rounded;
      case RadarrQueueRecordStatus.COMPLETED:
        return Icons.download_done_rounded;
      case RadarrQueueRecordStatus.DOWNLOADING:
        return Icons.cloud_download_rounded;
      default:
        return Icons.cloud_download_rounded;
    }
  }

  Color get zebrraStatusColor {
    Color color = Colors.white;
    if (this.status == RadarrQueueRecordStatus.COMPLETED)
      switch (this.trackedDownloadState) {
        case RadarrTrackedDownloadState.FAILED_PENDING:
          color = ZebrraColours.red;
          break;
        case RadarrTrackedDownloadState.IMPORT_PENDING:
          color = ZebrraColours.purple;
          break;
        case RadarrTrackedDownloadState.IMPORTING:
          color = ZebrraColours.purple;
          break;
        default:
          break;
      }
    if (this.trackedDownloadStatus == RadarrTrackedDownloadStatus.WARNING)
      color = ZebrraColours.orange;
    switch (this.status) {
      case RadarrQueueRecordStatus.DOWNLOAD_CLIENT_UNAVAILABLE:
        color = ZebrraColours.orange;
        break;
      case RadarrQueueRecordStatus.FAILED:
        color = ZebrraColours.red;
        break;
      case RadarrQueueRecordStatus.WARNING:
        color = ZebrraColours.orange;
        break;
      default:
        break;
    }
    if (this.trackedDownloadStatus == RadarrTrackedDownloadStatus.ERROR)
      color = ZebrraColours.red;
    return color;
  }
}
