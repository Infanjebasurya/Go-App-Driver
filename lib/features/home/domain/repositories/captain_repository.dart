import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';

abstract interface class CaptainRepository {
  Future<Either<Failure, CaptainProfile>> getCaptainProfile();
}
