import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ProcessedJpegImage extends Equatable {
  const ProcessedJpegImage({
    required this.bytes,
    required this.widthPx,
    required this.heightPx,
  });

  final Uint8List bytes;
  final int widthPx;
  final int heightPx;

  @override
  List<Object?> get props => <Object?>[bytes, widthPx, heightPx];
}

