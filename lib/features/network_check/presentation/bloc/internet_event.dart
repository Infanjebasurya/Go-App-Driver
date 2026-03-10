import 'package:equatable/equatable.dart';

abstract class InternetEvent extends Equatable {
  const InternetEvent();

  @override
  List<Object?> get props => [];
}

class InternetStarted extends InternetEvent {
  const InternetStarted();
}

class InternetConnectionChanged extends InternetEvent {
  const InternetConnectionChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

class InternetCheckRequested extends InternetEvent {
  const InternetCheckRequested();
}
