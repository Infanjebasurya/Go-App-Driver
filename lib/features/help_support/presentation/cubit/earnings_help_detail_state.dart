import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';

class EarningsHelpDetailState {
  const EarningsHelpDetailState({required this.items});

  factory EarningsHelpDetailState.initial() =>
      const EarningsHelpDetailState(items: <HelpFaqItem>[]);

  final List<HelpFaqItem> items;

  EarningsHelpDetailState copyWith({List<HelpFaqItem>? items}) {
    return EarningsHelpDetailState(items: items ?? this.items);
  }
}

