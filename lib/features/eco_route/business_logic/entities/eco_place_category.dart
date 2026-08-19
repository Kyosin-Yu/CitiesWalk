enum EcoPlaceCategory {
  all,
  food,
  attractions,
  history,
  parks,
  museums,
  markets;

  String get label => switch (this) {
    EcoPlaceCategory.all => 'All',
    EcoPlaceCategory.food => 'Food',
    EcoPlaceCategory.attractions => 'Attractions',
    EcoPlaceCategory.history => 'History',
    EcoPlaceCategory.parks => 'Parks',
    EcoPlaceCategory.museums => 'Museums',
    EcoPlaceCategory.markets => 'Markets',
  };

  String get apiValue => name;
}
