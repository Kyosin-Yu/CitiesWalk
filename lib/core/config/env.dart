import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw const FormatException('SUPABASE_URL is missing from assets/.env.');
    }
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException(
        'SUPABASE_URL in assets/.env is not a valid absolute URL.',
      );
    }
    if (supabasePublishableKey.isEmpty) {
      throw const FormatException(
        'SUPABASE_PUBLISHABLE_KEY is missing from assets/.env.',
      );
    }
  }
}
