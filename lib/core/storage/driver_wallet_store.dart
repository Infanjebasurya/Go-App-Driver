import 'shared_preferences_store.dart';

class DriverWalletStore {
  DriverWalletStore._();

  static const String _walletBalanceKey = 'driver_wallet_balance_v1';
  static const double minAllowedNegativeBalance = -50.0;

  static Future<double> loadBalance() async {
    final prefs = SharedPreferencesStore.global;
    return prefs.getDouble(_walletBalanceKey) ?? 0.0;
  }

  static Future<void> saveBalance(double amount) async {
    final prefs = SharedPreferencesStore.global;
    final double normalized = amount < minAllowedNegativeBalance
        ? minAllowedNegativeBalance
        : amount;
    await prefs.setDouble(_walletBalanceKey, normalized);
  }

  static Future<double> addAmount(double amount) async {
    if (amount <= 0) return loadBalance();
    final double current = await loadBalance();
    final double next = current + amount;
    await saveBalance(next);
    return next;
  }

  static Future<double?> subtractAmount(double amount) async {
    if (amount <= 0) return loadBalance();
    final double current = await loadBalance();
    final double next = current - amount;
    if (next < minAllowedNegativeBalance) return null;
    await saveBalance(next);
    return next;
  }
}
