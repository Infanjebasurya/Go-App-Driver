import 'package:shared_preferences/shared_preferences.dart';

class DriverWalletStore {
  DriverWalletStore._();

  static const String _walletBalanceKey = 'driver_wallet_balance_v1';

  static Future<double> loadBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_walletBalanceKey) ?? 0.0;
  }

  static Future<void> saveBalance(double amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double normalized = amount < 0 ? 0.0 : amount;
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
    if (amount > current) return null;
    final double next = current - amount;
    await saveBalance(next);
    return next;
  }
}
