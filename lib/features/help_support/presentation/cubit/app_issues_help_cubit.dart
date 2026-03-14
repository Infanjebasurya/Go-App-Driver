import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/usecases/get_app_issues_help_links_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/app_issues_help_state.dart';

class AppIssuesHelpCubit extends Cubit<AppIssuesHelpState> {
  AppIssuesHelpCubit({required GetAppIssuesHelpLinksUseCase getLinks})
    : _getLinks = getLinks,
      super(AppIssuesHelpState.initial()) {
    unawaited(init());
  }

  final GetAppIssuesHelpLinksUseCase _getLinks;

  Future<void> init() async {
    final links = await _getLinks();
    emit(state.copyWith(links: links));
  }
}
