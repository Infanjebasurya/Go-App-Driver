import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/refer_earn/domain/entities/referral.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_cubit.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_state.dart';

class TotalEarningActivity extends Equatable {
  const TotalEarningActivity({
    required this.id,
    required this.name,
    required this.initials,
    required this.dateText,
    required this.status,
    required this.amount,
    required this.label,
  });

  final String id;
  final String name;
  final String initials;
  final String dateText;
  final ReferralStatus status;
  final int amount;
  final String label;

  @override
  List<Object?> get props => [
    id,
    name,
    initials,
    dateText,
    status,
    amount,
    label,
  ];
}

sealed class TotalEarningState extends Equatable {
  const TotalEarningState();

  @override
  List<Object?> get props => [];
}

class TotalEarningLoading extends TotalEarningState {
  const TotalEarningLoading();
}

class TotalEarningFailure extends TotalEarningState {
  const TotalEarningFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class TotalEarningLoaded extends TotalEarningState {
  const TotalEarningLoaded({
    required this.totalEarnings,
    required this.activities,
  });

  final int totalEarnings;
  final List<TotalEarningActivity> activities;

  @override
  List<Object?> get props => [totalEarnings, activities];
}

class TotalEarningCubit extends Cubit<TotalEarningState> {
  TotalEarningCubit({required ReferralCubit referralCubit})
    : _referralCubit = referralCubit,
      super(const TotalEarningLoading()) {
    _sub = _referralCubit.stream.listen(_onReferralState);
    _onReferralState(_referralCubit.state);
  }

  final ReferralCubit _referralCubit;
  late final StreamSubscription<ReferralState> _sub;

  void _onReferralState(ReferralState state) {
    if (state is ReferralLoading || state is ReferralInitial) {
      emit(const TotalEarningLoading());
      return;
    }
    if (state is! ReferralLoaded) {
      emit(const TotalEarningFailure('Failed to load earnings.'));
      return;
    }

    final List<TotalEarningActivity> activities = _mapActivities(
      state.allReferrals,
    );
    emit(
      TotalEarningLoaded(
        totalEarnings: state.totalEarnings,
        activities: activities,
      ),
    );
  }

  List<TotalEarningActivity> _mapActivities(List<ReferralPerson> people) {
    final List<ReferralPerson> sorted = List<ReferralPerson>.from(people)
      ..sort((a, b) {
        int rank(ReferralStatus s) => switch (s) {
          ReferralStatus.completed => 0,
          ReferralStatus.joined => 1,
          ReferralStatus.pending => 2,
        };

        final int byStatus = rank(a.status).compareTo(rank(b.status));
        if (byStatus != 0) return byStatus;

        final String aDate = (a.completedDate ?? a.sentAgo).toUpperCase();
        final String bDate = (b.completedDate ?? b.sentAgo).toUpperCase();
        return bDate.compareTo(aDate);
      });

    return sorted
        .map(
          (p) => TotalEarningActivity(
            id: p.id,
            name: p.name,
            initials: p.initials,
            dateText: p.completedDate ?? p.sentAgo,
            status: p.status,
            amount: p.estimatedReward,
            label: 'REFERRAL',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
