import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OnlineHoursStore {
  OnlineHoursStore._();

  static const String _dateKey = 'driver_online_hours_date_v1';
  static const String _minutesKey = 'driver_online_hours_minutes_v1';
  static const String _historyKey = 'driver_online_hours_history_v1';
  static const String _activeSessionStartMsKey =
      'driver_online_active_session_start_ms_v1';
  static const int _maxHistoryDays = 90;

  static String _todayKey() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  static Future<int> loadTodayMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String today = _todayKey();
    final String? storedDate = prefs.getString(_dateKey);
    if (storedDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_minutesKey, 0);
      await saveMinutesForDate(today, 0);
      return 0;
    }
    final int cached = prefs.getInt(_minutesKey) ?? 0;
    final int byDate = await loadMinutesForDate(today);
    return byDate >= cached ? byDate : cached;
  }

  static Future<void> saveTodayMinutes(int minutes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int safeMinutes = minutes < 0 ? 0 : minutes;
    await prefs.setString(_dateKey, _todayKey());
    await prefs.setInt(_minutesKey, safeMinutes);
    await saveMinutesForDate(_todayKey(), safeMinutes);
  }

  static Future<int> loadMinutesForDate(String dateKey) async {
    final Map<String, int> history = await loadDailyMinutesHistory();
    return history[dateKey] ?? 0;
  }

  static Future<void> saveMinutesForDate(String dateKey, int minutes) async {
    final int safeMinutes = minutes < 0 ? 0 : minutes;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, int> history = await loadDailyMinutesHistory();
    history[dateKey] = safeMinutes;

    final List<String> ordered = history.keys.toList()..sort();
    if (ordered.length > _maxHistoryDays) {
      final int removeCount = ordered.length - _maxHistoryDays;
      for (int i = 0; i < removeCount; i += 1) {
        history.remove(ordered[i]);
      }
    }
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  static Future<Map<String, int>> loadDailyMinutesHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return <String, int>{};
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <String, int>{};

    final Map<String, int> history = <String, int>{};
    decoded.forEach((key, value) {
      final int? parsed = switch (value) {
        int v => v,
        num v => v.toInt(),
        String v => int.tryParse(v),
        _ => null,
      };
      history[key] = parsed == null || parsed < 0 ? 0 : parsed;
    });
    return history;
  }

  static Future<int?> loadActiveSessionStartEpochMs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? value = prefs.getInt(_activeSessionStartMsKey);
    if (value == null || value <= 0) return null;
    return value;
  }

  static Future<void> saveActiveSessionStartEpochMs(int epochMs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeSessionStartMsKey, epochMs);
  }

  static Future<void> clearActiveSessionStartEpochMs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeSessionStartMsKey);
  }
}
