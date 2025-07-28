import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliIPAddressDetailsGeolocationTile extends StatelessWidget {
  final TautulliGeolocationInfo geolocation;

  const TautulliIPAddressDetailsGeolocationTile({
    Key? key,
    required this.geolocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
            title: 'country', body: geolocation.country ?? ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'region', body: geolocation.region ?? ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'city', body: geolocation.city ?? ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'postal',
            body: geolocation.postalCode ?? ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'timezone',
            body: geolocation.timezone ?? ZebrraUI.TEXT_EMDASH),
        ZebrraTableContent(
            title: 'latitude',
            body: '${geolocation.latitude ?? ZebrraUI.TEXT_EMDASH}'),
        ZebrraTableContent(
            title: 'longitude',
            body: '${geolocation.longitude ?? ZebrraUI.TEXT_EMDASH}'),
      ],
    );
  }
}
