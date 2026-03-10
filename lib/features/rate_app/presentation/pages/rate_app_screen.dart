import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/keyboard_aware_bottom.dart';
import 'package:goapp/features/rate_app/presentation/cubit/rate_app_cubit.dart';
import 'package:goapp/features/rate_app/presentation/cubit/rate_app_state.dart';
import 'package:goapp/core/widgets/persistent_text_controller.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class RateAppScreen extends StatelessWidget {
  const RateAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RateAppCubit(),
      child: const _RateAppView(),
    );
  }
}

class _RateAppView extends StatefulWidget {
  const _RateAppView();

  @override
  State<_RateAppView> createState() => _RateAppViewState();
}

class _RateAppViewState extends State<_RateAppView> {
  late final PersistentTextController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = PersistentTextController(
      storageKey: 'rate_app.feedback',
    );
    _feedbackController.attach();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_feedbackController.text.isNotEmpty) {
        context.read<RateAppCubit>().updateFeedback(
              _feedbackController.text,
            );
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Rate App'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.strokeLight, height: 1),
        ),
      ),
      body: BlocConsumer<RateAppCubit, RateAppState>(
        listener: (context, state) {
          if (state.status == RateAppStatus.submitted) {
            _showSuccessDialog(context);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _HeroStar(rating: state.selectedRating),
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Enjoying the Goapp\nExperience?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingDark,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Your feedback helps us maintain\nthe gold standard of service.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral888,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _StarSelector(
                        rating: state.selectedRating,
                        onSelect: (r) =>
                            context.read<RateAppCubit>().selectRating(r),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: state.selectedRating > 0
                            ? Padding(
                                key: ValueKey<int>(state.selectedRating),
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _ratingLabel(state.selectedRating),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 20, key: ValueKey<int>(0)),
                      ),
                      const SizedBox(height: 20),
                      _FeedbackBox(
                        enabled:
                            state.status != RateAppStatus.submitting &&
                            state.status != RateAppStatus.submitted,
                        controller: _feedbackController,
                        onChanged: (t) =>
                            context.read<RateAppCubit>().updateFeedback(t),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.neutralDDD,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<RateAppCubit, RateAppState>(
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: KeyboardAwareBottom(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _SubmitButton(state: state),
            ),
          );
        },
      ),
    );
  }

  static String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.emerald,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your review has been submitted.\nWe appreciate your feedback!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral888,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ShadowButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStar extends StatefulWidget {
  final int rating;

  const _HeroStar({required this.rating});

  @override
  State<_HeroStar> createState() => _HeroStarState();
}

class _HeroStarState extends State<_HeroStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(covariant _HeroStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating && widget.rating > 0) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.rating > 0 ? AppColors.emerald : AppColors.neutralDDD;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.star, color: color, size: 74),
      ),
    );
  }
}

class _StarSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onSelect;

  const _StarSelector({required this.rating, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(5, (i) {
        final starIndex = i + 1;
        final filled = starIndex <= rating;
        return GestureDetector(
          onTap: () => onSelect(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                filled ? Icons.star : Icons.star_outline,
                key: ValueKey<String>('$starIndex-$filled'),
                color: filled ? AppColors.starYellow : AppColors.neutralDDD,
                size: 42,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FeedbackBox({
    required this.enabled,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.strokeLight),
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        maxLines: 5,
        minLines: 4,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.neutral333,
          height: 1.5,
        ),
        decoration: InputDecoration(
          fillColor: AppColors.white,
          filled: true,
          hintText: 'Share your feedback',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral888,
          ),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.strokeLight, width: 1.2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final RateAppState state;

  const _SubmitButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == RateAppStatus.submitting;
    final isSubmitted = state.status == RateAppStatus.submitted;
    final isEnabled = state.canSubmit && !isLoading && !isSubmitted;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ShadowButton(
        onPressed: isEnabled
            ? () => context.read<RateAppCubit>().submitReview()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.emerald : AppColors.neutralCCC,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                isSubmitted ? '✓ REVIEW SUBMITTED' : 'SUBMIT REVIEW',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    );
  }
}






