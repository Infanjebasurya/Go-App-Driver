import 'dart:convert';

import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/utils/earnings_calculator.dart';
import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EarningsWalletMockApi {
  const EarningsWalletMockApi();

  static const String _walletOpsKey = 'earnings_wallet_ops_v1';

  Future<EarningsSnapshot> fetchSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();

    final DateTime now = DateTime.now();
    final int dayStartMs = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final int dayEndMs = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    double totalEarned = 0;
    double todaysEarnings = 0;
    int totalRides = 0;

    for (final RideHistoryTrip trip in history) {
      if (!EarningsCalculator.isSettledTrip(trip)) continue;
      final double tripEarning = EarningsCalculator.totalEarning(trip);
      if (tripEarning <= 0) continue;
      totalEarned += tripEarning;

      if (EarningsCalculator.isCompletedTrip(trip)) {
        totalRides += 1;
      }

      final int eventEpoch =
          trip.completedAtEpochMs ?? trip.canceledAtEpochMs ?? trip.acceptedAtEpochMs;
      if (eventEpoch >= dayStartMs && eventEpoch < dayEndMs) {
        todaysEarnings += tripEarning;
      }
    }

    final double walletBalance = await DriverWalletStore.loadBalance();
    return EarningsSnapshot(
      todaysEarnings: todaysEarnings,
      totalEarned: totalEarned,
      totalRides: totalRides,
      walletBalance: walletBalance,
    );
  }

  Future<List<TransactionItem>> fetchTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final List<TransactionItem> tripEarnings = await _buildTripEarningTransactions();
    final List<TransactionItem> manualOps = await _loadWalletOperationTransactions();
    final List<TransactionItem> all = <TransactionItem>[...tripEarnings, ...manualOps]
      ..sort((a, b) => b.eventEpochMs.compareTo(a.eventEpochMs));
    return all;
  }

  Future<double> rechargeWallet(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final double updatedBalance = await DriverWalletStore.addAmount(amount);
    await _appendWalletOperation(
      _WalletOperationRecord(
        id: 'wallet_recharge_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        isCredit: true,
        type: WalletTransactionType.recharge,
        eventEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return updatedBalance;
  }

  Future<double?> withdrawWallet(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final double? updatedBalance = await DriverWalletStore.subtractAmount(amount);
    if (updatedBalance == null) return null;
    await _appendWalletOperation(
      _WalletOperationRecord(
        id: 'wallet_withdraw_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        isCredit: false,
        type: WalletTransactionType.withdrawal,
        eventEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return updatedBalance;
  }

  Future<List<TransactionItem>> _buildTripEarningTransactions() async {
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();
    final List<TransactionItem> items = <TransactionItem>[];
    for (final RideHistoryTrip trip in history) {
      if (!EarningsCalculator.isSettledTrip(trip)) continue;
      final double earned = EarningsCalculator.totalEarning(trip);
      if (earned <= 0) continue;
      final int eventEpoch =
          trip.completedAtEpochMs ?? trip.canceledAtEpochMs ?? trip.acceptedAtEpochMs;
      final String title = 'Trip Earning #${_shortTripId(trip.id)}';
      items.add(
        TransactionItem(
          id: 'trip_${trip.id}',
          title: title,
          subtitle: _formatRelativeTime(eventEpoch),
          amount: '+\u20B9${earned.toStringAsFixed(2)}',
          amountValue: earned,
          isCredit: true,
          type: WalletTransactionType.earning,
          eventEpochMs: eventEpoch,
        ),
      );
    }
    return items;
  }

  Future<List<TransactionItem>> _loadWalletOperationTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_walletOpsKey);
    if (raw == null || raw.isEmpty) return const <TransactionItem>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return const <TransactionItem>[];
      return decoded
          .whereType<Map>()
          .map(
            (e) => _WalletOperationRecord.fromJson(Map<String, dynamic>.from(e)),
          )
          .map(
            (record) => TransactionItem(
              id: record.id,
              title: record.type == WalletTransactionType.withdrawal
                  ? 'Bank Transfer'
                  : 'Wallet Recharge',
              subtitle: _formatRelativeTime(record.eventEpochMs),
              amount:
                  '${record.isCredit ? '+' : '-'}\u20B9${record.amount.toStringAsFixed(2)}',
              amountValue: record.amount,
              isCredit: record.isCredit,
              type: record.type,
              eventEpochMs: record.eventEpochMs,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <TransactionItem>[];
    }
  }

  Future<void> _appendWalletOperation(_WalletOperationRecord record) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<_WalletOperationRecord> current = (await _loadWalletOpsRaw()).toList(growable: true);
    current.insert(0, record);
    final String encoded = jsonEncode(
      current.map((item) => item.toJson()).toList(growable: false),
    );
    await prefs.setString(_walletOpsKey, encoded);
  }

  Future<List<_WalletOperationRecord>> _loadWalletOpsRaw() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_walletOpsKey);
    if (raw == null || raw.isEmpty) return <_WalletOperationRecord>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return <_WalletOperationRecord>[];
      return decoded
          .whereType<Map>()
          .map(
            (e) => _WalletOperationRecord.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(growable: true);
    } catch (_) {
      return <_WalletOperationRecord>[];
    }
  }

  String _shortTripId(String id) {
    if (id.length <= 4) return id;
    return id.substring(id.length - 4);
  }

  String _formatRelativeTime(int epochMs) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime date = DateTime(dt.year, dt.month, dt.day);
    final int dayDiff = today.difference(date).inDays;
    final String dayLabel = dayDiff == 0
        ? 'Today'
        : dayDiff == 1
        ? 'Yesterday'
        : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayLabel, $hour12:$minute $amPm';
  }
}

class _WalletOperationRecord {
  const _WalletOperationRecord({
    required this.id,
    required this.amount,
    required this.isCredit,
    required this.type,
    required this.eventEpochMs,
  });

  final String id;
  final double amount;
  final bool isCredit;
  final WalletTransactionType type;
  final int eventEpochMs;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'isCredit': isCredit,
      'type': type.name,
      'eventEpochMs': eventEpochMs,
    };
  }

  factory _WalletOperationRecord.fromJson(Map<String, dynamic> json) {
    final String rawType = (json['type'] as String?) ?? WalletTransactionType.recharge.name;
    final WalletTransactionType type = WalletTransactionType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => WalletTransactionType.recharge,
    );
    return _WalletOperationRecord(
      id: (json['id'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isCredit: (json['isCredit'] as bool?) ?? true,
      type: type,
      eventEpochMs: (json['eventEpochMs'] as num?)?.toInt() ?? 0,
    );
  }
}
