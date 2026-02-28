import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/storage/location_permission_prompt_store.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/features/home/presentation/pages/available_orders_page.dart';
import 'package:goapp/features/home/presentation/widgets/home_no_device_back.dart';

import '../cubit/driver_status_cubit.dart';
import '../cubit/driver_status_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/offline_content.dart';
import '../widgets/online_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _lastNavigationToken = 0;
  int _lastShownBlockEventId = -1;
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  bool _isPermissionFlowRunning = false;
  bool _isPermissionDialogVisible = false;
  Timer? _locationSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // B-13 FIX: Only clear the trip store when no trip is active.
    // Calling clear() unconditionally wiped the persisted stage on every
    // home-screen mount, breaking crash-recovery if the home screen was
    // pushed while a trip was in progress.
    _clearTripStoreIfSafe();
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
    _locationSyncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_syncLocationUiState());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runOfflinePermissionFlow());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        context.read<DriverCubit>().state.isOffline) {
      unawaited(_runOfflinePermissionFlow());
    }
  }

  /// B-13 FIX: Only wipes the trip resume store when no active trip exists.
  void _clearTripStoreIfSafe() {
    unawaited(
      HomeTripResumeStore.loadStage().then((stage) {
        if (stage == HomeTripResumeStage.none) {
          unawaited(HomeTripResumeStore.clear());
          // TripSessionStore: remove active session only when back at home
          // with no trip in progress.
          unawaited(TripSessionStore.endSession());
        }
      }),
    );
  }

  @override
  void dispose() {
    _locationSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverCubit, DriverState>(
      listener: (context, state) {
        if (state.navigateToOrdersToken > _lastNavigationToken) {
          _lastNavigationToken = state.navigateToOrdersToken;
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => AvailableOrdersPage()),
          );
        }

        if (state.offlineBlockIssue != null &&
            state.offlineBlockEventId != _lastShownBlockEventId) {
          _lastShownBlockEventId = state.offlineBlockEventId;
          if (_isHomeRouteActive()) {
            _showLocationBlockedSnack(context, state.offlineBlockIssue!);
          }
          if (state.isOffline && _isHomeRouteActive()) {
            unawaited(_runOfflinePermissionFlow());
          }
        }
      },
      builder: (context, state) {
        return HomeNoDeviceBack(
          child: Scaffold(
            backgroundColor: Colors.white,
            drawer: const AppDrawer(),
            body: state.isOnline
                ? const OnlineContent()
                : const OfflineContent(),
          ),
        );
      },
    );
  }

  Future<void> _runOfflinePermissionFlow() async {
    if (!mounted || _isPermissionFlowRunning) return;
    if (!_isHomeRouteActive()) return;
    if (context.read<DriverCubit>().state.isOnline) return;

    _isPermissionFlowRunning = true;
    try {
      final bool shouldPromptSettings =
          await LocationPermissionPromptStore.consumePendingSettingsPrompt();
      if (shouldPromptSettings && mounted) {
        await _showSettingsDialog(
          title: 'Location Access Required',
          message:
              'Location access was denied multiple times. Please open Settings and enable Location permission to continue receiving ride requests.',
        );
      }

      final initial = await _locationGuard.ensureReady(requestPermission: false);
      if (!mounted) return;
      if (initial.isReady) {
        await LocationPermissionPromptStore.clearDeniedHistory();
        if (!mounted) return;
        context.read<DriverCubit>().clearOfflineLocationBlock();
        ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
        return;
      }

      if (initial.issue == LocationIssue.serviceDisabled) {
        await _showGpsDialog();
        return;
      }

      final retried = await _locationGuard.ensureReady(requestPermission: true);
      if (!mounted) return;
      if (retried.isReady) {
        await LocationPermissionPromptStore.clearDeniedHistory();
        if (!mounted) return;
        context.read<DriverCubit>().clearOfflineLocationBlock();
        ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
        return;
      }

      await LocationPermissionPromptStore.noteDeniedAttempt();

      if (retried.issue == LocationIssue.permissionDenied ||
          retried.issue == LocationIssue.permissionDeniedForever) {
        await _showSettingsDialog(
          title: retried.issue == LocationIssue.permissionDeniedForever
              ? 'Location Permission Blocked'
              : 'Location Permission Needed',
          message:
              retried.issue == LocationIssue.permissionDeniedForever
              ? 'Location permission is permanently denied for this app. Please open Settings and allow Location access.'
              : 'Location permission is required to go online and receive rides. Please open Settings and allow Location access.',
        );
      }
    } finally {
      _isPermissionFlowRunning = false;
    }
  }

  Future<void> _syncLocationUiState() async {
    if (!mounted) return;
    if (!_isHomeRouteActive() && !_isPermissionDialogVisible) return;
    if (context.read<DriverCubit>().state.isOnline) return;

    final result = await _locationGuard.ensureReady(requestPermission: false);
    if (!mounted || !result.isReady) return;

    context.read<DriverCubit>().clearOfflineLocationBlock();
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    if (_isPermissionDialogVisible) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
  }

  bool _isHomeRouteActive() {
    final route = ModalRoute.of(context);
    return route?.isCurrent ?? false;
  }

  Future<void> _showGpsDialog() async {
    if (!mounted) return;
    _isPermissionDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable GPS'),
          content: const Text(
            'Location services are currently turned off. Please enable GPS to continue receiving ride requests.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _locationGuard.openLocationSettings();
              },
              child: const Text('Open location settings'),
            ),
          ],
        );
      },
    );
    _isPermissionDialogVisible = false;
  }

  Future<void> _showSettingsDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    _isPermissionDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _locationGuard.openAppSettings();
              },
              child: const Text('Open app settings'),
            ),
          ],
        );
      },
    );
    _isPermissionDialogVisible = false;
  }

  void _showLocationBlockedSnack(BuildContext context, LocationIssue issue) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(_locationBlockedMessage(issue)),
        action: SnackBarAction(
          label: issue == LocationIssue.serviceDisabled
              ? 'Enable GPS'
              : 'Settings',
          onPressed: () {
            final guard = const LocationPermissionGuard();
            if (issue == LocationIssue.serviceDisabled) {
              guard.openLocationSettings();
            } else {
              guard.openAppSettings();
            }
          },
        ),
      ),
    );
  }

  String _locationBlockedMessage(LocationIssue issue) {
    switch (issue) {
      case LocationIssue.serviceDisabled:
        return 'Turn on GPS to go online and receive ride requests.';
      case LocationIssue.permissionDenied:
        return 'Allow Location permission to go online and receive ride requests.';
      case LocationIssue.permissionDeniedForever:
        return 'Location permission is permanently denied. Enable it from app settings.';
    }
  }
}
