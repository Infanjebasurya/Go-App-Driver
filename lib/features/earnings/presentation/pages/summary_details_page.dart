import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import '../widgets/trip_card.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class SummaryDetailsPage extends StatelessWidget {
  final String title;
  final String dateTitle;
  final String summaryPillText;

  const SummaryDetailsPage({
    super.key,
    required this.title,
    required this.dateTitle,
    required this.summaryPillText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.earningsAccentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summaryPillText,
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) {
                return const TripCard(
                  date: 'Today',
                  timeRange: '05:30pm to 06:10pm',
                  price: '?850',
                  pickupLocation: 'Arumbakkam',
                  pickupAddress: '42 i-bloack, arumbakkam',
                  dropLocation: 'VR Mall',
                  dropAddress: '42 i-bloack, arumbakkam',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
