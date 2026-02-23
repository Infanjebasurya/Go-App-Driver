import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class RechargeWalletPage extends StatefulWidget {
  const RechargeWalletPage({super.key});

  @override
  State<RechargeWalletPage> createState() => _RechargeWalletPageState();
}

class _RechargeWalletPageState extends State<RechargeWalletPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '2000',
  );
  String _selectedPaymentMethod = 'UPI Payments';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addAmount(int amount) {
    final currentAmount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _amountController.text = (currentAmount + amount).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recharge Wallet',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'ENTER AMOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAddChip(500),
                      _buildQuickAddChip(1000, isSelected: true),
                      _buildQuickAddChip(2000),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodTile(
                    icon: Icons.qr_code_scanner,
                    title: 'UPI Payments',
                    subtitle: 'Google Pay, PhonePe, etc.',
                    value: 'UPI Payments',
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodTile(
                    icon: Icons.account_balance,
                    title: 'Net Banking',
                    subtitle: 'All major banks supported',
                    value: 'Net Banking',
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodTile(
                    icon: Icons.credit_card,
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                    value: 'Credit / Debit Card',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddChip(int amount, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _addAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.earningsAccentSoft : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.emerald : Colors.grey[200]!,
          ),
        ),
        child: Text(
          '+ ?$amount',
          style: TextStyle(
            color: isSelected ? AppColors.emerald : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.earningsAccentSoft : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.emerald : AppColors.emerald,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.emerald : Colors.grey[300]!,
                  width: isSelected ? 6 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


