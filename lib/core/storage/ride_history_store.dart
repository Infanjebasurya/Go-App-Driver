import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RideHistoryTrip {
  const RideHistoryTrip({
    required this.id,
    required this.acceptedAtEpochMs,
    required this.pickupLocation,
    required this.dropLocation,
    this.pickedUpAtEpochMs,
    this.startedAtEpochMs,
    this.completedAtEpochMs,
    this.canceledAtEpochMs,
    this.canceledBy,
    this.cancelReason,
    this.fareLabel,
    this.distanceLabel,
    this.tripAmount,
    this.incentiveAmount,
    this.cancellationFeeAmount,
    this.netEarningAmount,
  });

  final String id;
  final int acceptedAtEpochMs;
  final String pickupLocation;
  final String dropLocation;
  final int? pickedUpAtEpochMs;
  final int? startedAtEpochMs;
  final int? completedAtEpochMs;
  final int? canceledAtEpochMs;
  final String? canceledBy;
  final String? cancelReason;
  final String? fareLabel;
  final String? distanceLabel;
  final double? tripAmount;
  final double? incentiveAmount;
  final double? cancellationFeeAmount;
  final double? netEarningAmount;

  RideHistoryTrip copyWith({
    int? pickedUpAtEpochMs,
    int? startedAtEpochMs,
    int? completedAtEpochMs,
    int? canceledAtEpochMs,
    String? canceledBy,
    String? cancelReason,
    String? fareLabel,
    String? distanceLabel,
    double? tripAmount,
    double? incentiveAmount,
    double? cancellationFeeAmount,
    double? netEarningAmount,
    bool clearFare = false,
    bool clearDistance = false,
  }) {
    return RideHistoryTrip(
      id: id,
      acceptedAtEpochMs: acceptedAtEpochMs,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      pickedUpAtEpochMs: pickedUpAtEpochMs ?? this.pickedUpAtEpochMs,
      startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
      completedAtEpochMs: completedAtEpochMs ?? this.completedAtEpochMs,
      canceledAtEpochMs: canceledAtEpochMs ?? this.canceledAtEpochMs,
      canceledBy: canceledBy ?? this.canceledBy,
      cancelReason: cancelReason ?? this.cancelReason,
      fareLabel: clearFare ? null : (fareLabel ?? this.fareLabel),
      distanceLabel: clearDistance ? null : (distanceLabel ?? this.distanceLabel),
      tripAmount: tripAmount ?? this.tripAmount,
      incentiveAmount: incentiveAmount ?? this.incentiveAmount,
      cancellationFeeAmount:
          cancellationFeeAmount ?? this.cancellationFeeAmount,
      netEarningAmount: netEarningAmount ?? this.netEarningAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'acceptedAtEpochMs': acceptedAtEpochMs,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickedUpAtEpochMs': pickedUpAtEpochMs,
      'startedAtEpochMs': startedAtEpochMs,
      'completedAtEpochMs': completedAtEpochMs,
      'canceledAtEpochMs': canceledAtEpochMs,
      'canceledBy': canceledBy,
      'cancelReason': cancelReason,
      'fareLabel': fareLabel,
      'distanceLabel': distanceLabel,
      'tripAmount': tripAmount,
      'incentiveAmount': incentiveAmount,
      'cancellationFeeAmount': cancellationFeeAmount,
      'netEarningAmount': netEarningAmount,
    };
  }

  factory RideHistoryTrip.fromJson(Map<String, dynamic> json) {
    int? readInt(dynamic value) => value is int ? value : null;

    return RideHistoryTrip(
      id: (json['id'] as String?) ?? '',
      acceptedAtEpochMs: readInt(json['acceptedAtEpochMs']) ?? 0,
      pickupLocation: (json['pickupLocation'] as String?) ?? '',
      dropLocation: (json['dropLocation'] as String?) ?? '',
      pickedUpAtEpochMs: readInt(json['pickedUpAtEpochMs']),
      startedAtEpochMs: readInt(json['startedAtEpochMs']),
      completedAtEpochMs: readInt(json['completedAtEpochMs']),
      canceledAtEpochMs: readInt(json['canceledAtEpochMs']),
      canceledBy: json['canceledBy'] as String?,
      cancelReason: json['cancelReason'] as String?,
      fareLabel: json['fareLabel'] as String?,
      distanceLabel: json['distanceLabel'] as String?,
      tripAmount: (json['tripAmount'] as num?)?.toDouble(),
      incentiveAmount: (json['incentiveAmount'] as num?)?.toDouble(),
      cancellationFeeAmount:
          (json['cancellationFeeAmount'] as num?)?.toDouble(),
      netEarningAmount: (json['netEarningAmount'] as num?)?.toDouble(),
    );
  }
}

