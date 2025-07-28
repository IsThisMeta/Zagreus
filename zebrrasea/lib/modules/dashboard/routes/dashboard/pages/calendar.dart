import 'package:flutter/material.dart';

import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zebrrasea/modules/dashboard/core/api/data/abstract.dart';
import 'package:zebrrasea/modules/dashboard/core/state.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/calendar_view.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/schedule_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _State();
}

class _State extends State<CalendarPage>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<DashboardState>().resetToday();
    context.read<DashboardState>().resetUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: context.watch<DashboardState>().upcoming,
        builder: (
          BuildContext context,
          AsyncSnapshot<Map<DateTime, List<CalendarData>>> snapshot,
        ) {
          if (snapshot.hasError) {
            ZebrraLogger().error(
              'Failed to fetch unified calendar data',
              snapshot.error,
              snapshot.stackTrace,
            );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final events = snapshot.data!;
            return Selector<DashboardState, CalendarStartingType>(
              selector: (_, s) => s.calendarType,
              builder: (context, type, _) {
                if (type == CalendarStartingType.CALENDAR)
                  return CalendarView(events: events);
                else
                  return ScheduleView(events: events);
              },
            );
          }

          return const ZebrraLoader();
        },
      ),
    );
  }
}
