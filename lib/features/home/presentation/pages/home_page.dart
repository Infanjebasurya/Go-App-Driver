import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/pages/available_orders_page.dart';

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
  int _lastNavigationToken = 0;

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
          backgroundColor: Colors.white,
          drawer: const AppDrawer(),
          body: state.isOnline
              ? const OnlineContent()
              : const OfflineContent(),
        );
      },
    );
  }
}
