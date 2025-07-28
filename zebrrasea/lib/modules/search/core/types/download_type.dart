import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';

enum SearchDownloadType {
  NZBGET,
  SABNZBD,
  FILESYSTEM,
}

extension SearchDownloadTypeExtension on SearchDownloadType {
  String get name {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return 'NZBGet';
      case SearchDownloadType.SABNZBD:
        return 'SABnzbd';
      case SearchDownloadType.FILESYSTEM:
        return 'search.DownloadToDevice'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return ZebrraModule.NZBGET.icon;
      case SearchDownloadType.SABNZBD:
        return ZebrraModule.SABNZBD.icon;
      case SearchDownloadType.FILESYSTEM:
        return Icons.download_rounded;
    }
  }

  Future<void> execute(BuildContext context, NewznabResultData data) async {
    switch (this) {
      case SearchDownloadType.NZBGET:
        return _executeNZBGet(context, data);
      case SearchDownloadType.SABNZBD:
        return _executeSABnzbd(context, data);
      case SearchDownloadType.FILESYSTEM:
        return _executeFileSystem(context, data);
    }
  }

  Future<void> _executeNZBGet(
      BuildContext context, NewznabResultData data) async {
    NZBGetAPI api = NZBGetAPI.from(ZebrraProfile.current);
    await api
        .uploadURL(data.linkDownload)
        .then((_) => showZebrraSuccessSnackBar(
              title: 'search.SentNZBData'.tr(),
              message:
                  'search.SentTo'.tr(args: [SearchDownloadType.NZBGET.name]),
              showButton: true,
              buttonOnPressed: ZebrraModule.NZBGET.launch,
            ))
        .catchError((error, stack) {
      ZebrraLogger().error('Failed to download data', error, stack);
      return showZebrraErrorSnackBar(
          title: 'search.FailedToSend'.tr(), error: error);
    });
  }

  Future<void> _executeSABnzbd(
      BuildContext context, NewznabResultData data) async {
    SABnzbdAPI api = SABnzbdAPI.from(ZebrraProfile.current);
    await api
        .uploadURL(data.linkDownload)
        .then((_) => showZebrraSuccessSnackBar(
              title: 'search.SentNZBData'.tr(),
              message:
                  'search.SentTo'.tr(args: [SearchDownloadType.SABNZBD.name]),
              showButton: true,
              buttonOnPressed: ZebrraModule.SABNZBD.launch,
            ))
        .catchError((error, stack) {
      ZebrraLogger().error('Failed to download data', error, stack);
      return showZebrraErrorSnackBar(
          title: 'search.FailedToSend'.tr(), error: error);
    });
  }

  Future<void> _executeFileSystem(
      BuildContext context, NewznabResultData data) async {
    showZebrraInfoSnackBar(
      title: 'search.Downloading'.tr(),
      message: 'search.DownloadingNZBToDevice'.tr(),
    );
    String cleanTitle = data.title.replaceAll(RegExp(r'[^0-9a-zA-Z. -]+'), '');
    try {
      context
          .read<SearchState>()
          .api
          .downloadRelease(data)
          .then((download) async {
        bool result = await ZebrraFileSystem().save(
          context,
          '$cleanTitle.nzb',
          utf8.encode(download!),
        );
        if (result)
          showZebrraSuccessSnackBar(
              title: 'Saved NZB', message: 'NZB has been successfully saved');
      });
    } catch (error, stack) {
      ZebrraLogger().error('Error downloading NZB', error, stack);
      showZebrraErrorSnackBar(
          title: 'search.FailedToDownloadNZB'.tr(), error: error);
    }
  }
}
