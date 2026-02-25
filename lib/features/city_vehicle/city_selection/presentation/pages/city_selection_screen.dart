import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/cubit/city_selection_cubit.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/widget/city_list.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/widget/featured_city_chip.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/pages/vehicle_selection_screen.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CitySelectionCubit(),
      child: const _CitySelectionView(),
    );
  }
}

class _CitySelectionView extends StatefulWidget {
  const _CitySelectionView();

  @override
  State<_CitySelectionView> createState() => _CitySelectionViewState();
}

class _CitySelectionViewState extends State<_CitySelectionView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(title: 'GoApp', backEnabled: false),
      bottomNavigationBar: BlocBuilder<CitySelectionCubit, CitySelectionState>(
        builder: (context, state) {
          return _ContinueButton(
            enabled: state.hasSelection,
            onTap: () {
              if (state.hasSelection) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleSelectionScreen(
                      selectedCity: state.selectedCity!,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      body: BlocBuilder<CitySelectionCubit, CitySelectionState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Where will you be\ndriving?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingNavy,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SELECT YOUR PRIMARY OPERATIONAL CITY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.emerald,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (q) =>
                          context.read<CitySelectionCubit>().search(q),
                      onClear: () {
                        _searchController.clear();
                        context.read<CitySelectionCubit>().clearSearch();
                      },
                    ),
                    const SizedBox(height: 20),
                    if (state.filteredFeaturedCities.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: state.filteredFeaturedCities.map((city) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: FeaturedCityChip(
                              city: city,
                              isSelected: state.isSelected(city),
                              onTap: () => context
                                  .read<CitySelectionCubit>()
                                  .selectCity(city),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 6),
                  child: Text(
                    'ALL CITIES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  child: state.filteredAllCities.isEmpty
                      ? _EmptyState(query: state.searchQuery)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.filteredAllCities.length,
                          itemBuilder: (context, i) {
                            final city = state.filteredAllCities[i];
                            return CityListTile(
                              key: ValueKey(city.id),
                              city: city,
                              isSelected: state.isSelected(city),
                              onTap: () => context
                                  .read<CitySelectionCubit>()
                                  .selectCity(city),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: AppTextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
        ],


        textStyle: const TextStyle(
          fontSize: 14.5,
          color: AppColors.headingNavy,
        ),
        hint: 'Search for your city...',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        leading: Icon(
          Icons.search_rounded,
          color: Colors.grey.shade400,
          size: 20,
        ),
        trailing: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              )
            : null,
        borderColor: Colors.grey.shade400,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 44,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No cities found for "$query"',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        math.max(
              MediaQuery.viewInsetsOf(context).bottom,
              MediaQuery.of(context).padding.bottom,
            ) +
            20,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('continue_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: enabled ? onTap : null,
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
