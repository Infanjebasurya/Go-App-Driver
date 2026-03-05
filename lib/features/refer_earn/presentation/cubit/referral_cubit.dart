import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/refer_earn/data/datasources/referral_mock_api.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_state.dart';

class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit({ReferralMockApi? mockApi})
    : _mockApi = mockApi ?? const ReferralMockApi(),
      super(const ReferralInitial()) {
    loadData();
  }

  final ReferralMockApi _mockApi;

  Future<void> loadData() async {
    emit(const ReferralLoading());
    final ReferralPayload payload = await _mockApi.fetchReferralData();
    emit(
      ReferralLoaded(
        referralCode: payload.referralCode,
        totalEarnings: payload.totalEarnings,
        campaigns: payload.campaigns,
        allReferrals: payload.referrals,
      ),
    );
  }

  Future<void> copyCode() async {
    if (state is! ReferralLoaded) return;
    final s = state as ReferralLoaded;
    emit(s.copyWith(codeCopied: true));
    await Future<void>.delayed(const Duration(seconds: 2));
    if (state is ReferralLoaded) {
      emit((state as ReferralLoaded).copyWith(codeCopied: false));
    }
  }
}
