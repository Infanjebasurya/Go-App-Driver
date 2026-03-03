import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/incentives/domain/usecases/get_incentives_config_usecase.dart';

import 'incentives_state.dart';

class IncentivesCubit extends Cubit<IncentivesState> {
  IncentivesCubit({required GetIncentivesConfigUseCase getIncentivesConfig})
    : _getIncentivesConfig = getIncentivesConfig,
      super(const IncentivesState()) {
    load();
  }

  final GetIncentivesConfigUseCase _getIncentivesConfig;

  Future<void> load() async {
    final config = await _getIncentivesConfig();
    emit(
      state.copyWith(
        selectedTab: config.defaultTab,
        selectedDayIndex: config.defaultDayIndex,
      ),
    );
  }

  void selectTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void selectDay(int dayIndex) {
    emit(state.copyWith(selectedDayIndex: dayIndex));
  }
}
