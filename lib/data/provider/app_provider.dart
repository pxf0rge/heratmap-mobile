import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase client accessor.
class AppProvider {
  AppProvider._();

  static SupabaseClient get db => Supabase.instance.client;
}
