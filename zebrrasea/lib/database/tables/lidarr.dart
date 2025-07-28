import 'package:zebrrasea/database/table.dart';
import 'package:zebrrasea/modules/lidarr/core/api/data/metadata.dart';
import 'package:zebrrasea/modules/lidarr/core/api/data/qualityprofile.dart';
import 'package:zebrrasea/modules/lidarr/core/api/data/rootfolder.dart';
import 'package:zebrrasea/vendor.dart';

enum LidarrDatabase<T> with ZebrraTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  ADD_MONITORED_STATUS<String>('all'),
  ADD_ARTIST_SEARCH_FOR_MISSING<bool>(true),
  ADD_ALBUM_FOLDERS<bool>(true),
  ADD_QUALITY_PROFILE<LidarrQualityProfile?>(null),
  ADD_METADATA_PROFILE<LidarrMetadataProfile?>(null),
  ADD_ROOT_FOLDER<LidarrRootFolder?>(null);

  @override
  ZebrraTable get table => ZebrraTable.lidarr;

  @override
  final T fallback;

  const LidarrDatabase(this.fallback);

  @override
  void register() {
    Hive.registerAdapter(LidarrQualityProfileAdapter());
    Hive.registerAdapter(LidarrMetadataProfileAdapter());
    Hive.registerAdapter(LidarrRootFolderAdapter());
  }

  @override
  List<LidarrDatabase> get blockedFromImportExport {
    return [
      LidarrDatabase.ADD_ALBUM_FOLDERS,
      LidarrDatabase.ADD_QUALITY_PROFILE,
      LidarrDatabase.ADD_METADATA_PROFILE,
      LidarrDatabase.ADD_ROOT_FOLDER,
    ];
  }
}
