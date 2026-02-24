import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:goapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goapp/features/auth/domain/services/phone_number_service.dart';
import 'package:goapp/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:goapp/features/auth/presentation/cubit/login_form_cubit.dart';
import 'package:goapp/features/auth/presentation/cubit/login_form_state.dart';
import 'package:goapp/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:goapp/features/auth/presentation/pages/otp_page.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';
import 'package:goapp/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:goapp/features/auth/presentation/widgets/snackbar_utils.dart';

class RLoginPage extends StatefulWidget {
  const RLoginPage({super.key});

  @override
  State<RLoginPage> createState() => _RLoginPageState();
}

class _RLoginPageState extends State<RLoginPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormCubit(phoneNumberService: PhoneNumberService()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpRequestSuccess) {
                final phone = context.read<LoginFormCubit>().state.phoneE164;
                if (phone == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider<AuthBloc>.value(value: context.read<AuthBloc>()),
                        BlocProvider<OtpCubit>(
                          create: (_) => OtpCubit(
                            resendOtpUseCase: ResendOtpUseCase(
                              AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
                            ),
                          ),
                        ),
                      ],
                      child: OtpPage(phoneNumber: phone, otpId: state.otpId),
                    ),
                  ),
                );
                SnackBarUtils.show(context, 'OTP sent');
              }
              if (state is AuthFailure) {
                SnackBarUtils.show(context, state.message);
              }
            },
          ),
          BlocListener<LoginFormCubit, LoginFormState>(
            listenWhen: (previous, current) =>
                previous.submitRequested != current.submitRequested ||
                previous.submitError != current.submitError,
            listener: (context, state) {
              if (state.submitError != null) {
                return;
              }
              if (state.submitRequested && state.phoneE164 != null) {
                context.read<AuthBloc>().add(
                      RequestOtpRequested(phone: state.phoneE164!),
                    );
                context.read<LoginFormCubit>().consumeSubmit();
              }
            },
          ),
        ],
        child: BlocBuilder<LoginFormCubit, LoginFormState>(
          builder: (context, formState) {
            if (_controller.text != formState.digits) {
              _controller.value = TextEditingValue(
                text: formState.digits,
                selection: TextSelection.collapsed(
                  offset: formState.digits.length,
                ),
              );
            }
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  'Welcome to Goapp',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Enter your mobile number to begin your\njourney.',
                                  style: TextStyle(
                                    fontSize: 27 / 2,
                                    height: 1.45,
                                    color: AuthUiColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                    fontSize: 25 / 2,
                                    fontWeight: FontWeight.w600,
                                    color: AuthUiColors.textDark,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 30 / 2,
                                        fontWeight: FontWeight.w600,
                                        color: AuthUiColors.textDarkAlt,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 1,
                                      height: 38 / 2,
                                      color: AuthUiColors.textMuted.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                              child: AppTextField(
                                        controller: _controller,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        isCollapsed: true,
                                        filled: false,
                                        hint: '0000000000',
                                        hintStyle: const TextStyle(
                                          color: AuthUiColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                        borderless: true,
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AuthUiColors.textDarkAlt,
                                          letterSpacing: 1.1,
                                        ),
                                        onChanged: (value) {
                                          context.read<LoginFormCubit>().onInputChanged(value);
                                          final digits = context.read<LoginFormCubit>().state.digits;
                                          if (digits.length == 10) {
                                            FocusScope.of(context).unfocus();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 1,
                                  color: AuthUiColors.textMuted.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                if (formState.error != null && formState.rawInput.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Text(
                                      formState.error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        fontSize: 23 / 2,
                                        height: 1.45,
                                        color: AuthUiColors.textMuted,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'By continuing, you agree to receive SMS for verification.  ',
                                        ),
                                        TextSpan(text: ' and\n'),
                                        TextSpan(
                                          text: 'Message and data rates may apply. View our ',
                                        ),
                                        TextSpan(
                                          text: 'Privacy \nPolicy.',
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontSize: 14,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    math.max(
                      MediaQuery.viewInsetsOf(context).bottom,
                      MediaQuery.of(context).padding.bottom,
                    ) +
                        12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final bool loading = state is AuthLoading;
                        return AuthPrimaryButton(
                          label: 'Get Verification Code',
                          loading: loading,
                          onPressed: context.read<LoginFormCubit>().submit,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
