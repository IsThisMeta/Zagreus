import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/double/time.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrEventTypeZebrraExtension on SonarrEventType {
  Color zebrraColour() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return ZebrraColours.blue;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return ZebrraColours.red;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return ZebrraColours.accent;
      case SonarrEventType.DOWNLOAD_FAILED:
        return ZebrraColours.red;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return ZebrraColours.purple;
      case SonarrEventType.GRABBED:
        return ZebrraColours.orange;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return ZebrraColours.accent;
    }
  }

  IconData zebrraIcon() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return Icons.drive_file_rename_outline_rounded;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return Icons.delete_rounded;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case SonarrEventType.DOWNLOAD_FAILED:
        return Icons.cloud_download_rounded;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return Icons.cancel_rounded;
      case SonarrEventType.GRABBED:
        return Icons.cloud_download_rounded;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return Icons.download_rounded;
    }
  }

  Color zebrraIconColour() {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return Colors.white;
      case SonarrEventType.EPISODE_FILE_DELETED:
        return Colors.white;
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Colors.white;
      case SonarrEventType.DOWNLOAD_FAILED:
        return ZebrraColours.red;
      case SonarrEventType.DOWNLOAD_IGNORED:
        return Colors.white;
      case SonarrEventType.GRABBED:
        return Colors.white;
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return Colors.white;
    }
  }

  String? zebrraReadable(SonarrHistoryRecord record) {
    switch (this) {
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return 'sonarr.EpisodeFileRenamed'.tr();
      case SonarrEventType.EPISODE_FILE_DELETED:
        return 'sonarr.EpisodeFileDeleted'.tr();
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return 'sonarr.EpisodeImported'.tr(
          args: [record.quality?.quality?.name ?? 'zebrrasea.Unknown'.tr()],
        );
      case SonarrEventType.DOWNLOAD_FAILED:
        return 'sonarr.DownloadFailed'.tr();
      case SonarrEventType.GRABBED:
        return 'sonarr.GrabbedFrom'.tr(
          args: [record.data!['indexer'] ?? 'zebrrasea.Unknown'.tr()],
        );
      case SonarrEventType.DOWNLOAD_IGNORED:
        return 'sonarr.DownloadIgnored'.tr();
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
        return 'sonarr.SeriesFolderImported'.tr();
    }
  }

  List<ZebrraTableContent> zebrraTableContent({
    required SonarrHistoryRecord history,
    required bool showSourceTitle,
  }) {
    switch (this) {
      case SonarrEventType.DOWNLOAD_FAILED:
        return _downloadFailedTableContent(history, showSourceTitle);
      case SonarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return _downloadFolderImportedTableContent(history, showSourceTitle);
      case SonarrEventType.DOWNLOAD_IGNORED:
        return _downloadIgnoredTableContent(history, showSourceTitle);
      case SonarrEventType.EPISODE_FILE_DELETED:
        return _episodeFileDeletedTableContent(history, showSourceTitle);
      case SonarrEventType.EPISODE_FILE_RENAMED:
        return _episodeFileRenamedTableContent(history);
      case SonarrEventType.GRABBED:
        return _grabbedTableContent(history, showSourceTitle);
      case SonarrEventType.SERIES_FOLDER_IMPORTED:
      default:
        return _defaultTableContent(history, showSourceTitle);
    }
  }

  List<ZebrraTableContent> _downloadFailedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZebrraTableContent(
        title: 'sonarr.Message'.tr(),
        body: history.data!['message'],
      ),
    ];
  }

  List<ZebrraTableContent> _downloadFolderImportedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZebrraTableContent(
        title: 'sonarr.Quality'.tr(),
        body: history.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      if (history.language != null)
        ZebrraTableContent(
          title: 'sonarr.Languages'.tr(),
          body: history.language?.name ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'sonarr.Client'.tr(),
        body: history.data!['downloadClient'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'sonarr.Source'.tr(),
        body: history.data!['droppedPath'],
      ),
      ZebrraTableContent(
        title: 'sonarr.ImportedTo'.tr(),
        body: history.data!['importedPath'],
      ),
    ];
  }

  List<ZebrraTableContent> _downloadIgnoredTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.Name'.tr(),
          body: history.sourceTitle,
        ),
      ZebrraTableContent(
        title: 'sonarr.Message'.tr(),
        body: history.data!['message'],
      ),
    ];
  }

  List<ZebrraTableContent> _episodeFileDeletedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    String _reasonMapping(String? reason) {
      switch (reason) {
        case 'Upgrade':
          return 'sonarr.DeleteReasonUpgrade'.tr();
        case 'MissingFromDisk':
          return 'sonarr.DeleteReasonMissingFromDisk'.tr();
        case 'Manual':
          return 'sonarr.DeleteReasonManual'.tr();
        default:
          return 'zebrrasea.Unknown'.tr();
      }
    }

    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZebrraTableContent(
        title: 'sonarr.Reason'.tr(),
        body: _reasonMapping(history.data!['reason']),
      ),
    ];
  }

  List<ZebrraTableContent> _episodeFileRenamedTableContent(
    SonarrHistoryRecord history,
  ) {
    return [
      ZebrraTableContent(
        title: 'sonarr.Source'.tr(),
        body: history.data!['sourcePath'],
      ),
      ZebrraTableContent(
        title: 'sonarr.SourceRelative'.tr(),
        body: history.data!['sourceRelativePath'],
      ),
      ZebrraTableContent(
        title: 'sonarr.Destination'.tr(),
        body: history.data!['path'],
      ),
      ZebrraTableContent(
        title: 'sonarr.DestinationRelative'.tr(),
        body: history.data!['relativePath'],
      ),
    ];
  }

  List<ZebrraTableContent> _grabbedTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.SourceTitle'.tr(),
          body: history.sourceTitle,
        ),
      ZebrraTableContent(
        title: 'sonarr.Quality'.tr(),
        body: history.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      if (history.language != null)
        ZebrraTableContent(
          title: 'sonarr.Languages'.tr(),
          body: history.language?.name ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'sonarr.Indexer'.tr(),
        body: history.data!['indexer'],
      ),
      ZebrraTableContent(
        title: 'sonarr.ReleaseGroup'.tr(),
        body: history.data!['releaseGroup'],
      ),
      ZebrraTableContent(
        title: 'sonarr.InfoURL'.tr(),
        body: history.data!['nzbInfoUrl'],
        bodyIsUrl: history.data!['nzbInfoUrl'] != null,
      ),
      ZebrraTableContent(
        title: 'sonarr.Client'.tr(),
        body: history.data!['downloadClientName'],
      ),
      ZebrraTableContent(
        title: 'sonarr.DownloadID'.tr(),
        body: history.data!['downloadId'],
      ),
      ZebrraTableContent(
        title: 'sonarr.Age'.tr(),
        body: double.tryParse(history.data!['ageHours'])?.asTimeAgo(),
      ),
      ZebrraTableContent(
          title: 'sonarr.PublishedDate'.tr(),
          body: DateTime.tryParse(history.data!['publishedDate'])
              ?.asDateTime(delimiter: '\n')),
    ];
  }

  List<ZebrraTableContent> _defaultTableContent(
    SonarrHistoryRecord history,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'sonarr.Name'.tr(),
          body: history.sourceTitle,
        ),
    ];
  }
}
