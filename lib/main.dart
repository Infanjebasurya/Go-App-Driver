import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/request_otp_usecase.dart';
import 'features/auth/presentation/theme/app_theme.dart';
import 'app_entry_gate.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: kDebugMode && _devicePreviewEnabled,
      builder: (context) => const MyApp(),
    ),
  );
}

const bool _devicePreviewEnabled = true;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AuthRepositoryImpl(AuthRemoteDataSourceImpl());

    return BlocProvider(
      create: (_) =>
          AuthBloc(LoginUseCase(repository), RequestOtpUseCase(repository)),
      child: MaterialApp(
        title: 'GoApp Captain',
        theme: AppTheme.lightTheme(isTest: false),
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: const AppEntryGate(),
      ),
    );
  }
}
