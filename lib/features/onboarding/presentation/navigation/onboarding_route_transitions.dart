import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goapp/features/auth/presentation/pages/r_login_page.dart';

enum OnboardingTransitionStyle { slide, bikeToCab, cabToParcel }

Route<T> onboardingSlideRoute<T>(Widget page) {
  return onboardingRoute(page, style: OnboardingTransitionStyle.slide);
}

Route<T> onboardingBikeToCabRoute<T>(Widget page) {
  return onboardingRoute(page, style: OnboardingTransitionStyle.bikeToCab);
}

Route<T> onboardingCabToParcelRoute<T>(Widget page) {
  return onboardingRoute(page, style: OnboardingTransitionStyle.cabToParcel);
}

Route<T> onboardingRoute<T>(
  Widget page, {
  OnboardingTransitionStyle style = OnboardingTransitionStyle.slide,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (style) {
        case OnboardingTransitionStyle.slide:
          return _lightSlide(
            animation: animation,
            child: child,
            begin: const Offset(0.10, 0),
          );
        case OnboardingTransitionStyle.bikeToCab:
          return _lightSlide(
            animation: animation,
            child: child,
            begin: const Offset(0.14, 0.02),
          );
        case OnboardingTransitionStyle.cabToParcel:
          return _lightSlide(
            animation: animation,
            child: child,
            begin: const Offset(0, 0.10),
          );
      }
    },
  );
}

Widget _lightSlide({
  required Animation<double> animation,
  required Widget child,
  required Offset begin,
}) {
  const curve = Curves.easeOutCubic;
  final offsetTween = Tween<Offset>(
    begin: begin,
    end: Offset.zero,
  ).chain(CurveTween(curve: curve));
  final fadeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: curve));
  final scaleTween = Tween<double>(
    begin: 0.985,
    end: 1.0,
  ).chain(CurveTween(curve: curve));

  return FadeTransition(
    opacity: animation.drive(fadeTween),
    child: SlideTransition(
      position: animation.drive(offsetTween),
      child: ScaleTransition(scale: animation.drive(scaleTween), child: child),
    ),
  );
}

Route<void> loginFormRoute() {
  return MaterialPageRoute(builder: (_) => const LoginFormPage());
}

class LoginFormPage extends StatelessWidget {
  const LoginFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthBloc? existing;
    try {
      existing = context.read<AuthBloc>();
    } catch (_) {
      existing = null;
    }

    if (existing != null) {
      return BlocProvider<AuthBloc>.value(
        value: existing,
        child: const Scaffold(body: RLoginPage()),
      );
    }

    final repository = AuthRepositoryImpl(AuthRemoteDataSourceImpl());

    return BlocProvider<AuthBloc>(
      create: (_) =>
          AuthBloc(LoginUseCase(repository), RequestOtpUseCase(repository)),
      child: const Scaffold(body: RLoginPage()),
    );
  }
}
