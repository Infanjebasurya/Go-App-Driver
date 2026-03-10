import 'package:equatable/equatable.dart';

enum InternetStatus { initial, connected, disconnected }

class InternetState extends Equatable {
  const InternetState({required this.status});

  final InternetStatus status;

  bool get isConnected => status == InternetStatus.connected;

  factory InternetState.initial() =>
      const InternetState(status: InternetStatus.initial);

  factory InternetState.connected() =>
      const InternetState(status: InternetStatus.connected);

  factory InternetState.disconnected() =>
      const InternetState(status: InternetStatus.disconnected);

  @override
  List<Object?> get props => [status];
}
