import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/earnings/presentation/pages/earnings_screen.dart';
import 'package:goapp/features/ride_complete/data/repositories/ride_complete_repository_impl.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_feedback_tags.dart';
import 'package:goapp/features/ride_complete/domain/usecases/submit_ride_feedback.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/rate_experience_cubit.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/rate_experience_state.dart';

class RateExperienceScreen extends StatelessWidget {
  const RateExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RideCompleteRepositoryImpl();
    return BlocProvider<RateExperienceCubit>(
      create: (_) => RateExperienceCubit(
        GetFeedbackTags(repository),
        SubmitRideFeedback(repository),
      ),
      child: const _RateExperienceView(),
    );
  }
}

class _RateExperienceView extends StatelessWidget {
  const _RateExperienceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocBuilder<RateExperienceCubit, RateExperienceState>(
          builder: (BuildContext context, RateExperienceState state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Rate Your Experience',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Passenger Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/image/profile.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sam Yogi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFC107),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (int index) {
                      return GestureDetector(
                        onTap: () {
                          context.read<RateExperienceCubit>().selectRating(
                            index + 1,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.star_rounded,
                            size: 40,
                            color: index < state.selectedRating
                                ? const Color(0xFFFFC107)
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: state.feedbackTags.map((String tag) {
                      final bool isSelected = state.selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<RateExperienceCubit>().toggleTag(tag);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF00C853),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: 'Additional Comments ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                        children: [
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: context
                        .read<RateExperienceCubit>()
                        .updateComment,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share more details about your ride...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<RateExperienceCubit>()
                            .submitFeedback();
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EarningsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit & Return Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
