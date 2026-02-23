import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/ride_completed_state.dart';

class RideCompletedCubit extends Cubit<RideCompletedState> {
  RideCompletedCubit(GetRideCompletionSummary getRideCompletionSummary)
    : super(RideCompletedState(summary: getRideCompletionSummary()));

  void toggleQrExpanded() {
    emit(state.copyWith(isQrExpanded: !state.isQrExpanded));
  }
}
