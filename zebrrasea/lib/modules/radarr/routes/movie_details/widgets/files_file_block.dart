import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMovieDetailsFilesFileBlock extends StatefulWidget {
  final RadarrMovieFile file;

  const RadarrMovieDetailsFilesFileBlock({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMovieDetailsFilesFileBlock> {
  ZebrraLoadingState _deleteFileState = ZebrraLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
          title: 'relative path',
          body: widget.file.zebrraRelativePath,
        ),
        ZebrraTableContent(
          title: 'video',
          body: widget.file.mediaInfo?.zebrraVideoCodec,
        ),
        ZebrraTableContent(
          title: 'audio',
          body: [
            widget.file.mediaInfo?.zebrraAudioCodec,
            if (widget.file.mediaInfo?.audioChannels != null)
              widget.file.mediaInfo?.audioChannels.toString(),
          ].join(ZebrraUI.TEXT_BULLET.pad()),
        ),
        ZebrraTableContent(
          title: 'size',
          body: widget.file.zebrraSize,
        ),
        ZebrraTableContent(
          title: 'languages',
          body: widget.file.zebrraLanguage,
        ),
        ZebrraTableContent(
          title: 'quality',
          body: widget.file.zebrraQuality,
        ),
        ZebrraTableContent(
          title: 'formats',
          body: widget.file.zebrraCustomFormats,
        ),
        ZebrraTableContent(
          title: 'added on',
          body: widget.file.zebrraDateAdded,
        ),
      ],
      buttons: [
        if (widget.file.mediaInfo != null)
          ZebrraButton.text(
            text: 'Media Info',
            icon: Icons.info_outline_rounded,
            onTap: () async => _viewMediaInfo(),
          ),
        ZebrraButton(
          type: ZebrraButtonType.TEXT,
          text: 'Delete',
          icon: Icons.delete_rounded,
          onTap: () async => _deleteFile(),
          color: ZebrraColours.red,
          loadingState: _deleteFileState,
        ),
      ],
    );
  }

  Future<void> _deleteFile() async {
    setState(() => _deleteFileState = ZebrraLoadingState.ACTIVE);
    bool result = await RadarrDialogs().deleteMovieFile(context);
    if (result) {
      bool execute = await RadarrAPIHelper()
          .deleteMovieFile(context: context, movieFile: widget.file);
      if (execute) context.read<RadarrMovieDetailsState>().fetchFiles(context);
    }
    setState(() => _deleteFileState = ZebrraLoadingState.INACTIVE);
  }

  Future<void> _viewMediaInfo() async {
    ZebrraBottomModalSheet().show(
      builder: (context) => ZebrraListViewModal(
        children: [
          ZebrraHeader(text: 'radarr.Video'.tr()),
          ZebrraTableCard(
            content: [
              ZebrraTableContent(
                title: 'radarr.BitDepth'.tr(),
                body: widget.file.mediaInfo?.zebrraVideoBitDepth,
              ),
              ZebrraTableContent(
                title: 'radarr.Codec'.tr(),
                body: widget.file.mediaInfo?.zebrraVideoCodec,
              ),
              ZebrraTableContent(
                title: 'radarr.DynamicRange'.tr(),
                body: widget.file.mediaInfo?.zebrraVideoDynamicRange,
              ),
              ZebrraTableContent(
                title: 'radarr.FPS'.tr(),
                body: widget.file.mediaInfo?.zebrraVideoFps,
              ),
              ZebrraTableContent(
                title: 'radarr.Resolution'.tr(),
                body: widget.file.mediaInfo?.zebrraVideoResolution,
              ),
            ],
          ),
          ZebrraHeader(text: 'radarr.Audio'.tr()),
          ZebrraTableCard(
            content: [
              ZebrraTableContent(
                title: 'radarr.Channels'.tr(),
                body: widget.file.mediaInfo?.zebrraAudioChannels,
              ),
              ZebrraTableContent(
                title: 'radarr.Codec'.tr(),
                body: widget.file.mediaInfo?.zebrraAudioCodec,
              ),
              ZebrraTableContent(
                title: 'radarr.Languages'.tr(),
                body: widget.file.mediaInfo?.zebrraAudioLanguages,
              ),
              ZebrraTableContent(
                title: 'radarr.Streams'.tr(),
                body: widget.file.mediaInfo?.zebrraAudioStreamCount,
              ),
            ],
          ),
          ZebrraHeader(text: 'radarr.Other'.tr()),
          ZebrraTableCard(
            content: [
              ZebrraTableContent(
                title: 'radarr.Runtime'.tr(),
                body: widget.file.mediaInfo?.zebrraRunTime,
              ),
              ZebrraTableContent(
                title: 'radarr.ScanType'.tr(),
                body: widget.file.mediaInfo?.zebrraScanType,
              ),
              ZebrraTableContent(
                title: 'radarr.Subtitles'.tr(),
                body: widget.file.mediaInfo?.zebrraSubtitles,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
