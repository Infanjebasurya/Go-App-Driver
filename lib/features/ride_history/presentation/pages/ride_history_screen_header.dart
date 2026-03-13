part of 'ride_history_screen.dart';

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.totalTrips,
    required this.completedTrips,
    required this.canceledTrips,
    required this.earnings,
  });

  final int totalTrips;
  final int completedTrips;
  final int canceledTrips;
  final double earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.hexFF008051, Color(0xFF00A86B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Trip Overview',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _MetricTile(label: 'Total', value: '$totalTrips'),
              _MetricTile(label: 'Completed', value: '$completedTrips'),
              _MetricTile(label: 'Canceled', value: '$canceledTrips'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated Earnings  Rs ${earnings.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search by pickup, drop, or trip id',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.neutral888),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.neutral666,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.neutral666,
                ),
              ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.strokeLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.strokeLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emerald),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelected,
    required this.totalCount,
    required this.completedCount,
    required this.canceledCount,
  });

  final RideHistoryFilter selected;
  final ValueChanged<RideHistoryFilter> onSelected;
  final int totalCount;
  final int completedCount;
  final int canceledCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: <Widget>[
          _FilterChipItem(
            label: 'All ($totalCount)',
            selected: selected == RideHistoryFilter.all,
            onTap: () => onSelected(RideHistoryFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Completed ($completedCount)',
            selected: selected == RideHistoryFilter.completed,
            onTap: () => onSelected(RideHistoryFilter.completed),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Canceled ($canceledCount)',
            selected: selected == RideHistoryFilter.canceled,
            onTap: () => onSelected(RideHistoryFilter.canceled),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.emerald : AppColors.strokeLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.neutral666,
          ),
        ),
      ),
    );
  }
}

class _EmptyResultState extends StatelessWidget {
  const _EmptyResultState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: const Column(
        children: <Widget>[
          Icon(
            Icons.history_toggle_off_rounded,
            size: 42,
            color: AppColors.neutralAAA,
          ),
          SizedBox(height: 8),
          Text(
            'No trips match this filter',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral666,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try changing search or filter options.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral888,
            ),
          ),
        ],
      ),
    );
  }
}
