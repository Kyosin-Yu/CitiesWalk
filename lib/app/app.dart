import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/service_locator.dart';
import '../features/authentication/business_logic/providers/auth_controller.dart';
import '../features/authentication/presentation/pages/auth_gate.dart';
import '../features/authentication/business_logic/providers/settings_controller.dart';
import 'theme/app_theme.dart';

class CitiesWalkApp extends StatefulWidget {
  const CitiesWalkApp({super.key});

  @override
  State<CitiesWalkApp> createState() => _CitiesWalkAppState();
}

class _CitiesWalkAppState extends State<CitiesWalkApp> {
  late final SettingsController _settingsController = sl<SettingsController>();
  late final AuthController _authController = sl<AuthController>();
  String? _settingsUserId;

  @override
  void initState() {
    super.initState();
    _authController.addListener(_syncUserSettings);
    unawaited(_settingsController.load());
  }

  void _syncUserSettings() {
    final userId = _authController.currentUser?.id;
    if (userId == _settingsUserId) return;
    _settingsUserId = userId;
    if (userId == null) {
      _settingsController.reset();
    } else {
      unawaited(_settingsController.load());
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_syncUserSettings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) => MaterialApp(
        title: 'CitiesWalk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: Locale(_settingsController.settings.localeCode),
        supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthGate(),
      ),
    );
  }
}
