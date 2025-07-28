import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension RadarrSystemStatusExtension on RadarrSystemStatus {
  String get zebrraVersion {
    if (this.version != null && this.version!.isNotEmpty) return this.version!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraPackageVersion {
    String? packageAuthor, packageVersion;
    if (this.packageVersion != null && this.packageVersion!.isNotEmpty)
      packageVersion = this.packageVersion;
    if (this.packageAuthor != null && this.packageAuthor!.isNotEmpty)
      packageAuthor = this.packageAuthor;
    return '${packageVersion ?? ZebrraUI.TEXT_EMDASH} by ${packageAuthor ?? ZebrraUI.TEXT_EMDASH}';
  }

  String get zebrraNetCore {
    if (this.isNetCore ?? false)
      return 'Yes (${this.runtimeVersion ?? ZebrraUI.TEXT_EMDASH})';
    return 'No';
  }

  bool get zebrraIsDocker {
    return this.isDocker ?? false;
  }

  String get zebrraDBMigration {
    if (this.migrationVersion != null) return '${this.migrationVersion}';
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraAppDataDirectory {
    if (this.appData != null && this.appData!.isNotEmpty) return this.appData!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraStartupDirectory {
    if (this.startupPath != null && this.startupPath!.isNotEmpty)
      return this.startupPath!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraMode {
    if (this.mode != null && this.mode!.isNotEmpty)
      return this.mode!.toTitleCase();
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraUptime {
    if (this.startTime != null && this.startTime!.isNotEmpty) {
      DateTime? _start = DateTime.tryParse(this.startTime!);
      if (_start != null)
        return DateTime.now().difference(_start).asWordsTimestamp();
    }
    return ZebrraUI.TEXT_EMDASH;
  }
}
