import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/double/time.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrEventType on RadarrEventType {
  // Get ZebrraSea associated colour of the event type.
  Color get zebrraColour {
    switch (this) {
      case RadarrEventType.GRABBED:
        return ZebrraColours.orange;
      case RadarrEventType.DOWNLOAD_FAILED:
        return ZebrraColours.red;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return ZebrraColours.accent;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return ZebrraColours.purple;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return ZebrraColours.red;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return ZebrraColours.blue;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return ZebrraColours.accent;
    }
  }

  IconData get zebrraIcon {
    switch (this) {
      case RadarrEventType.GRABBED:
        return Icons.cloud_download_rounded;
      case RadarrEventType.DOWNLOAD_FAILED:
        return Icons.cloud_download_rounded;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return Icons.download_rounded;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return Icons.delete_rounded;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return Icons.cancel_rounded;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return Icons.drive_file_rename_outline_rounded;
    }
  }

  Color get zebrraIconColour {
    switch (this) {
      case RadarrEventType.GRABBED:
        return Colors.white;
      case RadarrEventType.DOWNLOAD_FAILED:
        return ZebrraColours.red;
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return Colors.white;
      case RadarrEventType.DOWNLOAD_IGNORED:
        return Colors.white;
      case RadarrEventType.MOVIE_FILE_DELETED:
        return Colors.white;
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return Colors.white;
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return Colors.white;
    }
  }

  String? zebrraReadable(RadarrHistoryRecord record) {
    switch (this) {
      case RadarrEventType.GRABBED:
        return 'radarr.GrabbedFrom'
            .tr(args: [(record.data ?? {})['indexer'] ?? ZebrraUI.TEXT_EMDASH]);
      case RadarrEventType.DOWNLOAD_FAILED:
        return 'radarr.DownloadFailed'.tr();
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return 'radarr.MovieImported'
            .tr(args: [record.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH]);
      case RadarrEventType.DOWNLOAD_IGNORED:
        return 'radarr.DownloadIgnored'.tr();
      case RadarrEventType.MOVIE_FILE_DELETED:
        return 'radarr.MovieFileDeleted'.tr();
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return 'radarr.MovieFileRenamed'.tr();
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return 'radarr.MovieImported'
            .tr(args: [record.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH]);
    }
  }

  List<ZebrraTableContent> zebrraTableContent(
    RadarrHistoryRecord record, {
    bool movieHistory = false,
  }) {
    switch (this) {
      case RadarrEventType.GRABBED:
        return _grabbedTableContent(record, !movieHistory);
      case RadarrEventType.DOWNLOAD_FAILED:
        return _downloadFailedTableContent(record, !movieHistory);
      case RadarrEventType.DOWNLOAD_FOLDER_IMPORTED:
        return _downloadFolderImportedTableContent(record);
      case RadarrEventType.DOWNLOAD_IGNORED:
        return _downloadIgnoredTableContent(record, !movieHistory);
      case RadarrEventType.MOVIE_FILE_DELETED:
        return _movieFileDeletedTableContent(record, !movieHistory);
      case RadarrEventType.MOVIE_FILE_RENAMED:
        return _movieFileRenamedTableContent(record);
      case RadarrEventType.MOVIE_FOLDER_IMPORTED:
        return _movieFolderImportedTableContent(record);
      default:
        return [];
    }
  }

  List<ZebrraTableContent> _grabbedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'languages',
        body: record.languages
            ?.map<String?>((language) => language.name)
            .join('\n'),
      ),
      ZebrraTableContent(
        title: 'indexer',
        body: record.data!['indexer'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'group',
        body: record.data!['releaseGroup'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'age',
        body: record.data!['ageHours'] != null
            ? double.tryParse((record.data!['ageHours'] as String))
                    ?.asTimeAgo() ??
                ZebrraUI.TEXT_EMDASH
            : ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'published date',
        body: DateTime.tryParse(record.data!['publishedDate']) != null
            ? DateTime.tryParse(record.data!['publishedDate'])
                    ?.asDateTime(delimiter: '\n') ??
                ZebrraUI.TEXT_EMDASH
            : ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'info url',
        body: record.data!['nzbInfoUrl'] ?? ZebrraUI.TEXT_EMDASH,
        bodyIsUrl: record.data!['nzbInfoUrl'] != null,
      ),
    ];
  }

  List<ZebrraTableContent> _downloadFailedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'message',
        body: record.data!['message'] ?? ZebrraUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZebrraTableContent> _downloadFolderImportedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZebrraTableContent(
        title: 'source title',
        body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'languages',
        body: record.languages
                ?.map<String?>((language) => language.name)
                .join('\n') ??
            ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'source',
        body: record.data!['droppedPath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'imported to',
        body: record.data!['importedPath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZebrraTableContent> _downloadIgnoredTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'message',
        body: record.data!['message'] ?? ZebrraUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZebrraTableContent> _movieFileDeletedTableContent(
    RadarrHistoryRecord record,
    bool showSourceTitle,
  ) {
    return [
      if (showSourceTitle)
        ZebrraTableContent(
          title: 'source title',
          body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
        ),
      ZebrraTableContent(
        title: 'reason',
        body: record.zebrraFileDeletedReasonMessage,
      ),
    ];
  }

  List<ZebrraTableContent> _movieFileRenamedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZebrraTableContent(
        title: 'source',
        body: record.data!['sourceRelativePath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'destination',
        body: record.data!['relativePath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
    ];
  }

  List<ZebrraTableContent> _movieFolderImportedTableContent(
    RadarrHistoryRecord record,
  ) {
    return [
      ZebrraTableContent(
        title: 'source title',
        body: record.sourceTitle ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'quality',
        body: record.quality?.quality?.name ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'languages',
        body: ([RadarrLanguage(name: ZebrraUI.TEXT_EMDASH)])
            .map<String?>((language) => language.name)
            .join('\n'),
      ),
      ZebrraTableContent(
        title: 'client',
        body: record.data!['downloadClientName'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'source',
        body: record.data!['droppedPath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
      ZebrraTableContent(
        title: 'imported to',
        body: record.data!['importedPath'] ?? ZebrraUI.TEXT_EMDASH,
      ),
    ];
  }
}
