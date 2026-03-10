part of 'earnings_details_page.dart';

class _WeekRangeChips extends StatelessWidget {
  const _WeekRangeChips({
    required this.ranges,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_WeekRange> ranges;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool compact = width < 340;
        if (compact) {
          return SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ranges.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _WeekRangeChip(
                  label: ranges[index].label,
                  selected: selectedIndex == index,
                  onTap: () => onSelect(index),
                );
              },
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List<Widget>.generate(ranges.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == ranges.length - 1 ? 0 : 10),
                  child: _WeekRangeChip(
                    label: ranges[index].label,
                    selected: selectedIndex == index,
                    onTap: () => onSelect(index),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _WeekRangeChip extends StatelessWidget {
  const _WeekRangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.hexFFB7D7CC : AppColors.hexFFF3F3F3,
          borderRadius: BorderRadius.circular(18),
          border: selected ? Border.all(color: AppColors.emerald) : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? AppColors.emerald : AppColors.neutral666,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderHistoryTabs extends StatelessWidget {
  const _OrderHistoryTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(0),
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selectedIndex == 0 ? AppColors.emerald : AppColors.strokeLight,
                    width: selectedIndex == 0 ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                'Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selectedIndex == 0 ? AppColors.black : AppColors.neutral666,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(1),
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selectedIndex == 1 ? AppColors.emerald : AppColors.strokeLight,
                    width: selectedIndex == 1 ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                'Cancelled',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selectedIndex == 1 ? AppColors.black : AppColors.neutral666,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}




