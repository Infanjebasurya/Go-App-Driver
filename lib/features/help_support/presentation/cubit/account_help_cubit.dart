import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/usecases/get_account_help_links_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/account_help_state.dart';

class AccountHelpCubit extends Cubit<AccountHelpState> {
  AccountHelpCubit({required GetAccountHelpLinksUseCase getLinks})
    : _getLinks = getLinks,
      super(AccountHelpState.initial()) {
    unawaited(init());
  }

  final GetAccountHelpLinksUseCase _getLinks;

  Future<void> init() async {
    final links = await _getLinks();
    emit(state.copyWith(links: links));
  }
}
