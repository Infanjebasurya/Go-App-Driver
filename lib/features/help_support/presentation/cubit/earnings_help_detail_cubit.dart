import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_faqs_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_detail_state.dart';

class EarningsHelpDetailCubit extends Cubit<EarningsHelpDetailState> {
  EarningsHelpDetailCubit({
    required GetEarningsHelpFaqsUseCase getFaqs,
    required String linkId,
  }) : _getFaqs = getFaqs,
       _linkId = linkId,
       super(EarningsHelpDetailState.initial());

  final GetEarningsHelpFaqsUseCase _getFaqs;
  final String _linkId;

  Future<void> init() async {
    final items = await _getFaqs(linkId: _linkId);
    emit(state.copyWith(items: items));
  }
}
