enum EcoPlaceCategory {
  all,
  food,
  attractions,
  history,
  parks,
  museums,
  markets,
  campus,
  malls,
  transit;

  String get label => switch (this) {
    EcoPlaceCategory.all => 'All',
    EcoPlaceCategory.food => 'Food',
    EcoPlaceCategory.attractions => 'Attractions',
    EcoPlaceCategory.history => 'History',
    EcoPlaceCategory.parks => 'Parks',
    EcoPlaceCategory.museums => 'Museums',
    EcoPlaceCategory.markets => 'Markets',
    EcoPlaceCategory.campus => 'Campus',
    EcoPlaceCategory.malls => 'Malls',
    EcoPlaceCategory.transit => 'Transit',
  };

  String get apiValue => name;
}
