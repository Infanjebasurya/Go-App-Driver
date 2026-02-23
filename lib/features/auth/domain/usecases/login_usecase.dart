import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';
import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase([this._repository]);

  final AuthRepository? _repository;

  Future<Either<Failure, User>> call({
    required String phone,
    required String otp,
    required String otpId,
  }) {
    final repository = _repository;
    if (repository == null) {
      return Future<Either<Failure, User>>.value(
        Right<Failure, User>(
          User(id: 'captain-001', phone: phone),
        ),
      );
    }
    return repository.login(phone: phone, otp: otp, otpId: otpId);
  }
}
