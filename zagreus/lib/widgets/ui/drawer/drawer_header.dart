import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagDrawerHeader extends StatelessWidget {
  final String page;

  const ZagDrawerHeader({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => Container(
        child: ZagAppBar.dropdown(
          backgroundColor: Colors.transparent,
          hideLeading: true,
          useDrawer: false,
          title: ZagBox.profiles.keys.length == 1
              ? 'Zagreus'
              : ZagreusDatabase.ENABLED_PROFILE.read(),
          profiles: ZagBox.profiles.keys.cast<String>().toList(),
          actions: [
            ZagIconButton(
              icon: ZagIcons.SETTINGS,
              onPressed: page == ZagModule.SETTINGS.key
                  ? Navigator.of(context).pop
                  : ZagModule.SETTINGS.launch,
            )
          ],
        ),
        decoration: BoxDecoration(
          color: ZagColours.accent,
          image: DecorationImage(
            image: const AssetImage(ZagAssets.brandingLogo),
            colorFilter: ColorFilter.mode(
              ZagColours.primary.withOpacity(0.15),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
