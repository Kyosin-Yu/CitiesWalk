import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_nearby_distance.dart';
import '../../business_logic/entities/eco_place_category.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/repositories/eco_route_repository.dart';
import '../data_sources/google_eco_route_data_source.dart';

/// Live Google Places and Routes repository for the Eco-Route feature.
class GoogleEcoRouteRepository implements EcoRouteRepository {
  GoogleEcoRouteRepository(this._dataSource);

  final GoogleEcoRouteDataSource _dataSource;

  @override
  Future<EcoRoute> buildRoute({
    required EcoLocation origin,
    required EcoDestination destination,
  }) => _dataSource.buildRoute(origin: origin, destination: destination);

  @override
  Future<List<EcoDestination>> fetchNearbyDestinations({
    required EcoLocation origin,
    EcoPlaceCategory category = EcoPlaceCategory.all,
    EcoNearbyDistance nearbyDistance = EcoNearbyDistance.oneKm,
  }) => _dataSource.fetchNearby(
    origin: origin,
    category: category,
    radiusKm: nearbyDistance.kilometres,
  );

  @override
  Future<List<EcoDestination>> searchDestinations({
    required String query,
    required EcoLocation origin,
  }) => _dataSource.search(query: query, origin: origin);
}
