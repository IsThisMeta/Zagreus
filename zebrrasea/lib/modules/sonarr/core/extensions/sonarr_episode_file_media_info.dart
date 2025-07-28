import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrEpisodeFileMediaInfoExtension on SonarrEpisodeFileMediaInfo {
  String get zebrraVideoBitDepth {
    if (videoBitDepth != null) return videoBitDepth.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraVideoBitrate {
    if (videoBitrate != null) return '${videoBitrate.asBits()}/s';
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraVideoCodec {
    if (videoCodec != null && videoCodec!.isNotEmpty) return videoCodec;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraVideoFps {
    if (videoFps != null) return videoFps.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraVideoResolution {
    if (resolution != null && resolution!.isNotEmpty) return resolution;
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraVideoScanType {
    if (scanType != null && scanType!.isNotEmpty) return scanType;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraAudioBitrate {
    if (audioBitrate != null) return '${audioBitrate.asBits()}/s';
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraAudioChannels {
    if (audioChannels != null) return audioChannels.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraAudioCodec {
    if (audioCodec != null && audioCodec!.isNotEmpty) return audioCodec;
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraAudioLanguages {
    if (audioLanguages != null && audioLanguages!.isNotEmpty)
      return audioLanguages;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraAudioStreamCount {
    if (audioStreamCount != null) return audioStreamCount.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraRunTime {
    if (runTime != null && runTime!.isNotEmpty) return runTime;
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraSubtitles {
    if (subtitles != null && subtitles!.isNotEmpty) return subtitles;
    return ZebrraUI.TEXT_EMDASH;
  }
}
