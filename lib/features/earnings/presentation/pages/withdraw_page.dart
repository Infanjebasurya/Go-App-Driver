import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
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
            selection: TextSelection.collapsed(offset: state.rechargeAmount.length),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Withdraw',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceF5,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral666,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Rs ${state.snapshot.walletBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
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
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Withdrawal Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral666,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          const Text(
                            'Rs',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral888,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (value) {
                                context.read<EarningsCubit>().setRechargeAmount(
                                  value,
                                );
                                if (_inlineError != null) {
                                  setState(() => _inlineError = null);
                                }
                              },
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.strokeLight),
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
                        context.read<EarningsCubit>().setRechargeAmount(enteredAmount);
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
                      child: const Text(
                        'Proceed to Withdraw',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
    final String cleaned = rawAmount
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .trim();
    final double? amount = double.tryParse(cleaned);
    if (amount == null || amount <= 0) {
      return 'Enter a valid withdrawal amount';
    }

    const double minimumRetainedBalance = 300;
    final double maxWithdrawable =
        double.parse((state.snapshot.walletBalance - minimumRetainedBalance).toStringAsFixed(2));
    if (maxWithdrawable <= 0) {
      return 'Minimum balance of Rs 300 must be kept in wallet';
    }

    if ((amount - maxWithdrawable) > 0.0001) {
      return 'You can withdraw up to Rs ${maxWithdrawable.toStringAsFixed(2)} only';
    }

    return 'Unable to process withdrawal';
  }
}
