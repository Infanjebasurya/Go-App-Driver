import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/injection.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/request_otp_usecase.dart';
import 'features/auth/presentation/theme/app_theme.dart';
import 'app_entry_gate.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize();
  await TripBackgroundService.initialize();
  await TextFieldStore.init();
  await UserCacheStore.init();
  await initializeDependencies();

  runApp(
    DevicePreview(
      enabled: kDebugMode && Env.enableDevicePreview,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // B-08 FIX: AuthBloc now uses the shared repository from get_it.
    return BlocProvider(
      create: (_) => AuthBloc(sl<LoginUseCase>(), sl<RequestOtpUseCase>()),
      child: MaterialApp(
        navigatorKey: _rootNavigatorKey,
        title: 'GoApp Captain',
        theme: AppTheme.lightTheme(isTest: false),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          return child;
        },
        home: const AppEntryGate(),
      ),
    );
  }
}
