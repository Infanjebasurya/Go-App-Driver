import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';
import 'package:goapp/features/driver_activation/presentation/widgets/activation_limited_drawer.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';
import 'package:goapp/features/notifications/presentation/pages/notifications_screen.dart';

enum NewDriverActivationPhase { documentReview, walletTopUp }

class NewDriverActivationScreen extends StatefulWidget {
  const NewDriverActivationScreen({
    super.key,
    this.initialPhase = NewDriverActivationPhase.documentReview,
  });

  final NewDriverActivationPhase initialPhase;

  @override
  State<NewDriverActivationScreen> createState() =>
      _NewDriverActivationScreenState();
}

class _NewDriverActivationScreenState extends State<NewDriverActivationScreen> {
  static const int _reviewSeconds = 10;
  static const double _minimumTopUp = 50;

  late NewDriverActivationPhase _phase;
  int _secondsLeft = _reviewSeconds;
  Timer? _reviewTimer;
  bool _isProcessingWallet = false;

  @override
  void initState() {
    super.initState();
    _phase = widget.initialPhase;
    if (_phase == NewDriverActivationPhase.documentReview) {
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.verificationSubmitted,
        ),
      );
      _startReviewCountdown();
    } else {
      unawaited(
        RegistrationProgressStore.setStep(RegistrationStep.verificationSubmitted),
      );
    }
  }

  @override
  void dispose() {
    _reviewTimer?.cancel();
    super.dispose();
  }

  void _startReviewCountdown() {
    _reviewTimer?.cancel();
    _secondsLeft = _reviewSeconds;
    _reviewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _moveToWalletTopUp();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _moveToWalletTopUp() {
    if (!mounted) return;
    unawaited(
      RegistrationProgressStore.setStep(RegistrationStep.verificationSubmitted),
    );
    setState(() {
      _phase = NewDriverActivationPhase.walletTopUp;
      _secondsLeft = 0;
    });
  }

  Future<void> _addMoneyAndContinue() async {
    if (_isProcessingWallet) return;
    setState(() => _isProcessingWallet = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    await DriverWalletStore.addAmount(_minimumTopUp);
    await RegistrationProgressStore.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlocProvider<DriverCubit>(
          create: (_) => DriverCubit(),
          child: const HomeScreen(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: const ActivationLimitedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'GoApp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
          child: _phase == NewDriverActivationPhase.documentReview
              ? _DocumentReviewCard(secondsLeft: _secondsLeft)
              : _WalletActivationCard(
                  minimumTopUp: _minimumTopUp,
                  isLoading: _isProcessingWallet,
                  onContinue: _addMoneyAndContinue,
                ),
        ),
      ),
    );
  }
}

class _DocumentReviewCard extends StatelessWidget {
  const _DocumentReviewCard({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5EBF3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/image/register_success.png',
                height: 190,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Documents Under Review',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2533),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We are verifying your submitted documents.\nEstimated approval check in ${secondsLeft}s.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF637488),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$secondsLeft s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0C9B61),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Checking status...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0C9B61),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletActivationCard extends StatelessWidget {
  const _WalletActivationCard({
    required this.minimumTopUp,
    required this.isLoading,
    required this.onContinue,
  });

  final double minimumTopUp;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5EBF3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 24,
                    color: Color(0xFF0C9B61),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Wallet Activation Required',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2533),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'To activate duty access, add a minimum wallet balance of Rs ${minimumTopUp.toInt()}.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF637488),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6ECF3)),
              ),
              child: const Text(
                'After successful top-up, all drawer menus and offline/online duty controls will be unlocked.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF506176),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C9B61),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Add Rs ${minimumTopUp.toInt()} and Continue',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
