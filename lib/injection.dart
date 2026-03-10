import 'package:get_it/get_it.dart';
import 'package:goapp/core/network/native_network_service.dart';
import 'package:goapp/core/network/network_info.dart';
import 'package:goapp/core/service/network_settings_service.dart';
import 'package:goapp/core/service/network_settings_service_impl.dart';
import 'package:goapp/core/network/network_status_cubit.dart';
import 'package:goapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:goapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:goapp/features/home/data/datasources/captain_remote_data_source.dart';
import 'package:goapp/features/home/data/repositories/captain_repository_impl.dart';
import 'package:goapp/features/home/domain/repositories/captain_repository.dart';
import 'package:goapp/features/home/domain/usecases/get_captain_profile.dart';
import 'package:goapp/features/home/presentation/cubit/home_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // B-08 FIX: Auth dependencies registered here so a single AuthRepositoryImpl
  // instance is shared across AuthBloc, OtpCubit, and any future consumers.
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<RequestOtpUseCase>(
      () => RequestOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<ResendOtpUseCase>(
      () => ResendOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton<CaptainRemoteDataSource>(
      () => CaptainRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<CaptainRepository>(
      () => CaptainRepositoryImpl(sl<CaptainRemoteDataSource>()),
    )
    ..registerLazySingleton<GetCaptainProfile>(
      () => GetCaptainProfile(sl<CaptainRepository>()),
    )
    ..registerFactory<HomeCubit>(() => HomeCubit(sl<GetCaptainProfile>()))
    ..registerLazySingleton<NativeNetworkService>(() => NativeNetworkService())
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<NativeNetworkService>()),
    )
    ..registerLazySingleton<NetworkSettingsService>(
      () => NetworkSettingsServiceImpl(),
    )
    ..registerFactory<NetworkStatusCubit>(
      () => NetworkStatusCubit(sl<NetworkInfo>()),
    );
}
