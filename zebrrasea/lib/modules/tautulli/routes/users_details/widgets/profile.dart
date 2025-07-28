import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliUserDetailsProfile extends StatefulWidget {
  final TautulliTableUser user;

  const TautulliUserDetailsProfile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliUserDetailsProfile>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  // Tracks the initial load to ensure the futures have been initialized
  bool _initialLoad = false;

  @override
  Future<void> loadCallback() async {
    // Initial load or refresh of the user profile data
    context.read<TautulliState>().setUserProfile(
          widget.user.userId!,
          context
              .read<TautulliState>()
              .api!
              .users
              .getUser(userId: widget.user.userId!),
        );
    // Initial load or refresh of the user watch stats
    context.read<TautulliState>().setUserWatchStats(
          widget.user.userId!,
          context.read<TautulliState>().api!.users.getUserWatchTimeStats(
              userId: widget.user.userId!, queryDays: [1, 7, 30, 0]),
        );
    // Initial load or refresh of the user player stats
    context.read<TautulliState>().setUserPlayerStats(
          widget.user.userId!,
          context
              .read<TautulliState>()
              .api!
              .users
              .getUserPlayerStats(userId: widget.user.userId!),
        );
    setState(() => _initialLoad = true);
    // This await keeps the refresh indicator showing until the data is loaded
    await Future.wait([
      context.read<TautulliState>().userProfile[widget.user.userId!]!,
      context.read<TautulliState>().userWatchStats[widget.user.userId!]!,
      context.read<TautulliState>().userPlayerStats[widget.user.userId!]!,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.TAUTULLI,
      body: _initialLoad ? _body() : const ZebrraLoader(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: Future.wait([
          context.watch<TautulliState>().userProfile[widget.user.userId!]!,
          context.watch<TautulliState>().userWatchStats[widget.user.userId!]!,
          context.watch<TautulliState>().userPlayerStats[widget.user.userId!]!,
        ]),
        builder: (context, AsyncSnapshot<List<Object>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Tautulli user: ${widget.user.userId}',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData)
            return _list(
              user: snapshot.data![0] as TautulliUser,
              watchtime: snapshot.data![1] as List<TautulliUserWatchTimeStats>,
              player: snapshot.data![2] as List<TautulliUserPlayerStats>,
            );
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list({
    required TautulliUser user,
    required List<TautulliUserWatchTimeStats> watchtime,
    required List<TautulliUserPlayerStats> player,
  }) {
    return ZebrraListView(
      controller: TautulliUserDetailsNavigationBar.scrollControllers[0],
      children: [
        const ZebrraHeader(text: 'Profile'),
        _profile(user),
        const ZebrraHeader(text: 'Global Stats'),
        _globalStats(watchtime),
        if (player.isNotEmpty) const ZebrraHeader(text: 'Player Stats'),
        if (player.isNotEmpty) ..._playerStats(player),
      ],
    );
  }

  Widget _profile(TautulliUser user) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'email', body: user.email),
        ZebrraTableContent(
          title: 'last seen',
          body: widget.user.lastSeen != null
              ? widget.user.lastSeen?.asAge() ?? 'Unknown'
              : 'Never',
        ),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(
            title: 'title', body: widget.user.lastPlayed ?? 'None'),
        ZebrraTableContent(
            title: 'platform', body: widget.user.platform ?? 'None'),
        ZebrraTableContent(title: 'player', body: widget.user.player ?? 'None'),
        ZebrraTableContent(
            title: 'location', body: widget.user.ipAddress ?? 'None'),
      ],
    );
  }

  Widget _globalStats(List<TautulliUserWatchTimeStats> watchtime) {
    return ZebrraTableCard(
      content: List.generate(
        watchtime.length,
        (index) => ZebrraTableContent(
          title: _globalStatsTitle(watchtime[index].queryDays),
          body: _globalStatsContent(
              watchtime[index].totalPlays, watchtime[index].totalTime!),
        ),
      ),
    );
  }

  String _globalStatsTitle(int? days) {
    if (days == 0) return 'All Time';
    if (days == 1) return '24 Hours';
    return '$days Days';
  }

  String _globalStatsContent(int? plays, Duration duration) {
    String _plays = plays == 1 ? '1 Play' : '$plays Plays';
    return '$_plays\n${duration.asWordsTimestamp()}';
  }

  List<Widget> _playerStats(List<TautulliUserPlayerStats> player) =>
      List.generate(
        player.length,
        (index) => ZebrraTableCard(
          content: [
            ZebrraTableContent(title: 'player', body: player[index].playerName),
            ZebrraTableContent(title: 'platform', body: player[index].platform),
            ZebrraTableContent(
                title: 'plays',
                body: player[index].totalPlays == 1
                    ? '1 Play'
                    : '${player[index].totalPlays} Plays'),
          ],
        ),
      );
}
