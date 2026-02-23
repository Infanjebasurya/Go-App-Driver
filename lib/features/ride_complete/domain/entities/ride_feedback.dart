import 'package:equatable/equatable.dart';

class RideFeedback extends Equatable {
  const RideFeedback({
    required this.rating,
    required this.tags,
    required this.comment,
  });

  final int rating;
  final Set<String> tags;
  final String comment;

  @override
  List<Object> get props => <Object>[rating, tags, comment];
}
