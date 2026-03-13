import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_links_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_state.dart';

class EarningsHelpCubit extends Cubit<EarningsHelpState> {
  EarningsHelpCubit({required GetEarningsHelpLinksUseCase getLinks})
    : _getLinks = getLinks,
      super(EarningsHelpState.initial());

  final GetEarningsHelpLinksUseCase _getLinks;

  Future<void> init() async {
    final links = await _getLinks();
    emit(state.copyWith(links: links));
  }
}
