import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension RadarrQualityProfileExtension on RadarrQualityProfile {
  String? get zebrraName {
    if (this.name != null && this.name!.isNotEmpty) return this.name;
    return ZebrraUI.TEXT_EMDASH;
  }
}
