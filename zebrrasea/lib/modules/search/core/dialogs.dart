import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/utils/profile_tools.dart';

class SearchDialogs {
  Future<Tuple2<bool, SearchDownloadType?>> downloadResult(
      BuildContext context) async {
    bool _flag = false;
    SearchDownloadType? _type;

    void _setValues(bool flag, SearchDownloadType type) {
      _flag = flag;
      _type = type;
      Navigator.of(context).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'search.Download'.tr(),
      customContent: ZebrraSeaDatabase.ENABLED_PROFILE.listenableBuilder(
        builder: (context, _) => ZebrraDialog.content(
          children: [
            Padding(
              child: ZebrraPopupMenuButton<String>(
                tooltip: 'zebrrasea.ChangeProfiles'.tr(),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          ZebrraSeaDatabase.ENABLED_PROFILE.read(),
                          style: const TextStyle(
                            fontSize: ZebrraUI.FONT_SIZE_H3,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: ZebrraColours.accent,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(bottom: 2.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ZebrraColours.accent,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                onSelected: (result) {
                  HapticFeedback.selectionClick();
                  ZebrraProfileTools().changeTo(result);
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<String>>[
                    for (final profile in ZebrraBox.profiles.keys.cast<String>())
                      PopupMenuItem<String>(
                        value: profile,
                        child: Text(
                          profile,
                          style: TextStyle(
                            fontSize: ZebrraUI.FONT_SIZE_H3,
                            color: ZebrraSeaDatabase.ENABLED_PROFILE.read() ==
                                    profile
                                ? ZebrraColours.accent
                                : Colors.white,
                          ),
                        ),
                      )
                  ];
                },
              ),
              padding: ZebrraDialog.tileContentPadding()
                  .add(const EdgeInsets.only(bottom: 16.0)),
            ),
            if (ZebrraProfile.current.sabnzbdEnabled)
              ZebrraDialog.tile(
                icon: SearchDownloadType.SABNZBD.icon,
                iconColor: ZebrraColours().byListIndex(0),
                text: SearchDownloadType.SABNZBD.name,
                onTap: () => _setValues(true, SearchDownloadType.SABNZBD),
              ),
            if (ZebrraProfile.current.nzbgetEnabled)
              ZebrraDialog.tile(
                icon: SearchDownloadType.NZBGET.icon,
                iconColor: ZebrraColours().byListIndex(1),
                text: SearchDownloadType.NZBGET.name,
                onTap: () => _setValues(true, SearchDownloadType.NZBGET),
              ),
            ZebrraDialog.tile(
              icon: SearchDownloadType.FILESYSTEM.icon,
              iconColor: ZebrraColours().byListIndex(2),
              text: SearchDownloadType.FILESYSTEM.name,
              onTap: () => _setValues(true, SearchDownloadType.FILESYSTEM),
            ),
          ],
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _type);
  }
}
