import '../../business/models/eco_destination.dart';
import '../../business/models/eco_location.dart';
import '../../business/models/eco_route.dart';

abstract interface class EcoRouteRepository {
  Future<List<EcoDestination>> searchDestinations(String query);

  Future<List<EcoDestination>> fetchNearbyDestinations();

  Future<EcoRoute> buildRoute({
    required EcoLocation origin,
    required EcoDestination destination,
  });
}
