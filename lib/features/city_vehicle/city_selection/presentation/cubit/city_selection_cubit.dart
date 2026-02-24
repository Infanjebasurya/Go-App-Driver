import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';

class CitySelectionCubit extends Cubit<CitySelectionState> {
  CitySelectionCubit() : super(CitySelectionState.initial());

  void search(String query) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? kAllCities
        : kAllCities
              .where((city) => city.name.toLowerCase().contains(q))
              .toList();
    final stillSelected =
        state.selectedCity != null &&
        filtered.any((city) => city.id == state.selectedCity!.id);

    emit(
      state.copyWith(
        searchQuery: query,
        filteredAllCities: filtered,
        clearSelection: !stillSelected,
      ),
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', filteredAllCities: kAllCities));
  }

  void selectCity(City city) {
    if (state.isSelected(city)) {
      emit(state.copyWith(clearSelection: true));
      return;
    }
    emit(state.copyWith(selectedCity: city));
  }
}
