import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/sample_eco_route_repository.dart';
import '../../business/services/location_service.dart';
import '../controllers/eco_route_controller.dart';
import 'eco_route_page.dart';

class EcoRouteModule extends StatelessWidget {
  const EcoRouteModule({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EcoRouteController(
        userId: userId,
        repository: const SampleEcoRouteRepository(),
        locationService: const DeviceLocationService(),
      ),
      child: const EcoRoutePage(),
    );
  }
}
