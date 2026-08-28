import 'dart:async';

import 'package:citieswalk/core/localization/localized_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../business_logic/providers/settings_controller.dart';
import '../localization/settings_strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller = sl<SettingsController>();

  @override
  void initState() {
    super.initState();
    unawaited(_controller.load());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final strings = SettingsStrings.of(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            title: Text(
              strings.settings,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              child: _buildContent(strings),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(SettingsStrings strings) {
    final localeCode = _controller.settings.localeCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.notifications),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _ToggleTile(
              icon: Icons.notifications_none_rounded,
              title: strings.pushNotifications,
              subtitle: strings.notificationPending,
              value: false,
              onChanged: null,
            ),
            _ToggleTile(
              icon: Icons.near_me_outlined,
              title: strings.journeyAlerts,
              subtitle: strings.notificationPending,
              value: false,
              onChanged: null,
            ),
            _ToggleTile(
              icon: Icons.star_border_rounded,
              title: strings.reviewResponses,
              subtitle: strings.notificationPending,
              value: false,
              onChanged: null,
            ),
          ],
        ),
        const SizedBox(height: 22),

        _SectionTitle(strings.languageRegion),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _NavigationTile(
              icon: Icons.language_rounded,
              iconBackground: const Color(0xFFEAF2FF),
              iconColor: const Color(0xFF3B82F6),
              title: strings.language,
              subtitle: _languageName(localeCode),
              onTap: () => _showLanguagePicker(strings),
            ),
            _NavigationTile(
              icon: Icons.location_on_outlined,
              iconBackground: const Color(0xFFEAF2FF),
              iconColor: const Color(0xFF3B82F6),
              title: strings.cityRegion,
              subtitle: 'Kuala Lumpur, Malaysia',
              onTap: () => _showRegionInformation(strings),
            ),
          ],
        ),
        const SizedBox(height: 22),

        _SectionTitle(strings.privacyData),
        const SizedBox(height: 8),
        _SettingsCard(
          children: [
            _NavigationTile(
              icon: Icons.lock_outline_rounded,
              iconBackground: const Color(0xFFF1EBFF),
              iconColor: const Color(0xFF7C3AED),
              title: strings.privacyPolicy,
              subtitle: strings.privacySubtitle,
              onTap: () {},
            ),
            _NavigationTile(
              icon: Icons.directions_walk_rounded,
              title: strings.locationData,
              subtitle: strings.locationSubtitle,
              onTap: () {},
            ),
            _NavigationTile(
              icon: Icons.delete_outline_rounded,
              iconBackground: const Color(0xFFFFEBEE),
              iconColor: const Color(0xFFE53935),
              title: strings.deleteAccount,
              subtitle: strings.deleteSubtitle,
              titleColor: const Color(0xFFE53935),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.deletionPending)),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Center(
          child: Text(
            'CitiesWalk v2.1.0 · KL Edition 🌿',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  String _languageName(String code) => switch (code) {
    'ms' => 'Bahasa Melayu',
    'zh' => '中文（简体）',
    _ => 'English',
  };

  Future<void> _showLanguagePicker(SettingsStrings strings) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<String>(
          groupValue: _controller.settings.localeCode,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final code in const ['en', 'ms', 'zh'])
                RadioListTile<String>(
                  value: code,
                  title: Text(_languageName(code)),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (selected == null || selected == _controller.settings.localeCode) return;
    final saved = await _controller.setLocale(selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? SettingsStrings.of(context).saved : strings.saveFailed,
        ),
      ),
    );
  }

  Future<void> _showRegionInformation(SettingsStrings strings) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.cityRegion),
        content: Text(strings.klPilot),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(
          children.length,
          (index) => Column(
            children: [
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, indent: 58, color: Color(0xFFEAEAEA)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _SettingsIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: _SettingsText(title: title, subtitle: subtitle),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackground = const Color(0xFFE8F5E9),
    this.iconColor = AppColors.primary,
    this.titleColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _SettingsIcon(
              icon: icon,
              backgroundColor: iconBackground,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SettingsText(
                title: title,
                subtitle: subtitle,
                titleColor: titleColor,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    this.backgroundColor = const Color(0xFFE8F5E9),
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 19, color: iconColor),
    );
  }
}

class _SettingsText extends StatelessWidget {
  const _SettingsText({
    required this.title,
    required this.subtitle,
    this.titleColor = AppColors.textPrimary,
  });

  final String title;
  final String subtitle;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
