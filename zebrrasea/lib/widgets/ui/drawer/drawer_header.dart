import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraDrawerHeader extends StatelessWidget {
  final String page;

  const ZebrraDrawerHeader({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraSeaDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => Container(
        child: ZebrraAppBar.dropdown(
          backgroundColor: Colors.transparent,
          hideLeading: true,
          useDrawer: false,
          title: ZebrraBox.profiles.keys.length == 1
              ? 'ZebrraSea'
              : ZebrraSeaDatabase.ENABLED_PROFILE.read(),
          profiles: ZebrraBox.profiles.keys.cast<String>().toList(),
          actions: [
            ZebrraIconButton(
              icon: ZebrraIcons.SETTINGS,
              onPressed: page == ZebrraModule.SETTINGS.key
                  ? Navigator.of(context).pop
                  : ZebrraModule.SETTINGS.launch,
            )
          ],
        ),
        decoration: BoxDecoration(
          color: ZebrraColours.accent,
          image: DecorationImage(
            image: const AssetImage(ZebrraAssets.brandingLogo),
            colorFilter: ColorFilter.mode(
              ZebrraColours.primary.withOpacity(0.15),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
