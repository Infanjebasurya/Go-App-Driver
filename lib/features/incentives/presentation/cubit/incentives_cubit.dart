import 'package:flutter_bloc/flutter_bloc.dart';

import 'incentives_state.dart';

class IncentivesCubit extends Cubit<IncentivesState> {
  IncentivesCubit() : super(const IncentivesState());

  void selectTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void selectDay(int dayIndex) {
    emit(state.copyWith(selectedDayIndex: dayIndex));
  }
}
