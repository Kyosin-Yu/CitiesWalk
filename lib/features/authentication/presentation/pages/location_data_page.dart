import 'dart:async';

import 'package:citieswalk/core/localization/localized_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/location_access.dart';
import '../../business_logic/providers/location_data_controller.dart';

class LocationDataPage extends StatefulWidget {
  const LocationDataPage({super.key, required this.controller});

  final LocationDataController controller;

  @override
  State<LocationDataPage> createState() => _LocationDataPageState();
}

class _LocationDataPageState extends State<LocationDataPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(widget.controller.load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final access = widget.controller.access;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Location Data')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(
                access: access,
                isLoading: widget.controller.isLoading,
              ),
              const SizedBox(height: 16),
              const _InformationCard(
                title: 'When location is used',
                body:
                    'CitiesWalk uses precise location when you request nearby routes and while an active journey is being tracked. Background location is not requested.',
              ),
              const SizedBox(height: 12),
              const _InformationCard(
                title: 'What is saved',
                body:
                    'Journey origins, destinations, route progress points, distance, duration, and calculated journey results are saved to your account in Supabase.',
              ),
              const SizedBox(height: 20),
              if (widget.controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    widget.controller.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              FilledButton.icon(
                onPressed: widget.controller.isLoading
                    ? null
                    : () => widget.controller.requestAccess(),
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Allow location access'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: widget.controller.openAppSettings,
                child: const Text('Open app settings'),
              ),
              if (access?.servicesEnabled == false)
                TextButton(
                  onPressed: widget.controller.openLocationSettings,
                  child: const Text('Turn on device location'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.access, required this.isLoading});

  final LocationAccess? access;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final allowed =
        access?.servicesEnabled == true &&
        access?.permissionState == LocationPermissionState.allowed;
    final label = isLoading
        ? 'Checking location access…'
        : allowed
        ? 'Location access is ready'
        : 'Location access needs attention';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allowed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle_outline : Icons.info_outline_rounded,
            color: allowed ? AppColors.primary : const Color(0xFFF9A825),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
