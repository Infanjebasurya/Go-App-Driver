import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/home_cubit.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';
import 'package:goapp/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';

class GoApp extends StatelessWidget {
  const GoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoApp Captain',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
      ),
      home: BlocProvider<HomeCubit>(
        create: (_) => sl<HomeCubit>()..loadCaptainProfile(),
        child: BlocProvider<DriverCubit>(
          create: (_) => DriverCubit(),
          child: const HomeScreen(),
        ),
      ),
    );
  }
}


