import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/pages/available_orders_page.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _lastNavigationToken = 0;

  @override
  void initState() {
    super.initState();
    unawaited(
      RegistrationProgressStore.setStep(RegistrationStep.home),
    );
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
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: AppDrawer(
            onReopenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: state.isOnline ? const OnlineContent() : const OfflineContent(),
        );
      },
    );
  }
}
