import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import '../widgets/trip_card.dart';
import 'summary_details_page.dart';

class EarningsDetailsPage extends StatefulWidget {
  const EarningsDetailsPage({super.key});

  @override
  State<EarningsDetailsPage> createState() => _EarningsDetailsPageState();
}

class _EarningsDetailsPageState extends State<EarningsDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Day';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Earnings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTimeTab('Day'),
                _buildTimeTab('Week'),
                _buildTimeTab('Month'),
              ],
            ),
          ),
          Expanded(
            child: _selectedPeriod == 'Week'
                ? _buildWeekView()
                : _selectedPeriod == 'Month'
                    ? _buildMonthView()
                    : _buildDayView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String text) {
    final isSelected = _selectedPeriod == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = text;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(25),
                )
              : null,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayView() {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _buildDateItem('Tue', '10', false),
              _buildDateItem('Wed', '11', false),
              _buildDateItem('Thu', '12', true),
              const SizedBox(width: 50),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildSummaryCard(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Order History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.emerald,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCompletedList(),
              const Center(child: Text('No cancelled rides')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.earningsAccentSoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppColors.emerald.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.emerald : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? AppColors.emerald : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildWeekRangePill('Feb 02 - 08', false),
                const SizedBox(width: 12),
                _buildWeekRangePill('Feb 06 - 13', true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendDot(AppColors.emerald, 'Weekday'),
                    const SizedBox(width: 12),
                    _buildLegendDot(AppColors.gold, 'Weekend'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBarChart(),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Order History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.emerald,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildWeeklySummaryItem(
            'Friday, 12 Feb',
            '4 Rides • Premium Class',
            '?2,450',
          ),
          _buildWeeklySummaryItem(
            'Thursday, 11 Feb',
            '4 Rides • Premium Class',
            '?2,450',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWeekRangePill(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.earningsAccentSoft : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isSelected ? Border.all(color: AppColors.emerald) : null,
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.emerald : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const Divider(color: AppColors.strokeLight, height: 1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('M', 0.6, false),
              _buildBar('T', 0.5, false),
              _buildBar('W', 0.8, false),
              _buildBar('T', 0.4, false),
              _buildBar('F', 0.7, false),
              _buildBar('S', 0.9, true),
              _buildBar('S', 0.0, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percentage, bool isWeekend) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 6,
          height: 150 * percentage,
          decoration: BoxDecoration(
            color: isWeekend ? AppColors.gold : AppColors.emerald,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummaryItem(String date, String subtitle, String price) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            decoration: const BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earned',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '?2,450',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rides',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '03',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Today\'s Activity',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        _buildTripCard(),
        const SizedBox(height: 16),
        _buildTripCard(),
      ],
    );
  }

  Widget _buildTripCard() {
    return const TripCard(
      date: 'Today',
      timeRange: '05:30pm to 06:10pm',
      price: '?850',
      pickupLocation: 'Arumbakkam',
      pickupAddress: '42 i-bloack, arumbakkam',
      dropLocation: 'VR Mall',
      dropAddress: '42 i-bloack, arumbakkam',
    );
  }

  Widget _buildMonthView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildMonthPill('Jan', false),
                const SizedBox(width: 12),
                _buildMonthPill('Feb', true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryCard(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                _buildLegendDot(AppColors.emerald, 'Monthly'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildMonthlyBarChart(),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Order History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.emerald,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMonthlySummaryItem('Week 2', '28 Completed Rides', '?5,450'),
          _buildMonthlySummaryItem('Week 1', '28 Completed Rides', '?4,450'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMonthPill(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.earningsAccentSoft : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isSelected ? Border.all(color: AppColors.emerald) : null,
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.emerald : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const Divider(color: AppColors.strokeLight, height: 1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMonthlyBar('Week 1', 0.6),
              _buildMonthlyBar('Week 2', 0.5),
              _buildMonthlyBar('Week 3', 0.0),
              _buildMonthlyBar('Week 4', 0.0),
              _buildMonthlyBar('Week 5', 0.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBar(String week, double percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: 150 * percentage,
          decoration: BoxDecoration(
            color: AppColors.emerald,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          week,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryItem(String week, String subtitle, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SummaryDetailsPage(
              title: 'Month',
              dateTitle: 'Week 2',
              summaryPillText: '?5,450 • 28 Rides',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: const BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          week,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


