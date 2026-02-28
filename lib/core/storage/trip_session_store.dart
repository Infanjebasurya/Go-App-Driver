import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// ─── Stage ────────────────────────────────────────────────────────────────────

/// Every distinct phase a trip goes through, in order.
/// A session always advances forward; it never goes backward.
enum TripSessionStage {
  /// No active session.
  none,

  /// Order accepted on the available-orders screen.
  orderAccepted,

  /// Captain arrived at the pickup point.
  arrivedAtPickup,

  /// Passenger OTP verified; trip officially started.
  tripStarted,

  /// Captain began the navigation leg to the drop location.
  navigating,

  /// Captain reached the drop location and marked the trip complete.
  tripCompleted,

  /// Payment details (earnings, breakdown) received from the server.
  paymentReceived,

  /// Captain submitted the post-ride passenger rating.
  rated,
}

// ─── Coords ───────────────────────────────────────────────────────────────────

/// A lightweight lat/lng pair that survives serialisation to JSON.
class TripLatLng {
  const TripLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'lat': latitude,
    'lng': longitude,
  };

  factory TripLatLng.fromJson(Map<String, dynamic> json) {
    return TripLatLng(
      (json['lat'] as num?)?.toDouble() ?? 0.0,
      (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => '(${latitude.toStringAsFixed(5)}, '
      '${longitude.toStringAsFixed(5)})';
}

// ─── Payment breakdown ────────────────────────────────────────────────────────

class TripPaymentDetails {
  const TripPaymentDetails({
    required this.totalEarnings,
    required this.tripFare,
    required this.tips,
    required this.discountPercent,
    required this.discountAmount,
    required this.paymentLink,
    required this.method,
    this.receivedAtEpochMs,
  });

  /// Net amount the captain earns (after discount, plus tips).
  final double totalEarnings;

  /// Base fare before tips/discounts.
  final double tripFare;

  final double tips;

  /// Discount percentage applied (e.g. 10 for 10 %).
  final double discountPercent;

  /// Rupee amount discounted.
  final double discountAmount;

  /// QR / UPI link shown to the passenger.
  final String paymentLink;

  /// How the passenger paid: "cash" | "online".
  final String method;

  /// When the captain confirmed payment received (epoch ms).
  final int? receivedAtEpochMs;

  TripPaymentDetails copyWith({
    double? totalEarnings,
    double? tripFare,
    double? tips,
    double? discountPercent,
    double? discountAmount,
    String? paymentLink,
    String? method,
    int? receivedAtEpochMs,
  }) {
    return TripPaymentDetails(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      tripFare: tripFare ?? this.tripFare,
      tips: tips ?? this.tips,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentLink: paymentLink ?? this.paymentLink,
      method: method ?? this.method,
      receivedAtEpochMs: receivedAtEpochMs ?? this.receivedAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalEarnings': totalEarnings,
    'tripFare': tripFare,
    'tips': tips,
    'discountPercent': discountPercent,
    'discountAmount': discountAmount,
    'paymentLink': paymentLink,
    'method': method,
    'receivedAtEpochMs': receivedAtEpochMs,
  };

  factory TripPaymentDetails.fromJson(Map<String, dynamic> json) {
    return TripPaymentDetails(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      tripFare: (json['tripFare'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      paymentLink: (json['paymentLink'] as String?) ?? '',
      method: (json['method'] as String?) ?? 'cash',
      receivedAtEpochMs: json['receivedAtEpochMs'] as int?,
    );
  }
}

// ─── Passenger rating ─────────────────────────────────────────────────────────

class TripPassengerRating {
  const TripPassengerRating({
    required this.stars,
    required this.tags,
    required this.comment,
    required this.submittedAtEpochMs,
  });

  /// 1–5 stars.
  final int stars;

  /// Quick-select tags the captain chose (e.g. "Punctual").
  final List<String> tags;

  final String comment;

  final int submittedAtEpochMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'stars': stars,
    'tags': tags,
    'comment': comment,
    'submittedAtEpochMs': submittedAtEpochMs,
  };

  factory TripPassengerRating.fromJson(Map<String, dynamic> json) {
    return TripPassengerRating(
      stars: (json['stars'] as int?) ?? 5,
      tags: List<String>.from((json['tags'] as List<dynamic>?) ?? <dynamic>[]),
      comment: (json['comment'] as String?) ?? '',
      submittedAtEpochMs:
          (json['submittedAtEpochMs'] as int?) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

// ─── Session ──────────────────────────────────────────────────────────────────

/// The complete snapshot of a single trip from order acceptance to final rating.
///
/// Fields are accumulated incrementally — early fields are set at order
/// acceptance and the later fields fill in as the trip progresses.  Null means
/// "not yet reached that stage".
class TripSession {
  const TripSession({
    required this.id,
    required this.stage,
    required this.acceptedAtEpochMs,

    // ── Order details ──────────────────────────────────────────────
    required this.pickupLatLng,
    required this.dropLatLng,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fareLabel,
    required this.distanceLabel,

    // ── Stage timestamps ───────────────────────────────────────────
    this.arrivedAtPickupEpochMs,
    this.rideCodeEnteredEpochMs,
    this.rideCode,
    this.tripStartedEpochMs,
    this.navigationBeganEpochMs,
    this.tripCompletedEpochMs,

    // ── Route snapshot (optional, stored as [[lat,lng],...]) ───────
    this.routePointCount,
    this.routeStartPoint,
    this.routeEndPoint,

    // ── Payment & rating ───────────────────────────────────────────
    this.payment,
    this.passengerRating,
  });

  // ── Identity ────────────────────────────────────────────────────────────────
  final String id;
  final TripSessionStage stage;
  final int acceptedAtEpochMs;

  // ── Order details ────────────────────────────────────────────────────────────
  final TripLatLng pickupLatLng;
  final TripLatLng dropLatLng;
  final String pickupAddress;
  final String dropAddress;

  /// Formatted fare shown on the order card, e.g. "₹90".
  final String fareLabel;

  /// Formatted distance shown on the order card, e.g. "2.5 km".
  final String distanceLabel;

  // ── Stage timestamps ─────────────────────────────────────────────────────────
  final int? arrivedAtPickupEpochMs;

  /// The OTP the passenger gave the captain (stored for audit / debug).
  final String? rideCode;
  final int? rideCodeEnteredEpochMs;

  final int? tripStartedEpochMs;
  final int? navigationBeganEpochMs;
  final int? tripCompletedEpochMs;

  // ── Route metadata ───────────────────────────────────────────────────────────
  /// How many LatLng points were in the computed route.
  final int? routePointCount;

  /// First point of the computed route (driver's position at trip start).
  final TripLatLng? routeStartPoint;

  /// Last point of the computed route (drop location).
  final TripLatLng? routeEndPoint;

  // ── Payment ──────────────────────────────────────────────────────────────────
  final TripPaymentDetails? payment;

  // ── Post-trip rating ─────────────────────────────────────────────────────────
  final TripPassengerRating? passengerRating;

  // ── Derived convenience getters ──────────────────────────────────────────────

  /// Total trip duration from start to completion. Null if not yet completed.
  Duration? get tripDuration {
    if (tripStartedEpochMs == null || tripCompletedEpochMs == null) return null;
    return Duration(
      milliseconds: tripCompletedEpochMs! - tripStartedEpochMs!,
    );
  }

  /// Duration spent waiting at pickup before the passenger boarded.
  Duration? get pickupWaitDuration {
    if (arrivedAtPickupEpochMs == null || tripStartedEpochMs == null) {
      return null;
    }
    return Duration(
      milliseconds: tripStartedEpochMs! - arrivedAtPickupEpochMs!,
    );
  }

  bool get isComplete => stage == TripSessionStage.rated;
  bool get isPaymentReceived =>
      stage.index >= TripSessionStage.paymentReceived.index;

  // ── copyWith ─────────────────────────────────────────────────────────────────

  TripSession copyWith({
    TripSessionStage? stage,
    int? arrivedAtPickupEpochMs,
    String? rideCode,
    int? rideCodeEnteredEpochMs,
    int? tripStartedEpochMs,
    int? navigationBeganEpochMs,
    int? routePointCount,
    TripLatLng? routeStartPoint,
    TripLatLng? routeEndPoint,
    int? tripCompletedEpochMs,
    TripPaymentDetails? payment,
    TripPassengerRating? passengerRating,
  }) {
    return TripSession(
      id: id,
      stage: stage ?? this.stage,
      acceptedAtEpochMs: acceptedAtEpochMs,
      pickupLatLng: pickupLatLng,
      dropLatLng: dropLatLng,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
      arrivedAtPickupEpochMs:
          arrivedAtPickupEpochMs ?? this.arrivedAtPickupEpochMs,
      rideCode: rideCode ?? this.rideCode,
      rideCodeEnteredEpochMs:
          rideCodeEnteredEpochMs ?? this.rideCodeEnteredEpochMs,
      tripStartedEpochMs: tripStartedEpochMs ?? this.tripStartedEpochMs,
      navigationBeganEpochMs:
          navigationBeganEpochMs ?? this.navigationBeganEpochMs,
      routePointCount: routePointCount ?? this.routePointCount,
      routeStartPoint: routeStartPoint ?? this.routeStartPoint,
      routeEndPoint: routeEndPoint ?? this.routeEndPoint,
      tripCompletedEpochMs: tripCompletedEpochMs ?? this.tripCompletedEpochMs,
      payment: payment ?? this.payment,
      passengerRating: passengerRating ?? this.passengerRating,
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'stage': stage.name,
    'acceptedAtEpochMs': acceptedAtEpochMs,
    'pickupLatLng': pickupLatLng.toJson(),
    'dropLatLng': dropLatLng.toJson(),
    'pickupAddress': pickupAddress,
    'dropAddress': dropAddress,
    'fareLabel': fareLabel,
    'distanceLabel': distanceLabel,
    'arrivedAtPickupEpochMs': arrivedAtPickupEpochMs,
    'rideCode': rideCode,
    'rideCodeEnteredEpochMs': rideCodeEnteredEpochMs,
    'tripStartedEpochMs': tripStartedEpochMs,
    'navigationBeganEpochMs': navigationBeganEpochMs,
    'routePointCount': routePointCount,
    'routeStartPoint': routeStartPoint?.toJson(),
    'routeEndPoint': routeEndPoint?.toJson(),
    'tripCompletedEpochMs': tripCompletedEpochMs,
    'payment': payment?.toJson(),
    'passengerRating': passengerRating?.toJson(),
  };

  factory TripSession.fromJson(Map<String, dynamic> json) {
    TripLatLng? readLatLng(dynamic raw) {
      if (raw is! Map) return null;
      return TripLatLng.fromJson(Map<String, dynamic>.from(raw));
    }

    return TripSession(
      id: (json['id'] as String?) ?? '',
      stage: TripSessionStage.values.firstWhere(
        (TripSessionStage s) => s.name == json['stage'],
        orElse: () => TripSessionStage.none,
      ),
      acceptedAtEpochMs: (json['acceptedAtEpochMs'] as int?) ?? 0,
      pickupLatLng:
          readLatLng(json['pickupLatLng']) ?? const TripLatLng(0, 0),
      dropLatLng:
          readLatLng(json['dropLatLng']) ?? const TripLatLng(0, 0),
      pickupAddress: (json['pickupAddress'] as String?) ?? '',
      dropAddress: (json['dropAddress'] as String?) ?? '',
      fareLabel: (json['fareLabel'] as String?) ?? '',
      distanceLabel: (json['distanceLabel'] as String?) ?? '',
      arrivedAtPickupEpochMs: json['arrivedAtPickupEpochMs'] as int?,
      rideCode: json['rideCode'] as String?,
      rideCodeEnteredEpochMs: json['rideCodeEnteredEpochMs'] as int?,
      tripStartedEpochMs: json['tripStartedEpochMs'] as int?,
      navigationBeganEpochMs: json['navigationBeganEpochMs'] as int?,
      routePointCount: json['routePointCount'] as int?,
      routeStartPoint: readLatLng(json['routeStartPoint']),
      routeEndPoint: readLatLng(json['routeEndPoint']),
      tripCompletedEpochMs: json['tripCompletedEpochMs'] as int?,
      payment: json['payment'] is Map
          ? TripPaymentDetails.fromJson(
              Map<String, dynamic>.from(json['payment'] as Map),
            )
          : null,
      passengerRating: json['passengerRating'] is Map
          ? TripPassengerRating.fromJson(
              Map<String, dynamic>.from(json['passengerRating'] as Map),
            )
          : null,
    );
  }
}

// ─── Store ────────────────────────────────────────────────────────────────────

/// Persists the active trip's complete data from order acceptance to final
/// passenger rating, using [SharedPreferences].
///
/// One session key holds the current trip; a separate archive key holds the
/// last [_archiveLimit] completed sessions so they survive restarts.
///
/// Call sites:
/// ```
/// // 1 – Available orders screen (order accepted)
/// await TripSessionStore.startSession(pickupLatLng: ..., dropLatLng: ..., ...);
///
/// // 2 – Ride arrived screen
/// await TripSessionStore.markArrivedAtPickup();
///
/// // 3 – Enter ride code screen (OTP confirmed, trip starts)
/// await TripSessionStore.markTripStarted(rideCode: '1234');
///
/// // 4 – Passenger onboard screen (navigation begins)
/// await TripSessionStore.markNavigationBegan(routePoints: [...]);
///
/// // 5 – Trip navigation screen (drop reached)
/// await TripSessionStore.markTripCompleted();
///
/// // 6 – Ride complete screen (payment details received)
/// await TripSessionStore.savePaymentDetails(totalEarnings: ..., ...);
/// await TripSessionStore.markPaymentReceived();
///
/// // 7 – Rate experience screen (rating submitted)
/// await TripSessionStore.savePassengerRating(stars: 5, tags: [...], comment: '');
///
/// // At home screen init (session cleanly ended)
/// await TripSessionStore.endSession();
/// ```
class TripSessionStore {
  TripSessionStore._();

  static const String _activeKey = 'trip_session_active_v1';
  static const String _archiveKey = 'trip_session_archive_v1';
  static const int _archiveLimit = 50;

  // ── Read ──────────────────────────────────────────────────────────────────────

  /// Returns the currently active [TripSession], or `null` if no trip is running.
  static Future<TripSession?> loadActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_activeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final TripSession session =
          TripSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.id.isEmpty ||
          session.stage == TripSessionStage.none) {
        return null;
      }
      return session;
    } catch (_) {
      return null;
    }
  }

  /// Returns the archive of the last [_archiveLimit] completed sessions,
  /// newest first.
  static Future<List<TripSession>> loadArchive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_archiveKey);
    if (raw == null || raw.isEmpty) return const <TripSession>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return const <TripSession>[];
      return decoded
          .whereType<Map>()
          .map(
            (dynamic e) =>
                TripSession.fromJson(Map<String, dynamic>.from(e)),
          )
          .where((TripSession s) => s.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <TripSession>[];
    }
  }

  // ── Stage 1: Order accepted ───────────────────────────────────────────────────

  /// Creates a fresh session the moment the captain accepts an order.
  ///
  /// [pickupLatLng] and [dropLatLng] are the raw coordinates from the order
  /// card.  They are persisted so that the correct destination is available
  /// even after a crash and restart.
  static Future<void> startSession({
    required TripLatLng pickupLatLng,
    required TripLatLng dropLatLng,
    required String pickupAddress,
    required String dropAddress,
    required String fareLabel,
    required String distanceLabel,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final TripSession session = TripSession(
      id: 'trip_$now',
      stage: TripSessionStage.orderAccepted,
      acceptedAtEpochMs: now,
      pickupLatLng: pickupLatLng,
      dropLatLng: dropLatLng,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
    );
    await _saveActive(session);
  }

  // ── Stage 2: Arrived at pickup ────────────────────────────────────────────────

  /// Records the timestamp when the captain reached the passenger pickup point.
  static Future<void> markArrivedAtPickup() async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    await _saveActive(
      session.copyWith(
        stage: TripSessionStage.arrivedAtPickup,
        arrivedAtPickupEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ── Stage 3: Trip started (OTP verified) ─────────────────────────────────────

  /// Records the OTP the passenger gave and marks the trip as started.
  ///
  /// [rideCode] is the 4-digit string entered on the [EnterRideCodePage].
  static Future<void> markTripStarted({required String rideCode}) async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _saveActive(
      session.copyWith(
        stage: TripSessionStage.tripStarted,
        rideCode: rideCode,
        rideCodeEnteredEpochMs: now,
        tripStartedEpochMs: now,
      ),
    );
  }

  // ── Stage 4: Navigation began ─────────────────────────────────────────────────

  /// Records when the route animation / GPS navigation to the drop point began.
  ///
  /// [routePoints] is the list of LatLng coordinates that make up the computed
  /// route.  Only the count and first/last points are persisted to keep the
  /// payload small.
  static Future<void> markNavigationBegan({
    List<TripLatLng> routePoints = const <TripLatLng>[],
  }) async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    await _saveActive(
      session.copyWith(
        stage: TripSessionStage.navigating,
        navigationBeganEpochMs: DateTime.now().millisecondsSinceEpoch,
        routePointCount: routePoints.length,
        routeStartPoint:
            routePoints.isNotEmpty ? routePoints.first : null,
        routeEndPoint:
            routePoints.isNotEmpty ? routePoints.last : null,
      ),
    );
  }

  // ── Stage 5: Trip completed ───────────────────────────────────────────────────

  /// Records when the captain tapped "Complete Trip" at the drop location.
  static Future<void> markTripCompleted() async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    await _saveActive(
      session.copyWith(
        stage: TripSessionStage.tripCompleted,
        tripCompletedEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ── Stage 6: Payment details ──────────────────────────────────────────────────

  /// Caches the full payment breakdown received from the server (or mock).
  ///
  /// Call this as soon as [RideCompletionSummary] is available (e.g. in
  /// [RideCompletedScreen.initState]).  [markPaymentReceived] should be called
  /// separately when the captain confirms the passenger paid.
  static Future<void> savePaymentDetails({
    required double totalEarnings,
    required double tripFare,
    required double tips,
    required double discountPercent,
    required double discountAmount,
    required String paymentLink,
    String method = 'cash',
  }) async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    await _saveActive(
      session.copyWith(
        payment: TripPaymentDetails(
          totalEarnings: totalEarnings,
          tripFare: tripFare,
          tips: tips,
          discountPercent: discountPercent,
          discountAmount: discountAmount,
          paymentLink: paymentLink,
          method: method,
        ),
      ),
    );
  }

  /// Marks that the captain has collected / confirmed payment from the passenger.
  static Future<void> markPaymentReceived({String method = 'cash'}) async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final TripPaymentDetails updatedPayment =
        session.payment != null
            ? session.payment!.copyWith(
                receivedAtEpochMs: now,
                method: method,
              )
            : TripPaymentDetails(
                totalEarnings: 0,
                tripFare: 0,
                tips: 0,
                discountPercent: 0,
                discountAmount: 0,
                paymentLink: '',
                method: method,
                receivedAtEpochMs: now,
              );
    await _saveActive(
      session.copyWith(
        stage: TripSessionStage.paymentReceived,
        payment: updatedPayment,
      ),
    );
  }

  // ── Stage 7: Passenger rating ─────────────────────────────────────────────────

  /// Stores the captain's rating of the passenger and advances the session to
  /// the final [TripSessionStage.rated] stage.
  ///
  /// After this call the session is automatically archived (moved from the
  /// active slot into the archive list).
  static Future<void> savePassengerRating({
    required int stars,
    required List<String> tags,
    required String comment,
  }) async {
    final TripSession? session = await loadActive();
    if (session == null) return;
    final TripSession completed = session.copyWith(
      stage: TripSessionStage.rated,
      passengerRating: TripPassengerRating(
        stars: stars,
        tags: tags,
        comment: comment,
        submittedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _saveActive(completed);
    await _archiveSession(completed);
  }

  // ── Lifecycle helpers ─────────────────────────────────────────────────────────

  /// Clears the active session slot.  Call from [HomeScreen.initState] after a
  /// trip completes and the captain is back on the home screen.
  static Future<void> endSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
  }

  /// Clears everything — both the active session and the archive.
  /// Only for testing / dev use.
  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
    await prefs.remove(_archiveKey);
  }

  // ── Private helpers ────────────────────────────────────────────────────────────

  static Future<void> _saveActive(TripSession session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, jsonEncode(session.toJson()));
  }

  static Future<void> _archiveSession(TripSession session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<TripSession> archive = (await loadArchive()).toList();
    // Replace if the same id already exists (e.g. a re-submit), else prepend.
    final int existing =
        archive.indexWhere((TripSession s) => s.id == session.id);
    if (existing == -1) {
      archive.insert(0, session);
    } else {
      archive[existing] = session;
    }
    if (archive.length > _archiveLimit) {
      archive.removeRange(_archiveLimit, archive.length);
    }
    await prefs.setString(
      _archiveKey,
      jsonEncode(
        archive.map((TripSession s) => s.toJson()).toList(growable: false),
      ),
    );
  }
}
