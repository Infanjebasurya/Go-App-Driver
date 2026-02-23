import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/cubit/auth_onboarding_cubit.dart';
import '../navigation/onboarding_route_transitions.dart';

class OnboardingFlowScope extends StatelessWidget {
  const OnboardingFlowScope({
    super.key,
    required this.cubit,
    required this.child,
  });

  final AuthOnboardingCubit cubit;
  final Widget child;

  static Widget wrapNext(BuildContext context, Widget child) {
    try {
      return OnboardingFlowScope(
        cubit: context.read<AuthOnboardingCubit>(),
        child: child,
      );
    } catch (_) {
      return child;
    }
  }

  static Future<void> finishToLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthOnboardingCubit>().markSeen();
    } catch (_) {}
    navigator.pushAndRemoveUntil(loginFormRoute(), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthOnboardingCubit>.value(value: cubit, child: child);
  }
}
