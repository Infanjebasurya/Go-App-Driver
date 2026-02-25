import 'package:flutter_bloc/flutter_bloc.dart';

class SafetyPreferencesState {
  const SafetyPreferencesState({
    required this.autoShare,
    required this.shareAtNight,
  });

  final bool autoShare;
  final bool shareAtNight;

  SafetyPreferencesState copyWith({bool? autoShare, bool? shareAtNight}) {
    return SafetyPreferencesState(
      autoShare: autoShare ?? this.autoShare,
      shareAtNight: shareAtNight ?? this.shareAtNight,
    );
  }
}

class SafetyPreferencesCubit extends Cubit<SafetyPreferencesState> {
  SafetyPreferencesCubit()
    : super(const SafetyPreferencesState(autoShare: true, shareAtNight: false));

  void setAutoShare(bool enabled) {
    emit(state.copyWith(autoShare: enabled));
  }

  void setShareAtNight(bool enabled) {
    emit(state.copyWith(shareAtNight: enabled));
  }
}
