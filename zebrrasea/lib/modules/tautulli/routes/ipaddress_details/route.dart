import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class IPDetailsRoute extends StatefulWidget {
  final String? ipAddress;

  const IPDetailsRoute({
    Key? key,
    required this.ipAddress,
  }) : super(key: key);

  @override
  State<IPDetailsRoute> createState() => _State();
}

class _State extends State<IPDetailsRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          TautulliIPAddressDetailsState(context, widget.ipAddress),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'IP Address Details',
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<TautulliIPAddressDetailsState>().fetchAll(context),
      child: FutureBuilder(
        future: Future.wait([
          context.watch<TautulliIPAddressDetailsState>().geolocation!,
          context.watch<TautulliIPAddressDetailsState>().whois!,
        ]),
        builder: (context, AsyncSnapshot<List<Object>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Tautulli IP address information',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData)
            return _list(snapshot.data![0] as TautulliGeolocationInfo,
                snapshot.data![1] as TautulliWHOISInfo);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(TautulliGeolocationInfo geolocation, TautulliWHOISInfo whois) {
    return ZebrraListView(
      controller: scrollController,
      children: [
        const ZebrraHeader(text: 'Location'),
        TautulliIPAddressDetailsGeolocationTile(geolocation: geolocation),
        const ZebrraHeader(text: 'Connection'),
        TautulliIPAddressDetailsWHOISTile(whois: whois),
      ],
    );
  }
}
