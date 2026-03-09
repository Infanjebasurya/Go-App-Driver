import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen/complaint_category_picker_sheet.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen/complaint_form_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen/complaint_success_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintCubit, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintFormState && state.showCategoryPicker) {
          _showCategoryPicker(context);
        }
      },
      builder: (context, state) {
        if (state is ComplaintSubmitted) {
          return ComplaintSuccessScreen(
            ticket: state.ticket,
            recentTickets: state.recentTickets,
          );
        }
        return ComplaintFormScreen(
          state: state is ComplaintFormState
              ? state
              : const ComplaintFormState(),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ComplaintCubit>(),
        child: const ComplaintCategoryPickerSheet(),
      ),
    );
  }
}

