import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';

/// Live Google map for selecting a suggested destination.
class NearbyPlacesMap extends StatefulWidget {
  const NearbyPlacesMap({
    super.key,
    required this.origin,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onStartingPointSelected,
    required this.showMyLocation,
    required this.originIsDeviceLocation,
    required this.showOriginMarker,
  });

  final EcoLocation origin;
  final List<EcoDestination> destinations;
  final ValueChanged<EcoDestination> onDestinationSelected;
  final ValueChanged<EcoLocation> onStartingPointSelected;
  final bool showMyLocation;
  final bool originIsDeviceLocation;
  final bool showOriginMarker;

  @override
  State<NearbyPlacesMap> createState() => _NearbyPlacesMapState();
}

class _NearbyPlacesMapState extends State<NearbyPlacesMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant NearbyPlacesMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final originChanged =
        oldWidget.origin.latitude != widget.origin.latitude ||
        oldWidget.origin.longitude != widget.origin.longitude;
    final destinationsChanged = !listEquals(
      oldWidget.destinations.map((destination) => destination.id).toList(),
      widget.destinations.map((destination) => destination.id).toList(),
    );
    if (originChanged) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.origin.latitude, widget.origin.longitude),
        ),
      );
    } else if (destinationsChanged) {
      _fitCameraToVisiblePlaces();
    }
  }

  Future<void> _fitCameraToVisiblePlaces() async {
    final controller = _mapController;
    if (controller == null || widget.destinations.isEmpty) return;

    final points = [
      LatLng(widget.origin.latitude, widget.origin.longitude),
      ...widget.destinations.map(
        (destination) => LatLng(
          destination.location.latitude,
          destination.location.longitude,
        ),
      ),
    ];
    if (points.length == 1) return;

    var south = points.first.latitude;
    var north = south;
    var west = points.first.longitude;
    var east = west;
    for (final point in points.skip(1)) {
      south = point.latitude < south ? point.latitude : south;
      north = point.latitude > north ? point.latitude : north;
      west = point.longitude < west ? point.longitude : west;
      east = point.longitude > east ? point.longitude : east;
    }
    if (south == north && west == east) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 15));
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        42,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
              target: LatLng(widget.origin.latitude, widget.origin.longitude),
              zoom: 13.4,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: widget.showMyLocation,
            myLocationButtonEnabled: widget.showMyLocation,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            },
            mapToolbarEnabled: false,
            onLongPress: (position) => widget.onStartingPointSelected(
              EcoLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                label: 'Selected starting point',
              ),
            ),
            markers: {
              if (widget.showOriginMarker)
                Marker(
                  markerId: const MarkerId('origin'),
                  position: LatLng(
                    widget.origin.latitude,
                    widget.origin.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: widget.originIsDeviceLocation
                        ? 'Live GPS location'
                        : 'Selected starting point',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              ...widget.destinations.map(
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
                  onTap: () => widget.onDestinationSelected(destination),
                ),
              ),
            },
          ),
          const Positioned(
            left: 12,
            top: 12,
            child: _MapPill(
              icon: Icons.near_me_rounded,
              label: 'Drag map • long-press start',
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
