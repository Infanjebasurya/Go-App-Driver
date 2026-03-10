import 'package:equatable/equatable.dart';

class ReconnectOverlayState extends Equatable {
  const ReconnectOverlayState({required this.visible});

  final bool visible;

  @override
  List<Object?> get props => [visible];
}
