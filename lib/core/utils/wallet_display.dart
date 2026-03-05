double walletDisplayBalance(double actualBalance, {double reservedAmount = 300.0}) {
  final double visible = actualBalance - reservedAmount;
  if (visible <= 0) return 0;
  return double.parse(visible.toStringAsFixed(2));
}
