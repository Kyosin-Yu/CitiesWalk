import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/completed_fitness_journey.dart';
import '../../business_logic/entities/fitness_route_point.dart';

class FitnessHistoryRouteMap extends StatefulWidget {
  const FitnessHistoryRouteMap({
    super.key,
    required this.journey,
    required this.routePoints,
    required this.isLoading,
    required this.hasLoaded,
    required this.errorMessage,
    required this.onRetry,
  });

  final CompletedFitnessJourney journey;
  final List<FitnessRoutePoint> routePoints;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  State<FitnessHistoryRouteMap> createState() => _FitnessHistoryRouteMapState();
}

class _FitnessHistoryRouteMapState extends State<FitnessHistoryRouteMap> {
  GoogleMapController? _controller;

  bool get _supportsGoogleMap =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  List<LatLng> get _track => widget.routePoints
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList(growable: false);

  List<LatLng> get _visiblePoints {
    final points = <LatLng>[..._track];
    final journey = widget.journey;
    if (journey.originLatitude != null && journey.originLongitude != null) {
      points.add(LatLng(journey.originLatitude!, journey.originLongitude!));
    }
    if (journey.destinationLatitude != null &&
        journey.destinationLongitude != null) {
      points.add(
        LatLng(journey.destinationLatitude!, journey.destinationLongitude!),
      );
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsGoogleMap) {
      return const _MapMessage(
        icon: Icons.devices_rounded,
        title: 'Map preview is unavailable on this device',
        message: 'Open this history item on Android, iOS, or Web to view it.',
      );
    }
    if (widget.isLoading && !widget.hasLoaded) {
      return const _LoadingMap();
    }
    if (widget.errorMessage != null && !widget.hasLoaded) {
      return _MapError(message: widget.errorMessage!, onRetry: widget.onRetry);
    }
    if (_visiblePoints.isEmpty) {
      return const _MapMessage(
        icon: Icons.location_off_rounded,
        title: 'Route coordinates unavailable',
        message: 'This older journey does not contain map coordinates.',
      );
    }

    final track = _track;
    final initialTarget = track.isNotEmpty ? track.first : _visiblePoints.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 360,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _controller = controller;
                _fitRoute();
              },
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: _markers(track),
              polylines: track.length < 2
                  ? const {}
                  : {
                      Polyline(
                        polylineId: const PolylineId('recorded-route'),
                        points: track,
                        width: 6,
                        color: AppColors.primary,
                      ),
                    },
            ),
          ),
        ),
        if (widget.hasLoaded && track.length < 2) ...[
          const SizedBox(height: 8),
          Text(
            'No GPS track was recorded for this journey. The map only shows its saved start and destination.',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 8),
          _InlineRetry(message: widget.errorMessage!, onRetry: widget.onRetry),
        ],
      ],
    );
  }

  Set<Marker> _markers(List<LatLng> track) {
    final journey = widget.journey;
    return {
      if (journey.originLatitude != null && journey.originLongitude != null)
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(journey.originLatitude!, journey.originLongitude!),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: journey.originName ?? 'Journey origin',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      if (journey.destinationLatitude != null &&
          journey.destinationLongitude != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            journey.destinationLatitude!,
            journey.destinationLongitude!,
          ),
          infoWindow: InfoWindow(
            title: journey.countsAsCompletedRoute
                ? 'Destination'
                : 'Planned destination',
            snippet: journey.destinationName ?? 'Journey destination',
          ),
        ),
      if (!journey.countsAsCompletedRoute && track.isNotEmpty)
        Marker(
          markerId: const MarkerId('stopped'),
          position: track.last,
          infoWindow: const InfoWindow(title: 'Journey stopped here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
    };
  }

  Future<void> _fitRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final controller = _controller;
    final points = _visiblePoints;
    if (!mounted || controller == null || points.isEmpty) return;
    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.single, 15),
      );
      return;
    }

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;
    for (final point in points.skip(1)) {
      minLatitude = math.min(minLatitude, point.latitude);
      maxLatitude = math.max(maxLatitude, point.latitude);
      minLongitude = math.min(minLongitude, point.longitude);
      maxLongitude = math.max(maxLongitude, point.longitude);
    }
    if (minLatitude == maxLatitude && minLongitude == maxLongitude) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLatitude, minLongitude),
          northeast: LatLng(maxLatitude, maxLongitude),
        ),
        48,
      ),
    );
  }
}

class _LoadingMap extends StatelessWidget {
  const _LoadingMap();

  @override
  Widget build(BuildContext context) => Container(
    height: 360,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const CircularProgressIndicator(color: AppColors.primary),
  );
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Icon(icon, size: 36, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _MapError extends StatelessWidget {
  const _MapError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _MapMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Route could not be loaded',
        message: 'Check your connection and try again.',
      ),
      const SizedBox(height: 8),
      _InlineRetry(message: message, onRetry: onRetry),
    ],
  );
}

class _InlineRetry extends StatelessWidget {
  const _InlineRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.error),
        ),
      ),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}
