import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseClient {
  static const String url = "https://avztkbkbekvxfftvodui.supabase.co";
  static const String anonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2enR4a2tiZWZmdHZvZHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzOTMzMjUsImV4cCI6MjA3OTk2OTMyNX0.liN7spnWnbKUXsKPS6IgbN5z09AR0gD61bwpLoi5aTE"; // masukkan anon key kamu

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
