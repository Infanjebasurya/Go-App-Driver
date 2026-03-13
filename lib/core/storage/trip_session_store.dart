import 'dart:convert';

import 'shared_preferences_store.dart';

part 'trip_session_reader.dart';
part 'trip_session_writer.dart';

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
  String toString() =>
      '(${latitude.toStringAsFixed(5)}, '
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
    return Duration(milliseconds: tripCompletedEpochMs! - tripStartedEpochMs!);
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
      pickupLatLng: readLatLng(json['pickupLatLng']) ?? const TripLatLng(0, 0),
      dropLatLng: readLatLng(json['dropLatLng']) ?? const TripLatLng(0, 0),
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

class TripSessionStore {
  TripSessionStore._();

  static const String _activeKey = 'trip_session_active_v1';
  static const String _archiveKey = 'trip_session_archive_v1';
  static const int _archiveLimit = 50;

  static Future<TripSession?> loadActive() => _loadActiveImpl();

  static Future<List<TripSession>> loadArchive() => _loadArchiveImpl();

  static Future<void> startSession({
    required TripLatLng pickupLatLng,
    required TripLatLng dropLatLng,
    required String pickupAddress,
    required String dropAddress,
    required String fareLabel,
    required String distanceLabel,
  }) {
    return _startSessionImpl(
      pickupLatLng: pickupLatLng,
      dropLatLng: dropLatLng,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
    );
  }

  static Future<void> markArrivedAtPickup() => _markArrivedAtPickupImpl();

  static Future<void> markTripStarted({required String rideCode}) {
    return _markTripStartedImpl(rideCode: rideCode);
  }

  static Future<void> markNavigationBegan({
    List<TripLatLng> routePoints = const <TripLatLng>[],
  }) {
    return _markNavigationBeganImpl(routePoints: routePoints);
  }

  static Future<void> markTripCompleted() => _markTripCompletedImpl();

  static Future<void> savePaymentDetails({
    required double totalEarnings,
    required double tripFare,
    required double tips,
    required double discountPercent,
    required double discountAmount,
    required String paymentLink,
    String method = 'cash',
  }) {
    return _savePaymentDetailsImpl(
      totalEarnings: totalEarnings,
      tripFare: tripFare,
      tips: tips,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      paymentLink: paymentLink,
      method: method,
    );
  }

  static Future<void> markPaymentReceived({String method = 'cash'}) {
    return _markPaymentReceivedImpl(method: method);
  }

  static Future<void> savePassengerRating({
    required int stars,
    required List<String> tags,
    required String comment,
  }) {
    return _savePassengerRatingImpl(stars: stars, tags: tags, comment: comment);
  }

  static Future<void> endSession() => _endSessionImpl();

  static Future<void> clearAll() => _clearAllImpl();

  static Future<void> _saveActive(TripSession session) =>
      _saveActiveImpl(session);

  static Future<void> _archiveSession(TripSession session) {
    return _archiveSessionImpl(session);
  }
}
