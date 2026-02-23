import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_state.dart';
import 'package:goapp/features/home/presentation/pages/ride_arrived_page.dart';

class AvailableOrdersPage extends StatelessWidget {
  const AvailableOrdersPage({super.key});

  void _goToRideScreen(
    BuildContext context, {
    required LatLng pickupPoint,
    required LatLng dropPoint,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RideArrivedPage(
          pickupPoint: pickupPoint,
          dropPoint: dropPoint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AvailableOrdersCubit>(
      create: (_) => AvailableOrdersCubit()..start(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceF5,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          elevation: 0.8,
          toolbarHeight: 86,
          centerTitle: false,
          titleSpacing: 16,
          title: const _OrdersAppBarTitle(),
        ),
        body: BlocBuilder<AvailableOrdersCubit, AvailableOrdersState>(
          builder: (BuildContext context, AvailableOrdersState state) {
            final cubit = context.read<AvailableOrdersCubit>();
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
              children: <Widget>[
                _OrderCard(
                  fare: '\u20B990',
                  pickupTitle: 'Arumbakkam',
                  pickupAddress: '42, MMDA Colony, Arumbakkam,\nch-106',
                  dropTitle: 'Amjikarai',
                  dropAddress:
                      '13, vinobaji St, Kamarajar Nagar, NGO\nColonyCholaimedu, Ch-94',
                  progress: cubit.progressForOrder(0),
                  onAccept: () => _goToRideScreen(
                    context,
                    pickupPoint: const LatLng(13.0696, 80.2154),
                    dropPoint: const LatLng(13.0744, 80.2241),
                  ),
                ),
                if (state.showSecondOrder) ...<Widget>[
                  const SizedBox(height: 14),
                  _OrderCard(
                    fare: '\u20B9100',
                    pickupTitle: 'Amjikarai',
                    pickupAddress:
                        '13, vinobaji St, Kamarajar Nagar, NGO\nColonyCholaimedu, Ch-94',
                    dropTitle: 'Amjikarai',
                  dropAddress:
                      '13, vinobaji St, Kamarajar Nagar, NGO\nColonyCholaimedu, Ch-94',
                  progress: cubit.progressForOrder(1),
                  onAccept: () => _goToRideScreen(
                    context,
                    pickupPoint: const LatLng(13.0721, 80.2186),
                    dropPoint: const LatLng(13.0662, 80.2103),
                  ),
                ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersAppBarTitle extends StatelessWidget {
  const _OrdersAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Available Orders',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral333,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Tap to Accept   |   Auto-expires in 30s',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral555,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceFDF8,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.circle, size: 7, color: AppColors.emerald),
                  SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.fare,
    required this.pickupTitle,
    required this.pickupAddress,
    required this.dropTitle,
    required this.dropAddress,
    required this.progress,
    required this.onAccept,
  });

  final String fare;
  final String pickupTitle;
  final String pickupAddress;
  final String dropTitle;
  final String dropAddress;
  final double progress;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress,
                backgroundColor: AppColors.surfaceF0,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fare,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'incl. tips & surge',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral888,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: <Widget>[
                Icon(Icons.navigation_outlined, size: 15, color: AppColors.neutral666),
                SizedBox(width: 4),
                Text(
                  '2.5 km',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral555,
                  ),
                ),
                SizedBox(width: 8),
                Text('|', style: TextStyle(color: AppColors.neutral888)),
                SizedBox(width: 8),
                Icon(Icons.access_time_rounded, size: 15, color: AppColors.neutral666),
                SizedBox(width: 4),
                Text(
                  '~12 mins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral555,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LocationPoint(
              title: pickupTitle,
              subtitle: pickupAddress,
              distance: '0.8 km',
              showConnector: true,
            ),
            const SizedBox(height: 8),
            _LocationPoint(
              title: dropTitle,
              subtitle: dropAddress,
              distance: '2.8 km',
              showConnector: false,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceF5,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral555,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onAccept,
                      child: const Text(
                        'Accept Order',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPoint extends StatelessWidget {
  const _LocationPoint({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.showConnector,
  });

  final String title;
  final String subtitle;
  final String distance;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 18,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(Icons.radio_button_unchecked, size: 13, color: AppColors.neutral666),
              ),
              if (showConnector)
                Container(width: 1.2, height: 40, color: AppColors.neutralCCC),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral333,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral666,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceF0,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            distance,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral666,
            ),
          ),
        ),
      ],
    );
  }
}
