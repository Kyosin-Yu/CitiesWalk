import 'package:flutter/material.dart';

import '../features/reviews/presentation/reviews_screen.dart';
import 'theme/app_theme.dart';

class CitiesWalkApp extends StatelessWidget {
  const CitiesWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CitiesWalk',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const ReviewsScreen(),
    );
  }
}
