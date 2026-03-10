import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/features/network_check/presentation/bloc/internet_bloc.dart';
import 'package:goapp/features/network_check/presentation/bloc/reconnect_overlay_cubit.dart';
import 'package:goapp/features/network_check/presentation/widgets/global_network_dialog_overlay.dart';
import 'package:goapp/features/network_check/presentation/widgets/network_reconnect_loader_overlay.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
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
  await DocumentProgressStore.init();
  await UserCacheStore.init();
  await DocumentProgressStore.init();
  await initializeDependencies();

  runApp(
    DevicePreview(
      enabled: !kDebugMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // B-08 FIX: AuthBloc now uses the shared repository from get_it.
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(sl<LoginUseCase>(), sl<RequestOtpUseCase>()),
        ),
        BlocProvider<InternetBloc>(create: (_) => sl<InternetBloc>()),
        BlocProvider<ReconnectOverlayCubit>(
          create: (_) => sl<ReconnectOverlayCubit>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _rootNavigatorKey,
        title: 'GoApp Captain',
        theme: AppTheme.lightTheme(isTest: false),
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: (context, child) {
          final Widget previewChild = DevicePreview.appBuilder(context, child);
          return Stack(
            children: <Widget>[
              previewChild,
              const GlobalNetworkDialogOverlay(),
              const NetworkReconnectLoaderOverlay(),
            ],
          );
        },
        home: const AppEntryGate(),
      ),
    );
  }
}
