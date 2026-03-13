import 'dart:io';

import 'package:goapp/core/storage/online_hours_store.dart';

class OnlineHoursMockApi {
  const OnlineHoursMockApi();
  static final bool _isTestRuntime = Platform.environment.containsKey(
    'FLUTTER_TEST',
  );

  Future<int> fetchTodayOnlineMinutes() async {
    final DateTime now = DateTime.now();
    return fetchOnlineMinutesForDate(_dateKey(now));
  }

  Future<void> syncTodayOnlineMinutes(int minutes) async {
    final DateTime now = DateTime.now();
    await syncOnlineMinutesForDate(_dateKey(now), minutes);
  }

  Future<int> fetchOnlineMinutesForDate(String dateKey) async {
    if (!_isTestRuntime) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    return OnlineHoursStore.loadMinutesForDate(dateKey);
  }

  Future<void> syncOnlineMinutesForDate(String dateKey, int minutes) async {
    if (!_isTestRuntime) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    await OnlineHoursStore.saveMinutesForDate(dateKey, minutes);
    if (dateKey == _dateKey(DateTime.now())) {
      await OnlineHoursStore.saveTodayMinutes(minutes);
    }
  }

  Future<Map<String, int>> fetchOnlineMinutesHistory({
    int limitDays = 30,
  }) async {
    if (!_isTestRuntime) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    final Map<String, int> history =
        await OnlineHoursStore.loadDailyMinutesHistory();
    final List<String> keys = history.keys.toList()..sort();
    if (keys.length <= limitDays) return history;

    final Iterable<String> keep = keys.skip(keys.length - limitDays);
    final Map<String, int> limited = <String, int>{};
    for (final String key in keep) {
      limited[key] = history[key] ?? 0;
    }
    return limited;
  }

  String _dateKey(DateTime dt) {
    final String month = dt.month.toString().padLeft(2, '0');
    final String day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day';
  }
}
