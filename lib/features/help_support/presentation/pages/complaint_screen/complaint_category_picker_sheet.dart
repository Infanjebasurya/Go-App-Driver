import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';

class ComplaintCategoryPickerSheet extends StatelessWidget {
  const ComplaintCategoryPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintCubit, ComplaintState>(
      builder: (context, state) {
        final cubit = context.read<ComplaintCubit>();
        final selected = state is ComplaintFormState
            ? state.selectedCategoryId
            : null;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'PLEASE SPECIFY THE NATURE OF YOUR CONCERN',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              ...kComplaintCategories.map(
                (cat) => ComplaintCategoryTile(
                  category: cat,
                  isSelected: selected == cat.id,
                  onTap: () {
                    cubit.selectCategory(cat.id);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              ShadowButton(
                onPressed: selected != null
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Selection',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ComplaintCategoryTile extends StatelessWidget {
  const ComplaintCategoryTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ComplaintCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.emerald : AppColors.borderSoft,
                  width: 2,
                ),
                color: isSelected ? AppColors.emerald : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
