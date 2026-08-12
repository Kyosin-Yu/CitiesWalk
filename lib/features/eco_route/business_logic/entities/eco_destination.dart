import 'eco_location.dart';

class EcoDestination {
  const EcoDestination({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final EcoLocation location;
}