class RideHistoryStore {
  RideHistoryStore._();

  static const String _historyKey = 'ride_history_items_v1';
  static const String _activeTripIdKey = 'ride_history_active_trip_id_v1';
  static const int _maxItems = 100;

  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_activeTripIdKey);
  }

  static Future<List<RideHistoryTrip>> loadTrips() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const <RideHistoryTrip>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return const <RideHistoryTrip>[];
      final List<RideHistoryTrip> items = decoded
          .whereType<Map>()
          .map(
            (dynamic entry) =>
                RideHistoryTrip.fromJson(Map<String, dynamic>.from(entry)),
          )
          .where((RideHistoryTrip item) => item.id.isNotEmpty)
          .toList(growable: false);
      items.sort(
        (RideHistoryTrip a, RideHistoryTrip b) =>
            b.acceptedAtEpochMs.compareTo(a.acceptedAtEpochMs),
      );
      return items;
    } catch (_) {
      return const <RideHistoryTrip>[];
    }
  }

  static Future<void> startTrip({
    required String pickupLocation,
    required String dropLocation,
    String? fareLabel,
    String? distanceLabel,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String id = 'trip_$now';
    final double parsedFare = _parseCurrency(fareLabel);
    final RideHistoryTrip trip = RideHistoryTrip(
      id: id,
      acceptedAtEpochMs: now,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
      tripAmount: parsedFare > 0 ? parsedFare : null,
      netEarningAmount: parsedFare > 0 ? parsedFare : null,
    );
    await _upsertTrip(trip, setAsActive: true);
  }

  static Future<void> markPickedUpNow() async {
    final RideHistoryTrip? active = await _loadTripForProgressUpdate();
    if (active == null) return;
    await _upsertTrip(
      active.copyWith(
        pickedUpAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Future<void> markStartedNow() async {
    final RideHistoryTrip? active = await _loadTripForProgressUpdate();
    if (active == null) return;
    await _upsertTrip(
      active.copyWith(
        startedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Future<void> markCompletedNow({
    String? fareLabel,
    String? distanceLabel,
    double? tripAmount,
    double? incentiveAmount,
    double? cancellationFeeAmount,
    double? netEarningAmount,
  }) async {
    final String? activeTripId = await _loadActiveTripId();
    final RideHistoryTrip? active = await _loadTripForProgressUpdate();
    if (active == null) return;
    await _upsertTrip(
      active.copyWith(
        completedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        fareLabel: fareLabel,
        distanceLabel: distanceLabel,
        tripAmount: tripAmount,
        incentiveAmount: incentiveAmount,
        cancellationFeeAmount: cancellationFeeAmount,
        netEarningAmount: netEarningAmount,
      ),
      clearActive: activeTripId != null && activeTripId == active.id,
    );
  }

  static Future<void> markCanceledNowOrCreate({
    required String canceledBy,
    required String cancelReason,
    String? pickupLocation,
    String? dropLocation,
    String? fareLabel,
    double cancellationFeeAmount = 0,
  }) async {
    final RideHistoryTrip? active = await _loadTripForProgressUpdate();
    final int now = DateTime.now().millisecondsSinceEpoch;

    if (active != null) {
      await _upsertTrip(
        active.copyWith(
          canceledAtEpochMs: now,
          canceledBy: canceledBy,
          cancelReason: cancelReason,
          fareLabel: fareLabel,
          cancellationFeeAmount: cancellationFeeAmount,
          netEarningAmount: cancellationFeeAmount > 0
              ? cancellationFeeAmount
              : 0,
        ),
        clearActive: true,
      );
      return;
    }

    final RideHistoryTrip trip = RideHistoryTrip(
      id: 'trip_$now',
      acceptedAtEpochMs: now,
      pickupLocation: pickupLocation ?? 'Unknown pickup',
      dropLocation: dropLocation ?? 'Unknown drop',
      canceledAtEpochMs: now,
      canceledBy: canceledBy,
      cancelReason: cancelReason,
      fareLabel: fareLabel,
      cancellationFeeAmount: cancellationFeeAmount,
      netEarningAmount: cancellationFeeAmount > 0 ? cancellationFeeAmount : 0,
    );
    await _upsertTrip(trip, clearActive: true);
  }

  static Future<void> markCompletedNowOrCreate({
    required String pickupLocation,
    required String dropLocation,
    String? fareLabel,
    String? distanceLabel,
    double? tripAmount,
    double? incentiveAmount,
    double? cancellationFeeAmount,
    double? netEarningAmount,
  }) async {
    final RideHistoryTrip? active = await _loadTripForProgressUpdate();
    if (active != null) {
      await markCompletedNow(
        fareLabel: fareLabel,
        distanceLabel: distanceLabel,
        tripAmount: tripAmount,
        incentiveAmount: incentiveAmount,
        cancellationFeeAmount: cancellationFeeAmount,
        netEarningAmount: netEarningAmount,
      );
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final double parsedFare = _parseCurrency(fareLabel);
    final RideHistoryTrip trip = RideHistoryTrip(
      id: 'trip_$now',
      acceptedAtEpochMs: now,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      pickedUpAtEpochMs: now,
      startedAtEpochMs: now,
      completedAtEpochMs: now,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
      tripAmount: tripAmount ?? (parsedFare > 0 ? parsedFare : null),
      incentiveAmount: incentiveAmount,
      cancellationFeeAmount: cancellationFeeAmount,
      netEarningAmount:
          netEarningAmount ?? (parsedFare > 0 ? parsedFare : null),
    );
    await _upsertTrip(trip);
  }

  static Future<void> updateLatestCompletedDetails({
    String? fareLabel,
    String? distanceLabel,
    double? tripAmount,
    double? incentiveAmount,
    double? cancellationFeeAmount,
    double? netEarningAmount,
  }) async {
    final List<RideHistoryTrip> trips = (await loadTrips()).toList();
    final int index = trips.indexWhere((RideHistoryTrip trip) {
      return trip.completedAtEpochMs != null;
    });
    if (index == -1) return;
    final RideHistoryTrip current = trips[index];
    final RideHistoryTrip updated = current.copyWith(
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
      tripAmount: tripAmount,
      incentiveAmount: incentiveAmount,
      cancellationFeeAmount: cancellationFeeAmount,
      netEarningAmount: netEarningAmount,
    );
    trips[index] = updated;
    await _saveTrips(trips);
  }

  static double _parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  static Future<String?> _loadActiveTripId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? activeId = prefs.getString(_activeTripIdKey);
    if (activeId == null || activeId.isEmpty) return null;
    return activeId;
  }

  static Future<RideHistoryTrip?> _loadActiveTrip() async {
    final String? activeId = await _loadActiveTripId();
    if (activeId == null || activeId.isEmpty) return null;
    final List<RideHistoryTrip> trips = await loadTrips();
    for (final RideHistoryTrip trip in trips) {
      if (trip.id == activeId) return trip;
    }
    return null;
  }

  static Future<RideHistoryTrip?> _loadTripForProgressUpdate() async {
    final RideHistoryTrip? active = await _loadActiveTrip();
    if (active != null) return active;

    final List<RideHistoryTrip> trips = await loadTrips();
    for (final RideHistoryTrip trip in trips) {
      if (trip.completedAtEpochMs == null) return trip;
    }
    return null;
  }

  static Future<void> _upsertTrip(
    RideHistoryTrip trip, {
    bool setAsActive = false,
    bool clearActive = false,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<RideHistoryTrip> trips = (await loadTrips()).toList();
    final int existing = trips.indexWhere((RideHistoryTrip t) => t.id == trip.id);
    if (existing == -1) {
      trips.insert(0, trip);
    } else {
      trips[existing] = trip;
    }
    trips.sort(
      (RideHistoryTrip a, RideHistoryTrip b) =>
          b.acceptedAtEpochMs.compareTo(a.acceptedAtEpochMs),
    );
    if (trips.length > _maxItems) {
      trips.removeRange(_maxItems, trips.length);
    }
    await _saveTrips(trips);
    if (setAsActive) {
      await prefs.setString(_activeTripIdKey, trip.id);
    }
    if (clearActive) {
      await prefs.remove(_activeTripIdKey);
    }
  }

  static Future<void> _saveTrips(List<RideHistoryTrip> trips) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      trips.map((RideHistoryTrip trip) => trip.toJson()).toList(growable: false),
    );
    await prefs.setString(_historyKey, encoded);
  }
}
