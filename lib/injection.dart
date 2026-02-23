import 'package:get_it/get_it.dart';
import 'package:goapp/features/home/data/datasources/captain_remote_data_source.dart';
import 'package:goapp/features/home/data/repositories/captain_repository_impl.dart';
import 'package:goapp/features/home/domain/repositories/captain_repository.dart';
import 'package:goapp/features/home/domain/usecases/get_captain_profile.dart';
import 'package:goapp/features/home/presentation/cubit/home_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl
    ..registerLazySingleton<CaptainRemoteDataSource>(
      () => CaptainRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<CaptainRepository>(
      () => CaptainRepositoryImpl(sl<CaptainRemoteDataSource>()),
    )
    ..registerLazySingleton<GetCaptainProfile>(
      () => GetCaptainProfile(sl<CaptainRepository>()),
    )
    ..registerFactory<HomeCubit>(() => HomeCubit(sl<GetCaptainProfile>()));
}
