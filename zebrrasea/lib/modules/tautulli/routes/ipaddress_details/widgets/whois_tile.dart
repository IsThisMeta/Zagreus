import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliIPAddressDetailsWHOISTile extends StatelessWidget {
  final TautulliWHOISInfo whois;

  const TautulliIPAddressDetailsWHOISTile({
    Key? key,
    required this.whois,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'host', body: whois.host ?? ZebrraUI.TEXT_EMDASH),
        ..._subnets(),
      ],
    );
  }

  List<ZebrraTableContent> _subnets() {
    if (whois.subnets?.isEmpty ?? true) return [];
    return whois.subnets!.fold<List<ZebrraTableContent>>([], (list, subnet) {
      list.add(ZebrraTableContent(
        title: 'isp',
        body: [
          subnet.description ?? ZebrraUI.TEXT_EMDASH,
          '\n\n${subnet.address ?? ZebrraUI.TEXT_EMDASH}',
          '\n${subnet.city}, ${subnet.state ?? ZebrraUI.TEXT_EMDASH}',
          '\n${subnet.postalCode ?? ZebrraUI.TEXT_EMDASH}',
          '\n${subnet.country ?? ZebrraUI.TEXT_EMDASH}',
        ].join(),
      ));
      return list;
    });
  }
}
