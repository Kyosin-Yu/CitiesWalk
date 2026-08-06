import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/authentication/presentation/pages/login_page.dart';

class CitiesWalkApp extends StatelessWidget {
  const CitiesWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CitiesWalk',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const LoginPage(),
    );
  }
}