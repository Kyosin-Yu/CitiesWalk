import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';

/// Live Google map for selecting a suggested destination.
class NearbyPlacesMap extends StatelessWidget {
  const NearbyPlacesMap({
    super.key,
    required this.origin,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final EcoLocation origin;
  final List<EcoDestination> destinations;
  final ValueChanged<EcoDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 225,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(origin.latitude, origin.longitude),
              zoom: 13.4,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('origin'),
                position: LatLng(origin.latitude, origin.longitude),
                infoWindow: const InfoWindow(title: 'Current location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
              ...destinations.map(
                (destination) => Marker(
                  markerId: MarkerId(destination.id),
                  position: LatLng(
                    destination.location.latitude,
                    destination.location.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: destination.name,
                    snippet: 'Tap to plan a route',
                  ),
                  onTap: () => onDestinationSelected(destination),
                ),
              ),
            },
          ),
          const Positioned(
            left: 12,
            top: 12,
            child: _MapPill(
              icon: Icons.near_me_rounded,
              label: 'Google Maps nearby places',
            ),
          ),
        ],
      ),
    ),
  );
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
