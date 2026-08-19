import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // This renderer belongs to the Android implementation and must not run on
    // Chrome or other non-Android platforms.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await GoogleMapsFlutterAndroid().initializeWithRenderer(
        AndroidMapRenderer.latest,
      );
    }

    await dotenv.load(fileName: 'assets/.env');
    Env.validate();

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
    await setupServiceLocator();
    runApp(const CitiesWalkApp());
  } catch (error, stackTrace) {
    debugPrint('CitiesWalk startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(_StartupErrorApp(error: error));
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Unable to start CitiesWalk',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
