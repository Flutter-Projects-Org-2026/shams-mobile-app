import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase client accessor.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static String? get currentUserId => client.auth.currentUser?.id;
}
