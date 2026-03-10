part of 'trip_session_store.dart';

Future<void> _startSessionImpl({
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
  await TripSessionStore._saveActive(session);
}

Future<void> _markArrivedAtPickupImpl() async {
  final TripSession? session = await TripSessionStore.loadActive();
  if (session == null) return;
  await TripSessionStore._saveActive(
    session.copyWith(
      stage: TripSessionStage.arrivedAtPickup,
      arrivedAtPickupEpochMs: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

Future<void> _markTripStartedImpl({required String rideCode}) async {
  final TripSession? session = await TripSessionStore.loadActive();
  if (session == null) return;
  final int now = DateTime.now().millisecondsSinceEpoch;
  await TripSessionStore._saveActive(
    session.copyWith(
      stage: TripSessionStage.tripStarted,
      rideCode: rideCode,
      rideCodeEnteredEpochMs: now,
      tripStartedEpochMs: now,
    ),
  );
}

Future<void> _markNavigationBeganImpl({
  List<TripLatLng> routePoints = const <TripLatLng>[],
}) async {
  final TripSession? session = await TripSessionStore.loadActive();
  if (session == null) return;
  await TripSessionStore._saveActive(
    session.copyWith(
      stage: TripSessionStage.navigating,
      navigationBeganEpochMs: DateTime.now().millisecondsSinceEpoch,
      routePointCount: routePoints.length,
      routeStartPoint: routePoints.isNotEmpty ? routePoints.first : null,
      routeEndPoint: routePoints.isNotEmpty ? routePoints.last : null,
    ),
  );
}

Future<void> _markTripCompletedImpl() async {
  final TripSession? session = await TripSessionStore.loadActive();
  if (session == null) return;
  await TripSessionStore._saveActive(
    session.copyWith(
      stage: TripSessionStage.tripCompleted,
      tripCompletedEpochMs: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

Future<void> _savePaymentDetailsImpl({
  required double totalEarnings,
  required double tripFare,
  required double tips,
  required double discountPercent,
  required double discountAmount,
  required String paymentLink,
  String method = 'cash',
}) async {
  final TripSession? session = await TripSessionStore.loadActive();
  if (session == null) return;
  await TripSessionStore._saveActive(
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

Future<void> _markPaymentReceivedImpl({String method = 'cash'}) async {
  final TripSession? session = await TripSessionStore.loadActive();
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
  await TripSessionStore._saveActive(
    session.copyWith(
      stage: TripSessionStage.paymentReceived,
      payment: updatedPayment,
    ),
  );
}

Future<void> _savePassengerRatingImpl({
  required int stars,
  required List<String> tags,
  required String comment,
}) async {
  final TripSession? session = await TripSessionStore.loadActive();
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
  await TripSessionStore._saveActive(completed);
  await TripSessionStore._archiveSession(completed);
}

Future<void> _endSessionImpl() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(TripSessionStore._activeKey);
}

Future<void> _clearAllImpl() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(TripSessionStore._activeKey);
  await prefs.remove(TripSessionStore._archiveKey);
}

Future<void> _saveActiveImpl(TripSession session) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    TripSessionStore._activeKey,
    jsonEncode(session.toJson()),
  );
}

Future<void> _archiveSessionImpl(TripSession session) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<TripSession> archive = (await TripSessionStore.loadArchive()).toList();
  final int existing = archive.indexWhere((TripSession s) => s.id == session.id);
  if (existing == -1) {
    archive.insert(0, session);
  } else {
    archive[existing] = session;
  }
  if (archive.length > TripSessionStore._archiveLimit) {
    archive.removeRange(TripSessionStore._archiveLimit, archive.length);
  }
  await prefs.setString(
    TripSessionStore._archiveKey,
    jsonEncode(
      archive.map((TripSession s) => s.toJson()).toList(growable: false),
    ),
  );
}
