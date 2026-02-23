import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';

abstract class HelpState extends Equatable {
  const HelpState();

  @override
  List<Object?> get props => [];
}

class HelpHomeState extends HelpState {
  final String searchQuery;

  const HelpHomeState({this.searchQuery = ''});

  @override
  List<Object?> get props => [searchQuery];
}

class HelpTicketsState extends HelpState {
  final List<SupportTicket> tickets;

  const HelpTicketsState({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

class HelpExploreState extends HelpState {
  final String searchQuery;

  const HelpExploreState({this.searchQuery = ''});

  @override
  List<Object?> get props => [searchQuery];
}

class HelpCubit extends Cubit<HelpState> {
  static final List<SupportTicket> _mockTickets = [
    SupportTicket(
      id: 'GP-BB421',
      title: 'Fare adjustment for ride on March 14',
      description: 'Rs 240.00 adjustment has been credited.',
      status: TicketStatus.resolved,
      createdAt: DateTime(2024, 3, 14),
    ),
    SupportTicket(
      id: 'GP-BB390',
      title: 'Updated verification documents',
      description: 'Vehicle insurance update complete.',
      status: TicketStatus.closed,
      createdAt: DateTime(2024, 3, 10),
    ),
  ];

  HelpCubit() : super(const HelpHomeState());

  List<IssueCategory> get filteredIssueCategories {
    final query = state is HelpExploreState
        ? (state as HelpExploreState).searchQuery
        : '';
    if (query.trim().isEmpty) return kIssueCategories;
    final normalized = query.trim().toLowerCase();
    return kIssueCategories
        .where((item) => item.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  void goToTickets() => emit(HelpTicketsState(tickets: _mockTickets));

  void goToExplore() => emit(const HelpExploreState());

  void goHome() => emit(const HelpHomeState());

  void updateSearch(String query) {
    if (state is HelpHomeState) {
      emit(HelpHomeState(searchQuery: query));
    } else if (state is HelpExploreState) {
      emit(HelpExploreState(searchQuery: query));
    }
  }
}
