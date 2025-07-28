import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrMediaInfoSheet extends ZebrraBottomModalSheet {
  final SonarrEpisodeFileMediaInfo? mediaInfo;

  SonarrMediaInfoSheet({
    required this.mediaInfo,
  });

  @override
  Widget builder(BuildContext context) {
    return ZebrraListViewModal(
      children: [
        ZebrraHeader(text: 'sonarr.Video'.tr()),
        ZebrraTableCard(
          content: [
            ZebrraTableContent(
              title: 'sonarr.BitDepth'.tr(),
              body: mediaInfo!.zebrraVideoBitDepth,
            ),
            ZebrraTableContent(
              title: 'sonarr.Bitrate'.tr(),
              body: mediaInfo!.zebrraVideoBitrate,
            ),
            ZebrraTableContent(
              title: 'sonarr.Codec'.tr(),
              body: mediaInfo!.zebrraVideoCodec,
            ),
            ZebrraTableContent(
              title: 'sonarr.FPS'.tr(),
              body: mediaInfo!.zebrraVideoFps,
            ),
            ZebrraTableContent(
              title: 'sonarr.Resolution'.tr(),
              body: mediaInfo!.zebrraVideoResolution,
            ),
            ZebrraTableContent(
              title: 'sonarr.ScanType'.tr(),
              body: mediaInfo!.zebrraVideoScanType,
            ),
          ],
        ),
        ZebrraHeader(text: 'sonarr.Audio'.tr()),
        ZebrraTableCard(
          content: [
            ZebrraTableContent(
              title: 'sonarr.Bitrate'.tr(),
              body: mediaInfo!.zebrraAudioBitrate,
            ),
            ZebrraTableContent(
              title: 'sonarr.Channels'.tr(),
              body: mediaInfo!.zebrraAudioChannels,
            ),
            ZebrraTableContent(
              title: 'sonarr.Codec'.tr(),
              body: mediaInfo!.zebrraAudioCodec,
            ),
            ZebrraTableContent(
              title: 'sonarr.Languages'.tr(),
              body: mediaInfo!.zebrraAudioLanguages,
            ),
            ZebrraTableContent(
              title: 'sonarr.Streams'.tr(),
              body: mediaInfo!.zebrraAudioStreamCount,
            ),
          ],
        ),
        ZebrraHeader(text: 'sonarr.Other'.tr()),
        ZebrraTableCard(
          content: [
            ZebrraTableContent(
              title: 'sonarr.Runtime'.tr(),
              body: mediaInfo!.zebrraRunTime,
            ),
            ZebrraTableContent(
              title: 'sonarr.Subtitles'.tr(),
              body: mediaInfo!.zebrraSubtitles,
            ),
          ],
        ),
      ],
    );
  }
}
