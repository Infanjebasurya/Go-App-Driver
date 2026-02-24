import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String id;
  final String name;
  final bool isFeatured;

  const City({required this.id, required this.name, this.isFeatured = false});

  @override
  List<Object?> get props => [id, name, isFeatured];
}

const List<City> kFeaturedCities = [
  City(id: 'chennai', name: 'Chennai', isFeatured: true),
  City(id: 'mumbai', name: 'Mumbai', isFeatured: true),
  City(id: 'delhi', name: 'Delhi', isFeatured: true),
];

const List<City> kAllCities = [
  City(id: 'ahmedabad', name: 'Ahmedabad'),
  City(id: 'bengaluru', name: 'Bengaluru'),
  City(id: 'hyderabad', name: 'Hyderabad'),
  City(id: 'pune', name: 'Pune'),
  City(id: 'kolkata', name: 'Kolkata'),
  City(id: 'jaipur', name: 'Jaipur'),
  City(id: 'lucknow', name: 'Lucknow'),
  City(id: 'surat', name: 'Surat'),
  City(id: 'nagpur', name: 'Nagpur'),
  City(id: 'indore', name: 'Indore'),
  City(id: 'bhopal', name: 'Bhopal'),
  City(id: 'patna', name: 'Patna'),
];

class CitySelectionState extends Equatable {
  final City? selectedCity;
  final String searchQuery;
  final List<City> filteredAllCities;

  const CitySelectionState({
    this.selectedCity,
    this.searchQuery = '',
    this.filteredAllCities = kAllCities,
  });

  factory CitySelectionState.initial() =>
      const CitySelectionState(filteredAllCities: kAllCities);

  bool get hasSelection => selectedCity != null;

  bool isSelected(City city) => selectedCity?.id == city.id;

  List<City> get filteredFeaturedCities {
    if (searchQuery.isEmpty) return kFeaturedCities;
    final q = searchQuery.toLowerCase();
    return kFeaturedCities
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  CitySelectionState copyWith({
    City? selectedCity,
    bool clearSelection = false,
    String? searchQuery,
    List<City>? filteredAllCities,
  }) {
    return CitySelectionState(
      selectedCity: clearSelection ? null : (selectedCity ?? this.selectedCity),
      searchQuery: searchQuery ?? this.searchQuery,
      filteredAllCities: filteredAllCities ?? this.filteredAllCities,
    );
  }

  @override
  List<Object?> get props => [selectedCity, searchQuery, filteredAllCities];
}
