part of 'trip_session_store.dart';

Future<TripSession?> _loadActiveImpl() async {
  final prefs = SharedPreferencesStore.global;
  final String? raw = prefs.getString(TripSessionStore._activeKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final TripSession session =
        TripSession.fromJson(Map<String, dynamic>.from(decoded));
    if (session.id.isEmpty || session.stage == TripSessionStage.none) {
      return null;
    }
    return session;
  } catch (_) {
    return null;
  }
}

Future<List<TripSession>> _loadArchiveImpl() async {
  final prefs = SharedPreferencesStore.global;
  final String? raw = prefs.getString(TripSessionStore._archiveKey);
  if (raw == null || raw.isEmpty) return const <TripSession>[];
  try {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List) return const <TripSession>[];
    return decoded
        .whereType<Map>()
        .map(
          (dynamic e) => TripSession.fromJson(Map<String, dynamic>.from(e)),
        )
        .where((TripSession s) => s.id.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const <TripSession>[];
  }
}
