import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/wallet_display.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/pages/withdrawal_success_page.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  String? _inlineError;
  late final TextEditingController _amountController;
  final List<_BankItem> _banks = const <_BankItem>[
    _BankItem(name: 'SBI Bank', maskedNumber: '**** **** 8829'),
    _BankItem(name: 'HDFC Bank', maskedNumber: '**** **** 8829'),
  ];

  @override
  void initState() {
    super.initState();
    String initial = '0';
    try {
      initial = context.read<EarningsCubit>().state.rechargeAmount;
    } catch (_) {}
    _amountController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EarningsCubit, EarningsState>(
      builder: (context, state) {
        if (_amountController.text != state.rechargeAmount) {
          _amountController.value = TextEditingValue(
            text: state.rechargeAmount,
            selection: TextSelection.collapsed(
              offset: state.rechargeAmount.length,
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: const Text('Withdraw'),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 26,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white70,
                          borderRadius: BorderRadius.circular(16),
                          // border: Border.all(
                          //   color: AppColors.hexFF3B82F6,
                          //   width: 1.4,
                          // ),
                        ),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 2.2,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral666,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹ ${walletDisplayBalance(state.snapshot.walletBalance).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                            if (_inlineError != null) ...<Widget>[
                              const SizedBox(height: 10),
                              Text(
                                _inlineError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Withdrawal Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral666,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white30,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: AppColors.hex11000000,
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            const Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral888,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (value) {
                                  context
                                      .read<EarningsCubit>()
                                      .setRechargeAmount(value);
                                  if (_inlineError != null) {
                                    setState(() => _inlineError = null);
                                  }
                                },
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const <Widget>[
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.neutralAAA,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Standard processing time: 2-4 business hours',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.neutralAAA,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Saved Cards',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral666,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: AppColors.hex11000000,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            for (int i = 0; i < _banks.length; i++)
                              _SavedBankTile(
                                bank: _banks[i],
                                selected: state.selectedBank == _banks[i].name,
                                onTap: () => context
                                    .read<EarningsCubit>()
                                    .selectBank(_banks[i].name),
                                showDivider: i != _banks.length - 1,
                              ),
                            const Divider(
                              height: 1,
                              color: AppColors.hexFFE8E8E8,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: const <Widget>[
                                  Icon(
                                    Icons.add_circle,
                                    color: AppColors.emerald,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Add New Bank',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.emerald,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // const Text(
                      //   'Pay Online',
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w600,
                      //     color: AppColors.neutral666,
                      //   ),
                      // ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final String enteredAmount = _amountController.text;
                        context.read<EarningsCubit>().setRechargeAmount(
                          enteredAmount,
                        );
                        final bool ok = await context
                            .read<EarningsCubit>()
                            .withdrawWallet(rawAmount: enteredAmount);
                        if (!context.mounted) return;
                        if (!ok) {
                          setState(() {
                            _inlineError = _buildWithdrawValidationMessage(
                              state: state,
                              rawAmount: enteredAmount,
                            );
                          });
                          return;
                        }
                        setState(() => _inlineError = null);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => WithdrawalSuccessPage(
                              amount: enteredAmount,
                              bankName: state.selectedBank,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            'Proceed to Withdraw',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildWithdrawValidationMessage({
    required EarningsState state,
    required String rawAmount,
  }) {
    final String cleaned = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final double? amount = double.tryParse(cleaned);
    if (amount == null || amount <= 0) {
      return 'Enter a valid withdrawal amount';
    }

    final double maxWithdrawable = double.parse(
      state.snapshot.walletBalance.toStringAsFixed(2),
    );
    if (maxWithdrawable <= 0) {
      return 'No withdrawable wallet balance available';
    }

    if ((amount - maxWithdrawable) > 0.0001) {
      return 'You can withdraw up to Rs ${maxWithdrawable.toStringAsFixed(2)} only';
    }

    return 'Unable to process withdrawal';
  }
}

class _BankItem {
  const _BankItem({required this.name, required this.maskedNumber});

  final String name;
  final String maskedNumber;
}

class _SavedBankTile extends StatelessWidget {
  const _SavedBankTile({
    required this.bank,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final _BankItem bank;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.earningsAccentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    size: 18,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bank.maskedNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralAAA,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.emerald
                          : AppColors.neutralCCC,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.emerald,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            if (showDivider)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Divider(height: 1, color: AppColors.hexFFF5F5F5),
              ),
          ],
        ),
      ),
    );
  }
}
