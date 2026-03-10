import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/core/network/global_network_dialog_overlay.dart';
import 'package:goapp/core/network/network_status_cubit.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
import 'package:goapp/core/di/injection.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/theme/app_theme.dart';
import 'core/app/app_entry_gate.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await LocalNotificationService.initialize();
  await TripBackgroundService.initialize();
  await TextFieldStore.init();
  await DocumentProgressStore.init();
  await UserCacheStore.init();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
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
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<NetworkStatusCubit>(
          create: (_) => sl<NetworkStatusCubit>(),
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
            ],
          );
        },
        home: const AppEntryGate(),
      ),
    );
  }
}
