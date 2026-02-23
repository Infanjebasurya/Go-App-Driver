import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, String>> requestOtp({required String phone});

  Future<Either<Failure, User>> login({
    required String phone,
    required String otp,
    required String otpId,
  });

  Future<Either<Failure, String>> resendOtp({required String phone});
}
