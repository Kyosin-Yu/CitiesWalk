import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_route_segment.dart';
import '../../business_logic/entities/eco_location.dart';

/// Real Google map embedded in the Eco-Route page.
class EcoRouteMap extends StatefulWidget {
  const EcoRouteMap({super.key, required this.route, this.currentLocation});

  final EcoRoute route;
  final EcoLocation? currentLocation;

  @override
  State<EcoRouteMap> createState() => _EcoRouteMapState();
}

class _EcoRouteMapState extends State<EcoRouteMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant EcoRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final location = widget.currentLocation;
    if (location != null && location != oldWidget.currentLocation) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = [
      widget.route.origin,
      for (final segment in widget.route.segments) ...segment.mapPath,
      widget.route.destination.location,
    ];
    final mapPoints = points
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList();

    return _GoogleMapFrame(
      label: 'Google Maps route to ${widget.route.destination.name}',
      bottomLeft: widget.route.hasTransit ? 'Rail route' : 'Walking route',
      bottomRight: '${widget.route.durationMinutes} min',
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: mapPoints[mapPoints.length ~/ 2],
                zoom: 13.2,
              ),
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              // Custom buttons work reliably inside the page's scroll view on
              // Android and iOS, including zooming back out.
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
              mapToolbarEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('origin'),
                  position: LatLng(
                    widget.route.origin.latitude,
                    widget.route.origin.longitude,
                  ),
                  infoWindow: const InfoWindow(title: 'Starting point'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    widget.route.destination.location.latitude,
                    widget.route.destination.location.longitude,
                  ),
                  infoWindow: InfoWindow(title: widget.route.destination.name),
                ),
                if (widget.currentLocation != null)
                  Marker(
                    markerId: const MarkerId('live-location'),
                    position: LatLng(
                      widget.currentLocation!.latitude,
                      widget.currentLocation!.longitude,
                    ),
                    infoWindow: const InfoWindow(title: 'Your live location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
              },
              polylines: _polylines(),
            ),
          ),
          Positioned(
            right: 12,
            top: 62,
            child: _ZoomControls(
              onZoomIn: () =>
                  _mapController?.animateCamera(CameraUpdate.zoomBy(1)),
              onZoomOut: () =>
                  _mapController?.animateCamera(CameraUpdate.zoomBy(-1)),
            ),
          ),
        ],
      ),
    );
  }

  Set<Polyline> _polylines() => widget.route.segments
      .where((segment) => segment.mapPath.length >= 2)
      .map(
        (segment) => Polyline(
          polylineId: PolylineId('${segment.type}-${segment.title}'),
          points: segment.mapPath
              .map((location) => LatLng(location.latitude, location.longitude))
              .toList(),
          width: segment.type == EcoRouteSegmentType.transit ? 7 : 5,
          color: segment.type == EcoRouteSegmentType.transit
              ? const Color(0xFF1565C0)
              : AppColors.primary,
          patterns: segment.type == EcoRouteSegmentType.walk
              ? [PatternItem.dot, PatternItem.gap(10)]
              : const [],
        ),
      )
      .toSet();
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .96),
    borderRadius: BorderRadius.circular(12),
    elevation: 2,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom in',
          onPressed: onZoomIn,
          icon: const Icon(Icons.add_rounded),
        ),
        const Divider(height: 1),
        IconButton(
          tooltip: 'Zoom out',
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove_rounded),
        ),
      ],
    ),
  );
}

class _GoogleMapFrame extends StatelessWidget {
  const _GoogleMapFrame({
    required this.label,
    required this.bottomLeft,
    required this.bottomRight,
    required this.child,
  });

  final String label;
  final String bottomLeft;
  final String bottomRight;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(
              left: 12,
              top: 12,
              child: _MapPill(
                icon: Icons.touch_app_rounded,
                label: 'Drag or zoom map',
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: _MapPill(icon: Icons.train_rounded, label: bottomLeft),
            ),
            const Positioned(right: 12, top: 12, child: _RouteLegend()),
            Positioned(
              right: 12,
              bottom: 12,
              child: _MapPill(icon: Icons.schedule_rounded, label: bottomRight),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RouteLegend extends StatelessWidget {
  const _RouteLegend();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.train_rounded, size: 14, color: Color(0xFF1565C0)),
        SizedBox(width: 3),
        Icon(Icons.directions_walk_rounded, size: 14, color: AppColors.primary),
      ],
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
