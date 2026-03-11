import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DetectedFace extends Equatable {
  const DetectedFace({
    required this.boundingBox,
    required this.headEulerAngleX,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
  });

  final Rect boundingBox;
  final double? headEulerAngleX;
  final double? headEulerAngleY;
  final double? headEulerAngleZ;

  @override
  List<Object?> get props => <Object?>[
        boundingBox,
        headEulerAngleX,
        headEulerAngleY,
        headEulerAngleZ,
      ];
}

