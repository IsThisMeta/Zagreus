import 'package:flutter/material.dart';

import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/abstract.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/lidarr.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/radarr.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/sonarr.dart';

class ContentBlock extends StatelessWidget {
  final CalendarData data;
  const ContentBlock(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headers = getHeaders();
    return ZebrraBlock(
      title: data.title,
      body: data.body,
      posterHeaders: headers,
      backgroundHeaders: headers,
      posterUrl: data.posterUrl(context),
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      backgroundUrl: data.backgroundUrl(context),
      trailing: data.trailing(context),
      onTap: () async => data.enterContent(context),
    );
  }

  Map getHeaders() {
    switch (data.runtimeType) {
      case CalendarLidarrData:
        return ZebrraProfile.current.lidarrHeaders;
      case CalendarRadarrData:
        return ZebrraProfile.current.radarrHeaders;
      case CalendarSonarrData:
        return ZebrraProfile.current.sonarrHeaders;
      default:
        return const {};
    }
  }
}
