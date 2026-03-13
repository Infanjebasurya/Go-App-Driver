import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class SelectionBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelect;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelect,
  });

  @override
  State<SelectionBottomSheet<T>> createState() =>
      _SelectionBottomSheetState<T>();
}

class _SelectionBottomSheetState<T> extends State<SelectionBottomSheet<T>> {
  T? _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.hexFFDDE4EC,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingNavy,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.coolwhite),
          ...widget.options.map((option) {
            final label = widget.labelBuilder(option);
            final isSelected = _localSelected == option;
            return _OptionTile(
              label: label,
              isSelected: isSelected,
              onTap: () {
                setState(() => _localSelected = option);
                widget.onSelect(option);
              },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.emerald : AppColors.headingNavy,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.emerald : AppColors.hexFFB6C2CF,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T? selected,
  required String Function(T) labelBuilder,
  required ValueChanged<T> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) => SelectionBottomSheet<T>(
      title: title,
      options: options,
      selected: selected,
      labelBuilder: labelBuilder,
      onSelect: (value) {
        onSelect(value);
        Navigator.pop(context);
      },
    ),
  );
}
