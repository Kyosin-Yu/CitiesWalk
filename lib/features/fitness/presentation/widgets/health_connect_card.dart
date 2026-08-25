import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/health_activity.dart';

class HealthConnectCard extends StatelessWidget {
  const HealthConnectCard({
    super.key,
    required this.status,
    required this.isBusy,
    required this.onConnect,
    required this.onDisconnect,
    required this.onInstall,
    this.snapshot,
    this.message,
  });

  final HealthIntegrationStatus status;
  final HealthActivitySnapshot? snapshot;
  final String? message;
  final bool isBusy;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;
  final Future<void> Function() onInstall;

  @override
  Widget build(BuildContext context) {
    final connected = status == HealthIntegrationStatus.connected;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected
              ? AppColors.accent.withValues(alpha: .55)
              : const Color(0xFFE4E9E5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  connected
                      ? Icons.health_and_safety_rounded
                      : Icons.favorite_outline_rounded,
                  color: _statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _description,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: status == HealthIntegrationStatus.error
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ],
          if (connected && snapshot != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _HealthValue(
                  value: '${snapshot!.stepsToday ?? 0}',
                  label: 'steps',
                ),
                _HealthValue(
                  value: ((snapshot!.walkingDistanceMetersToday ?? 0) / 1000)
                      .toStringAsFixed(2),
                  label: 'km',
                ),
                _HealthValue(
                  value: '${snapshot!.activeCaloriesToday ?? 0}',
                  label: 'active kcal',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Synced ${_time(snapshot!.syncedAt)} • Health data does not create Eco Route rewards.',
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (status != HealthIntegrationStatus.unsupported) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (connected)
                  TextButton(
                    onPressed: isBusy
                        ? null
                        : () => _confirmDisconnect(context),
                    child: const Text('Disconnect'),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: isBusy ? null : _primaryAction,
                  icon: Icon(_primaryIcon, size: 18),
                  label: Text(_primaryLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color get _statusColor => switch (status) {
    HealthIntegrationStatus.connected => AppColors.primary,
    HealthIntegrationStatus.error => AppColors.error,
    HealthIntegrationStatus.unavailable => AppColors.warning,
    _ => AppColors.secondary,
  };

  String get _title => switch (status) {
    HealthIntegrationStatus.connected => 'Health Connect synced',
    HealthIntegrationStatus.unavailable => 'Health Connect required',
    HealthIntegrationStatus.permissionRequired => 'Connect health data',
    HealthIntegrationStatus.error => 'Health sync needs attention',
    HealthIntegrationStatus.unsupported => 'Health Connect on Android',
  };

  String get _description => switch (status) {
    HealthIntegrationStatus.connected =>
      'Today’s steps, distance and active calories come from your device.',
    HealthIntegrationStatus.unavailable =>
      'Install or update Health Connect before syncing.',
    HealthIntegrationStatus.permissionRequired =>
      'CitiesWalk requests read-only access to activity data.',
    HealthIntegrationStatus.error => 'Your Eco Route dashboard still works.',
    HealthIntegrationStatus.unsupported =>
      'Open CitiesWalk on an Android phone to connect fitness data.',
  };

  String get _primaryLabel => switch (status) {
    HealthIntegrationStatus.connected => 'Sync now',
    HealthIntegrationStatus.unavailable => 'Install',
    HealthIntegrationStatus.error => 'Try again',
    _ => 'Connect',
  };

  IconData get _primaryIcon => switch (status) {
    HealthIntegrationStatus.connected => Icons.sync_rounded,
    HealthIntegrationStatus.unavailable => Icons.download_rounded,
    _ => Icons.link_rounded,
  };

  Future<void> Function() get _primaryAction =>
      status == HealthIntegrationStatus.unavailable ? onInstall : onConnect;

  Future<void> _confirmDisconnect(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect Health Connect?'),
        content: const Text(
          'CitiesWalk will stop reading your steps, distance and active calories.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep connected'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDisconnect();
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.hour}:$minute';
  }
}

class _HealthValue extends StatelessWidget {
  const _HealthValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 8,
          ),
        ),
      ],
    ),
  );
}
