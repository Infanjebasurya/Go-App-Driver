import 'package:equatable/equatable.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.profile,
    this.errorMessage = '',
  });

  final HomeStatus status;
  final CaptainProfile? profile;
  final String errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    CaptainProfile? profile,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, profile, errorMessage];
}
