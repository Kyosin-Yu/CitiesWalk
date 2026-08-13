import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  /// Only for local development. Production Routes API calls must be proxied
  /// through a server so a web-service key is never shipped in the app.
  static String get googleRoutesApiKey =>
      dotenv.env['GOOGLE_ROUTES_API_KEY'] ?? '';
}
