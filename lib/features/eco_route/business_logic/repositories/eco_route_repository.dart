import '../entities/eco_destination.dart';
import '../entities/eco_location.dart';
import '../entities/eco_route.dart';

abstract interface class EcoRouteRepository {
  Future<List<EcoDestination>> searchDestinations({
    required String query,
    required EcoLocation origin,
  });

  Future<List<EcoDestination>> fetchNearbyDestinations({
    required EcoLocation origin,
  });

  Future<EcoRoute> buildRoute({
    required EcoLocation origin,
    required EcoDestination destination,
  });
}
