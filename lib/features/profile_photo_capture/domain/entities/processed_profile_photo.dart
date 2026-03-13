import 'package:equatable/equatable.dart';

class ProcessedProfilePhoto extends Equatable {
  const ProcessedProfilePhoto({
    required this.path,
    required this.widthPx,
    required this.heightPx,
  });

  final String path;
  final int widthPx;
  final int heightPx;

  @override
  List<Object?> get props => <Object?>[path, widthPx, heightPx];
}
